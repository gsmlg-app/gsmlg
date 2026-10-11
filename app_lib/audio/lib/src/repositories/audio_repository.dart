import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/vault_repository.dart';
import '../models/audio_settings.dart';

class OpenAiAudioRepository {
  OpenAiAudioRepository({
    this.database,
    this.vault,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final AppDatabase? database;
  final VaultRepository? vault;
  final http.Client _httpClient;

  Future<String?> resolveToken(AudioSettings settings) async {
    if (settings.useDummyToken) return null;
    final accountId = settings.accountId;
    if (accountId == null) return null;

    final localVault = vault;
    if (localVault != null) {
      return (await localVault.read(key: 'service_account_$accountId'))?.trim();
    }
    return null;
  }

  Uri _resolveEndpoint(String baseUrl, String path) {
    final cleanBase = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final cleanPath = path.trim().replaceAll(RegExp(r'^/+'), '');
    return Uri.parse('$cleanBase/$cleanPath');
  }

  Future<Uint8List> synthesizeSpeech(
    AudioSettings settings,
    String text, {
    String? model,
    String? voice,
    double? speed,
    String? format,
  }) async {
    final uri = _resolveEndpoint(settings.baseUrl, 'audio/speech');
    final token = await resolveToken(settings);

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'model': model ?? settings.ttsModel,
      'input': text,
      'voice': voice ?? settings.ttsVoice,
      'speed': speed ?? settings.ttsSpeed,
      'response_format': format ?? settings.ttsResponseFormat,
    });

    final response = await _httpClient.post(uri, headers: headers, body: body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }

    throw HttpException(
      'TTS request failed [${response.statusCode}]: ${response.body}',
      uri: uri,
    );
  }

  Future<String> transcribeAudio(
    AudioSettings settings, {
    List<int>? bytes,
    String? filename,
    String? filePath,
    String? model,
    String? language,
  }) async {
    final uri = _resolveEndpoint(settings.baseUrl, 'audio/transcriptions');
    final token = await resolveToken(settings);

    final request = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['model'] = model ?? settings.asrModel;
    final effectiveLanguage = language ?? settings.asrLanguage;
    if (effectiveLanguage != null && effectiveLanguage.isNotEmpty) {
      request.fields['language'] = effectiveLanguage;
    }
    request.fields['response_format'] = 'json';

    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    } else if (bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename ?? 'audio.wav',
          contentType: MediaType('audio', 'wav'),
        ),
      );
    } else {
      throw ArgumentError('Either filePath or bytes must be provided.');
    }

    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['text'] as String? ?? '';
    }

    throw HttpException(
      'ASR request failed [${response.statusCode}]: ${response.body}',
      uri: uri,
    );
  }
}
