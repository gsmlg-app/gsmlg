import 'dart:convert';
import 'dart:typed_data';

import '../crypto/ard_auth.dart';
import '../crypto/vnc_des.dart';
import '../models/vnc_exceptions.dart';
import '../models/vnc_models.dart';
import '../transport/vnc_transport.dart';
import 'byte_reader.dart';
import 'rfb_encodings.dart';

/// Callback invoked during handshake when the negotiated security type requires
/// credentials that were not supplied upfront in [VncConnectionConfig].
typedef VncCredentialProvider =
    Future<VncCredentials?> Function({
      required int securityType,
      required bool requiresUsername,
    });

/// Performs the RFB 3.3 / 3.7 / 3.8 (including macOS `003.889`) handshake,
/// security authentication, initialization, and initial pixel-format/encoding
/// negotiation.
abstract final class RfbHandshake {
  static const int _maxReasonLength = 65536;
  static const int _maxDesktopNameLength = 65536;
  static const int _minArdKeyLength = 1;
  static const int _maxArdKeyLength = 1024;
  static const int _maxEncodingsCount = 0xFFFF;

  static const List<int> _autoSecurityPriority = [
    RfbSecurityType.appleArd,
    RfbSecurityType.vncAuth,
    RfbSecurityType.none,
  ];

  static final RegExp _bannerRegex = RegExp(r'^RFB (\d{3})\.(\d{3})\n$');

  /// Runs the complete RFB handshake over [transport] and [reader], returning
  /// the negotiated [VncDesktopInfo] once `SetPixelFormat` and `SetEncodings`
  /// have been transmitted.
  static Future<VncDesktopInfo> perform({
    required VncTransport transport,
    required BufferedByteReader reader,
    required VncConnectionConfig config,
    VncCredentialProvider? onCredentialsRequired,
    List<int> encodings = RfbEncoding.defaultEncodings,
  }) async {
    if (encodings.length > _maxEncodingsCount) {
      throw ArgumentError.value(
        encodings.length,
        'encodings',
        'Cannot advertise more than $_maxEncodingsCount encodings',
      );
    }

    // Step A: ProtocolVersion negotiation.
    final (:serverBannerTrimmed, :effectiveMinor) =
        await _negotiateProtocolVersion(transport, reader);

    // Step B: Security type negotiation.
    final selectedType = await _negotiateSecurityType(
      transport: transport,
      reader: reader,
      config: config,
      effectiveMinor: effectiveMinor,
    );

    // Step C: Security handshake.
    await _performSecurityHandshake(
      transport: transport,
      reader: reader,
      config: config,
      selectedType: selectedType,
      effectiveMinor: effectiveMinor,
      onCredentialsRequired: onCredentialsRequired,
    );

    // Step D: ClientInit & ServerInit.
    final (:width, :height, :name) = await _exchangeInitMessages(
      transport: transport,
      reader: reader,
      sharedDesktop: config.sharedDesktop,
    );

    // Step E: Initial SetPixelFormat (rgba8888) & SetEncodings.
    await _sendInitialConfiguration(transport: transport, encodings: encodings);

    return VncDesktopInfo(
      name: name,
      width: width,
      height: height,
      protocolVersion: serverBannerTrimmed,
      securityType: selectedType,
    );
  }

  static Future<({String serverBannerTrimmed, int effectiveMinor})>
  _negotiateProtocolVersion(
    VncTransport transport,
    BufferedByteReader reader,
  ) async {
    final bannerBytes = await reader.readBytes(12);
    final String banner;
    try {
      banner = ascii.decode(bannerBytes);
    } on FormatException catch (e) {
      throw VncProtocolException('Invalid RFB protocol version banner', e);
    }

    final match = _bannerRegex.firstMatch(banner);
    if (match == null) {
      throw VncProtocolException(
        'Invalid RFB protocol version banner: ${banner.trim()}',
      );
    }

    final major = int.parse(match.group(1)!);
    final minor = int.parse(match.group(2)!);
    final trimmed = banner.trim();

    if (major < 3) {
      throw VncProtocolException('Unsupported RFB protocol version: $trimmed');
    }

    final String clientBanner;
    final int effectiveMinor;
    if (major > 3 || minor >= 8) {
      clientBanner = 'RFB 003.008\n';
      effectiveMinor = 8;
    } else if (minor == 7) {
      clientBanner = 'RFB 003.007\n';
      effectiveMinor = 7;
    } else if (minor >= 3) {
      clientBanner = 'RFB 003.003\n';
      effectiveMinor = 3;
    } else {
      throw VncProtocolException('Unsupported RFB protocol version: $trimmed');
    }

    transport.add(Uint8List.fromList(ascii.encode(clientBanner)));
    await transport.flush();

    return (serverBannerTrimmed: trimmed, effectiveMinor: effectiveMinor);
  }

  static Future<int> _negotiateSecurityType({
    required VncTransport transport,
    required BufferedByteReader reader,
    required VncConnectionConfig config,
    required int effectiveMinor,
  }) async {
    if (effectiveMinor == 3) {
      final type = await reader.readUint32();
      if (type == RfbSecurityType.invalid) {
        final reason = await _readReasonString(reader);
        throw VncConnectionException(
          reason.isEmpty ? 'Server rejected VNC connection' : reason,
        );
      }
      if (type != RfbSecurityType.none && type != RfbSecurityType.vncAuth) {
        throw VncUnsupportedSecurityTypeException([type]);
      }
      if (config.authPreference != VncAuthPreference.auto &&
          config.authPreference.code != type) {
        throw VncUnsupportedSecurityTypeException([type]);
      }
      return type;
    }

    final count = await reader.readUint8();
    if (count == 0) {
      final reason = await _readReasonString(reader);
      throw VncConnectionException(
        reason.isEmpty ? 'Server rejected VNC connection' : reason,
      );
    }

    final offeredBytes = await reader.readBytes(count);
    final offeredTypes = List<int>.unmodifiable(offeredBytes);

    int? selectedType;
    if (config.authPreference == VncAuthPreference.auto) {
      for (final candidate in _autoSecurityPriority) {
        if (offeredTypes.contains(candidate)) {
          selectedType = candidate;
          break;
        }
      }
    } else if (offeredTypes.contains(config.authPreference.code)) {
      selectedType = config.authPreference.code;
    }

    if (selectedType == null) {
      throw VncUnsupportedSecurityTypeException(offeredTypes);
    }

    transport.add(Uint8List.fromList([selectedType]));
    await transport.flush();
    return selectedType;
  }

  static Future<void> _performSecurityHandshake({
    required VncTransport transport,
    required BufferedByteReader reader,
    required VncConnectionConfig config,
    required int selectedType,
    required int effectiveMinor,
    required VncCredentialProvider? onCredentialsRequired,
  }) async {
    final isVersion38 = effectiveMinor >= 8;

    switch (selectedType) {
      case RfbSecurityType.none:
        if (isVersion38) {
          await _readSecurityResult(reader, isVersion38: true);
        }
      case RfbSecurityType.vncAuth:
        final challenge = await reader.readBytes(16);
        var password = config.credentials.password;
        if (password == null || password.isEmpty) {
          final provided = await onCredentialsRequired?.call(
            securityType: RfbSecurityType.vncAuth,
            requiresUsername: false,
          );
          password = provided?.password;
        }
        if (password == null) {
          throw const VncAuthenticationException('VNC password is required');
        }

        final response = VncDes.encryptChallenge(challenge, password);
        transport.add(response);
        await transport.flush();
        await _readSecurityResult(reader, isVersion38: isVersion38);
      case RfbSecurityType.appleArd:
        final generator = await reader.readUint16();
        final keyLength = await reader.readUint16();
        if (keyLength < _minArdKeyLength || keyLength > _maxArdKeyLength) {
          throw VncProtocolException(
            'Invalid Apple ARD Diffie-Hellman key length: $keyLength',
          );
        }

        final primeBytes = await reader.readBytes(keyLength);
        final serverPubKeyBytes = await reader.readBytes(keyLength);

        var username = config.credentials.username;
        var password = config.credentials.password;
        if (username == null || username.isEmpty || password == null) {
          final provided = await onCredentialsRequired?.call(
            securityType: RfbSecurityType.appleArd,
            requiresUsername: true,
          );
          username = provided?.username;
          password = provided?.password;
        }
        if (username == null || username.isEmpty || password == null) {
          throw const VncAuthenticationException(
            'macOS username and password are required',
          );
        }

        final ArdAuthResponse ardResponse;
        try {
          ardResponse = ArdAuthCrypto.buildResponse(
            generator: generator,
            keyLength: keyLength,
            primeBytes: primeBytes,
            serverPublicKeyBytes: serverPubKeyBytes,
            username: username,
            password: password,
          );
        } on ArgumentError catch (e) {
          throw VncProtocolException(
            'Invalid Apple ARD Diffie-Hellman parameters',
            e,
          );
        }

        final credLen = ardResponse.encryptedCredentials.length;
        final pubLen = ardResponse.clientPublicKey.length;
        final payload = Uint8List(credLen + pubLen)
          ..setRange(0, credLen, ardResponse.encryptedCredentials)
          ..setRange(credLen, credLen + pubLen, ardResponse.clientPublicKey);
        transport.add(payload);
        await transport.flush();
        await _readSecurityResult(reader, isVersion38: isVersion38);
      default:
        throw VncUnsupportedSecurityTypeException([selectedType]);
    }
  }

  static Future<void> _readSecurityResult(
    BufferedByteReader reader, {
    required bool isVersion38,
  }) async {
    final status = await reader.readUint32();
    if (status == 0) {
      return;
    }

    if (isVersion38) {
      final reason = await _readReasonString(reader);
      throw VncAuthenticationException(
        reason.isEmpty ? 'VNC authentication failed (status $status)' : reason,
      );
    }

    throw VncAuthenticationException(
      'VNC authentication failed (status $status)',
    );
  }

  static Future<String> _readReasonString(BufferedByteReader reader) async {
    final length = await reader.readUint32();
    if (length > _maxReasonLength) {
      throw VncProtocolException('RFB reason string too large: $length bytes');
    }
    if (length == 0) {
      return '';
    }
    final bytes = await reader.readBytes(length);
    return utf8.decode(bytes, allowMalformed: true);
  }

  static Future<({int width, int height, String name})> _exchangeInitMessages({
    required VncTransport transport,
    required BufferedByteReader reader,
    required bool sharedDesktop,
  }) async {
    transport.add(Uint8List.fromList([sharedDesktop ? 1 : 0]));
    await transport.flush();

    final width = await reader.readUint16();
    final height = await reader.readUint16();
    if (width <= 0 || height <= 0) {
      throw VncProtocolException(
        'Invalid remote desktop dimensions: ${width}x$height',
      );
    }

    // Ignore server's default pixel format; we negotiate rgba8888 immediately.
    await reader.skip(16);

    final nameLength = await reader.readUint32();
    if (nameLength > _maxDesktopNameLength) {
      throw VncProtocolException(
        'RFB desktop name too large: $nameLength bytes',
      );
    }
    final nameBytes = await reader.readBytes(nameLength);
    final name = utf8.decode(nameBytes, allowMalformed: true);

    return (width: width, height: height, name: name);
  }

  static Future<void> _sendInitialConfiguration({
    required VncTransport transport,
    required List<int> encodings,
  }) async {
    // SetPixelFormat: [0, 0, 0, 0, ...16-byte VncPixelFormat.rgba8888]
    final setPixelFormat = Uint8List(20)
      ..setRange(4, 20, VncPixelFormat.rgba8888.toBytes());

    // SetEncodings: [2, 0, countHi, countLo, ...int32BE(encoding)]
    final setEncodings = Uint8List(4 + encodings.length * 4);
    final bd = ByteData.sublistView(setEncodings)
      ..setUint8(0, 2)
      ..setUint8(1, 0)
      ..setUint16(2, encodings.length, Endian.big);
    for (var i = 0; i < encodings.length; i++) {
      bd.setInt32(4 + i * 4, encodings[i], Endian.big);
    }

    transport.add(setPixelFormat);
    transport.add(setEncodings);
    await transport.flush();
  }
}
