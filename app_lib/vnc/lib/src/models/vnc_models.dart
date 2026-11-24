import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum VncAuthPreference {
  auto(0),
  none(1),
  vncPassword(2),
  appleArd(30);

  const VncAuthPreference(this.code);
  final int code;

  static VncAuthPreference fromCode(int code) => VncAuthPreference.values
      .firstWhere((v) => v.code == code, orElse: () => VncAuthPreference.auto);
}

class VncSshTunnelConfig extends Equatable {
  const VncSshTunnelConfig({
    required this.host,
    this.port = 22,
    required this.username,
    this.password,
    this.privateKeyPem,
    this.privateKeyPassphrase,
  });

  final String host;
  final int port;
  final String username;
  final String? password;
  final String? privateKeyPem;
  final String? privateKeyPassphrase;

  @override
  List<Object?> get props => [
    host,
    port,
    username,
    password,
    privateKeyPem,
    privateKeyPassphrase,
  ];
}

class VncCredentials extends Equatable {
  const VncCredentials({this.username, this.password});

  final String? username;
  final String? password;

  @override
  List<Object?> get props => [username, password];
}

class VncConnectionConfig extends Equatable {
  const VncConnectionConfig({
    required this.host,
    this.port = 5900,
    this.authPreference = VncAuthPreference.auto,
    this.credentials = const VncCredentials(),
    this.sshTunnel,
    this.viewOnly = false,
    this.sharedDesktop = true,
    this.connectTimeout = const Duration(seconds: 15),
    this.enableAppleExtensions = true,
  });

  final String host;
  final int port;
  final VncAuthPreference authPreference;
  final VncCredentials credentials;
  final VncSshTunnelConfig? sshTunnel;
  final bool viewOnly;
  final bool sharedDesktop;
  final Duration connectTimeout;

  /// Whether to negotiate native macOS `RFB 003.889` protocol extensions
  /// (encrypted record layer, `AppleDisplayLayout`, server-side `SetDisplay`,
  /// `AppleCursorCache`, and macOS button-mask mapping) when connecting to a
  /// server advertising `RFB 003.889`.
  final bool enableAppleExtensions;

  @override
  List<Object?> get props => [
    host,
    port,
    authPreference,
    credentials,
    sshTunnel,
    viewOnly,
    sharedDesktop,
    connectTimeout,
    enableAppleExtensions,
  ];
}

class VncPixelFormat extends Equatable {
  const VncPixelFormat({
    required this.bitsPerPixel,
    required this.depth,
    required this.bigEndian,
    required this.trueColor,
    required this.redMax,
    required this.greenMax,
    required this.blueMax,
    required this.redShift,
    required this.greenShift,
    required this.blueShift,
  });

  static const rgba8888 = VncPixelFormat(
    bitsPerPixel: 32,
    depth: 24,
    bigEndian: false,
    trueColor: true,
    redMax: 255,
    greenMax: 255,
    blueMax: 255,
    redShift: 0,
    greenShift: 8,
    blueShift: 16,
  );

  final int bitsPerPixel;
  final int depth;
  final bool bigEndian;
  final bool trueColor;
  final int redMax;
  final int greenMax;
  final int blueMax;
  final int redShift;
  final int greenShift;
  final int blueShift;

  int get bytesPerPixel => bitsPerPixel ~/ 8;

  Uint8List toBytes() {
    final bd = ByteData(16)
      ..setUint8(0, bitsPerPixel)
      ..setUint8(1, depth)
      ..setUint8(2, bigEndian ? 1 : 0)
      ..setUint8(3, trueColor ? 1 : 0)
      ..setUint16(4, redMax, Endian.big)
      ..setUint16(6, greenMax, Endian.big)
      ..setUint16(8, blueMax, Endian.big)
      ..setUint8(10, redShift)
      ..setUint8(11, greenShift)
      ..setUint8(12, blueShift);
    return bd.buffer.asUint8List();
  }

  factory VncPixelFormat.fromBytes(Uint8List bytes, [int offset = 0]) {
    final bd = ByteData.sublistView(bytes, offset, offset + 16);
    return VncPixelFormat(
      bitsPerPixel: bd.getUint8(0),
      depth: bd.getUint8(1),
      bigEndian: bd.getUint8(2) != 0,
      trueColor: bd.getUint8(3) != 0,
      redMax: bd.getUint16(4, Endian.big),
      greenMax: bd.getUint16(6, Endian.big),
      blueMax: bd.getUint16(8, Endian.big),
      redShift: bd.getUint8(10),
      greenShift: bd.getUint8(11),
      blueShift: bd.getUint8(12),
    );
  }

  @override
  List<Object?> get props => [
    bitsPerPixel,
    depth,
    bigEndian,
    trueColor,
    redMax,
    greenMax,
    blueMax,
    redShift,
    greenShift,
    blueShift,
  ];
}

class VncDesktopInfo extends Equatable {
  const VncDesktopInfo({
    required this.name,
    required this.width,
    required this.height,
    required this.protocolVersion,
    required this.securityType,
    this.isApple889 = false,
  });

  final String name;
  final int width;
  final int height;
  final String protocolVersion;
  final int securityType;

  /// Whether this session negotiated native macOS `RFB 003.889` mode with
  /// Apple's encrypted record layer and server-side display switching.
  final bool isApple889;

  @override
  List<Object?> get props => [
    name,
    width,
    height,
    protocolVersion,
    securityType,
    isApple889,
  ];
}

class VncScreenInfo extends Equatable {
  const VncScreenInfo({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.flags = 0,
  });

  final int id;
  final int x;
  final int y;
  final int width;
  final int height;
  final int flags;

  @override
  List<Object?> get props => [id, x, y, width, height, flags];
}

class VncCursorData extends Equatable {
  const VncCursorData({
    required this.width,
    required this.height,
    required this.hotspotX,
    required this.hotspotY,
    required this.rgbaPixels,
  });

  final int width;
  final int height;
  final int hotspotX;
  final int hotspotY;
  final Uint8List rgbaPixels;

  @override
  List<Object?> get props => [width, height, hotspotX, hotspotY, rgbaPixels];
}

@immutable
class VncFrameData {
  const VncFrameData({
    required this.frameId,
    required this.width,
    required this.height,
    required this.rgbaPixels,
  });

  final int frameId;
  final int width;
  final int height;
  final Uint8List rgbaPixels;
}

class VncDiscoveredHost extends Equatable {
  const VncDiscoveredHost({
    required this.name,
    required this.host,
    required this.port,
    this.addresses = const [],
  });

  final String name;
  final String host;
  final int port;
  final List<String> addresses;

  String get preferredAddress => addresses.isNotEmpty ? addresses.first : host;
  String get id => '$preferredAddress:$port';

  @override
  List<Object?> get props => [name, host, port, addresses];
}
