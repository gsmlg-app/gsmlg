import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_mcp/client.dart' as mcp;
import 'package:dart_mcp/stdio.dart';
import 'package:dio/dio.dart';
import 'package:stream_channel/stream_channel.dart';

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
  const DartMcpHttpServerConfig({
    required this.url,
    this.headers = const {},
  });

  final String url;
  final Map<String, String> headers;
}

class DartMcpToolClient {
  DartMcpToolClient({
    String clientName = 'GSMLG',
    String clientVersion = '1.0.0',
    Dio? dio,
  })  : _client = mcp.MCPClient(
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
      return [
        for (final tool in result.tools) _toolToJson(tool),
      ];
    });
  }

  Future<List<Map<String, dynamic>>> listHttpTools(
    DartMcpHttpServerConfig config,
  ) {
    return _withInitializedChannel(_httpChannel(config), (server) async {
      final result = await server.listTools(mcp.ListToolsRequest());
      return [
        for (final tool in result.tools) _toolToJson(tool),
      ];
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

    try {
      return await _initializeAndRun(server, callback);
    } finally {
      await server.shutdown();
      process.kill();
    }
  }

  Future<T> _withInitializedChannel<T>(
    StreamChannel<String> channel,
    Future<T> Function(mcp.ServerConnection server) callback,
  ) async {
    final server = _client.connectServer(channel);
    try {
      return await _initializeAndRun(server, callback);
    } finally {
      await server.shutdown();
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
    controller.local.stream.listen(
      (message) async {
        try {
          final response = await _dio.post<String>(
            config.url,
            options: Options(
              responseType: ResponseType.plain,
              headers: {
                'Accept': 'application/json, text/event-stream',
                'Content-Type': 'application/json',
                ...config.headers,
              },
            ),
            data: message,
          );
          final messages = _responseMessages(response.data);
          for (final responseMessage in messages) {
            controller.local.sink.add(responseMessage);
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
      return {
        ...raw,
        'text': (content as mcp.TextContent).text,
      };
    }
    return raw;
  }

  Map<String, dynamic> _mapFrom(Object? value) {
    return Map<String, dynamic>.from(value as Map);
  }
}
