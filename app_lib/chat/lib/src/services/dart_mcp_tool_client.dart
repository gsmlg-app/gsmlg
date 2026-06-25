import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_mcp/client.dart' as mcp;
import 'package:dart_mcp/stdio.dart';
import 'package:dio/dio.dart';
import 'package:stream_channel/stream_channel.dart';

const _mcpSessionIdHeader = 'Mcp-Session-Id';

class DartMcpStdioServerConfig {
  const DartMcpStdioServerConfig({
    required this.command,
    this.arguments = const [],
    this.workingDirectory,
    this.environment,
  });

  final String command;
  final List<String> arguments;
  final String? workingDirectory;
  final Map<String, String>? environment;
}

class DartMcpHttpServerConfig {
  const DartMcpHttpServerConfig({required this.url, this.headers = const {}});

  final String url;
  final Map<String, String> headers;
}

class DartMcpToolClient {
  DartMcpToolClient({
    String clientName = 'GSMLG',
    String clientVersion = '1.0.0',
    Dio? dio,
  }) : _client = mcp.MCPClient(
         mcp.Implementation(name: clientName, version: clientVersion),
       ),
       _dio = dio ?? Dio();

  final mcp.MCPClient _client;
  final Dio _dio;

  Future<List<Map<String, dynamic>>> listTools(
    DartMcpStdioServerConfig config,
  ) {
    return _withInitializedServer(config, (server) async {
      final result = await server.listTools(mcp.ListToolsRequest());
      return [for (final tool in result.tools) _toolToJson(tool)];
    });
  }

  Future<List<Map<String, dynamic>>> listHttpTools(
    DartMcpHttpServerConfig config,
  ) {
    return _withInitializedChannel(_httpChannel(config), (server) async {
      final result = await server.listTools(mcp.ListToolsRequest());
      return [for (final tool in result.tools) _toolToJson(tool)];
    });
  }

  Future<Map<String, dynamic>> callTool({
    required DartMcpStdioServerConfig config,
    required String name,
    required Map<String, dynamic> arguments,
  }) {
    return _withInitializedServer(config, (server) async {
      final result = await server.callTool(
        mcp.CallToolRequest(
          name: name,
          arguments: arguments.cast<String, Object?>(),
        ),
      );
      return _callToolResultToJson(result);
    });
  }

  Future<Map<String, dynamic>> callHttpTool({
    required DartMcpHttpServerConfig config,
    required String name,
    required Map<String, dynamic> arguments,
  }) {
    return _withInitializedChannel(_httpChannel(config), (server) async {
      final result = await server.callTool(
        mcp.CallToolRequest(
          name: name,
          arguments: arguments.cast<String, Object?>(),
        ),
      );
      return _callToolResultToJson(result);
    });
  }

  Future<T> _withInitializedServer<T>(
    DartMcpStdioServerConfig config,
    Future<T> Function(mcp.ServerConnection server) callback,
  ) async {
    final process = await Process.start(
      config.command,
      config.arguments,
      workingDirectory: config.workingDirectory,
      environment: config.environment,
    );
    unawaited(process.stderr.drain<void>());

    final server = _client.connectServer(
      stdioChannel(input: process.stdout, output: process.stdin),
    );
    unawaited(server.done.then((_) => process.kill()));

    Object? failure;
    try {
      return await _initializeAndRun(server, callback);
    } catch (error, stackTrace) {
      failure = error;
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      try {
        await server.shutdown();
      } catch (error, stackTrace) {
        if (failure == null) {
          Error.throwWithStackTrace(error, stackTrace);
        }
      } finally {
        process.kill();
      }
    }
  }

  Future<T> _withInitializedChannel<T>(
    StreamChannel<String> channel,
    Future<T> Function(mcp.ServerConnection server) callback,
  ) async {
    final server = _client.connectServer(channel);
    Object? failure;
    try {
      return await _initializeAndRun(server, callback);
    } catch (error, stackTrace) {
      failure = error;
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      try {
        await server.shutdown();
      } catch (error, stackTrace) {
        if (failure == null) {
          Error.throwWithStackTrace(error, stackTrace);
        }
      }
    }
  }

  Future<T> _initializeAndRun<T>(
    mcp.ServerConnection server,
    Future<T> Function(mcp.ServerConnection server) callback,
  ) async {
    final initializeResult = await server.initialize(
      mcp.InitializeRequest(
        protocolVersion: mcp.ProtocolVersion.latestSupported,
        capabilities: _client.capabilities,
        clientInfo: _client.implementation,
      ),
    );
    if (initializeResult.capabilities.tools == null) {
      throw StateError('MCP server does not support tools');
    }
    server.notifyInitialized();
    return callback(server);
  }

  StreamChannel<String> _httpChannel(DartMcpHttpServerConfig config) {
    final controller = StreamChannelController<String>();
    String? sessionId;
    controller.local.stream.listen(
      (message) async {
        try {
          final headers = {
            'Accept': 'application/json, text/event-stream',
            'Content-Type': 'application/json',
            ...config.headers,
          };
          final currentSessionId = sessionId;
          if (currentSessionId != null) {
            headers[_mcpSessionIdHeader] = currentSessionId;
          }
          final response = await _dio.post<String>(
            config.url,
            options: Options(
              responseType: ResponseType.plain,
              headers: headers,
            ),
            data: message,
          );
          final responseSessionId = response.headers.value(_mcpSessionIdHeader);
          if (responseSessionId != null &&
              responseSessionId.trim().isNotEmpty) {
            sessionId = responseSessionId.trim();
          }
          final messages = _responseMessages(response.data);
          for (final responseMessage in messages) {
            controller.local.sink.add(responseMessage);
          }
        } on DioException catch (error, stackTrace) {
          final exception = _httpExceptionFrom(error);
          final rpcError = _jsonRpcErrorResponse(message, exception.message);
          if (rpcError == null) {
            controller.local.sink.addError(exception, stackTrace);
          } else {
            controller.local.sink.add(rpcError);
          }
        } catch (error, stackTrace) {
          controller.local.sink.addError(error, stackTrace);
        }
      },
      onError: controller.local.sink.addError,
      onDone: controller.local.sink.close,
    );
    return controller.foreign;
  }

  List<String> _responseMessages(String? body) {
    if (body == null || body.trim().isEmpty) return const [];
    final trimmed = body.trimLeft();
    if (!trimmed.startsWith('event:') && !trimmed.startsWith('data:')) {
      return [body];
    }

    final messages = <String>[];
    final dataLines = <String>[];
    for (final line in const LineSplitter().convert(body)) {
      if (line.isEmpty) {
        _flushSseData(dataLines, messages);
        continue;
      }
      if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trimLeft());
      }
    }
    _flushSseData(dataLines, messages);
    return messages;
  }

  void _flushSseData(List<String> dataLines, List<String> messages) {
    if (dataLines.isEmpty) return;
    final data = dataLines.join('\n').trim();
    dataLines.clear();
    if (data.isEmpty || data == '[DONE]') return;
    messages.add(data);
  }

  Map<String, dynamic> _toolToJson(mcp.Tool tool) {
    return {
      'name': tool.name,
      if (tool.title != null) 'title': tool.title,
      if (tool.description != null) 'description': tool.description,
      'inputSchema': _mapFrom(tool.inputSchema),
      if (tool.outputSchema != null)
        'outputSchema': _mapFrom(tool.outputSchema!),
    };
  }

  Map<String, dynamic> _callToolResultToJson(mcp.CallToolResult result) {
    return {
      'isError': result.isError ?? false,
      'content': [
        for (final content in result.content) _contentToJson(content),
      ],
      if (result.structuredContent != null)
        'structuredContent': _mapFrom(result.structuredContent!),
    };
  }

  Map<String, dynamic> _contentToJson(mcp.Content content) {
    final raw = _mapFrom(content);
    if (content.isText) {
      return {...raw, 'text': (content as mcp.TextContent).text};
    }
    return raw;
  }

  Map<String, dynamic> _mapFrom(Object? value) {
    return Map<String, dynamic>.from(value as Map);
  }
}

class DartMcpHttpException implements Exception {
  const DartMcpHttpException(this.message);

  final String message;

  @override
  String toString() => message;
}

DartMcpHttpException _httpExceptionFrom(DioException error) {
  final response = error.response;
  if (response == null) {
    return DartMcpHttpException(
      'MCP HTTP request failed: ${error.message ?? error.type.name}',
    );
  }

  final statusCode = response.statusCode;
  final statusMessage = response.statusMessage;
  final buffer = StringBuffer(
    'MCP endpoint returned HTTP $statusCode'
    '${statusMessage == null || statusMessage.isEmpty ? '' : ' $statusMessage'}.',
  );
  if (statusCode == 401) {
    buffer.write(
      ' Check the endpoint URL, Auth Type, and selected service account secret.',
    );
  }

  final challenge = response.headers.value('www-authenticate');
  if (challenge != null && challenge.trim().isNotEmpty) {
    buffer.write(' WWW-Authenticate: ${_truncateHttpDetail(challenge)}');
  }

  final body = response.data?.toString().trim();
  if (body != null && body.isNotEmpty) {
    buffer.write(' Response: ${_truncateHttpDetail(body)}');
  }

  return DartMcpHttpException(buffer.toString());
}

String _truncateHttpDetail(String value) {
  const maxLength = 300;
  final trimmed = value.trim();
  if (trimmed.length <= maxLength) return trimmed;
  return '${trimmed.substring(0, maxLength)}...';
}

String? _jsonRpcErrorResponse(String requestMessage, String message) {
  try {
    final decoded = jsonDecode(requestMessage);
    if (decoded is! Map<String, dynamic>) return null;
    final id = decoded['id'];
    if (id == null) return null;
    return jsonEncode({
      'jsonrpc': '2.0',
      'id': id,
      'error': {'code': -32000, 'message': message},
    });
  } catch (_) {
    return null;
  }
}
