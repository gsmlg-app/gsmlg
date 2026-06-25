import 'dart:convert';
import 'dart:typed_data';

import 'package:app_chat/src/services/dart_mcp_tool_client.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group('DartMcpToolClient HTTP transport', () {
    test('preserves streamable HTTP session id between requests', () async {
      final requests = <_HttpRequest>[];
      final dio = Dio();
      dio.httpClientAdapter = _McpHttpClientAdapter(requests);

      final tools = await DartMcpToolClient(dio: dio).listHttpTools(
        const DartMcpHttpServerConfig(
          url: 'https://mcp.example.com/http',
          headers: {'Authorization': 'Bearer secret'},
        ),
      );

      expect(tools, [
        {
          'name': 'search_docs',
          'description': 'Search docs',
          'inputSchema': {'type': 'object', 'properties': <String, dynamic>{}},
        },
      ]);
      expect(requests, hasLength(greaterThanOrEqualTo(2)));

      final initializeRequest = requests.firstWhere(
        (request) => request.methodName == 'initialize',
      );
      expect(initializeRequest.headers['authorization'], 'Bearer secret');
      expect(initializeRequest.headers, isNot(contains('mcp-session-id')));

      final sessionRequests = requests.where(
        (request) => request.methodName != 'initialize',
      );
      expect(sessionRequests, isNotEmpty);
      for (final request in sessionRequests) {
        expect(request.headers['authorization'], 'Bearer secret');
        expect(request.headers['mcp-session-id'], 'session-123');
      }
    });

    test('wraps unauthorized responses with an actionable message', () async {
      final dio = Dio();
      dio.httpClientAdapter = _UnauthorizedHttpClientAdapter();

      await expectLater(
        DartMcpToolClient(dio: dio).listHttpTools(
          const DartMcpHttpServerConfig(
            url: 'https://mcp.example.com/http',
            headers: {'Authorization': 'Bearer bad-token'},
          ),
        ),
        throwsA(
          predicate<Object>((error) {
            final message = error.toString();
            return message.contains(
                  'MCP endpoint returned HTTP 401 Unauthorized',
                ) &&
                message.contains('selected service account secret') &&
                message.contains('invalid token');
          }),
        ),
      );
    });
  });
}

class _HttpRequest {
  const _HttpRequest({required this.headers, required this.body});

  final Map<String, dynamic> headers;
  final String body;

  String get methodName {
    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['method'] as String;
  }
}

class _McpHttpClientAdapter implements HttpClientAdapter {
  _McpHttpClientAdapter(this.requests);

  final List<_HttpRequest> requests;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bodyBytes = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bodyBytes.addAll(chunk);
      }
    }

    final body = utf8.decode(bodyBytes);
    final headers = {
      for (final entry in options.headers.entries)
        entry.key.toLowerCase(): entry.value,
    };
    requests.add(_HttpRequest(headers: headers, body: body));

    final payload = jsonDecode(body) as Map<String, dynamic>;
    final method = payload['method'] as String?;
    final id = payload['id'];
    if (method != 'initialize' && headers['mcp-session-id'] != 'session-123') {
      return ResponseBody.fromString('Unauthorized', 401);
    }

    switch (method) {
      case 'initialize':
        return _jsonRpcResponse(
          id,
          {
            'protocolVersion': '2025-11-25',
            'capabilities': {'tools': <String, dynamic>{}},
            'serverInfo': {'name': 'Fake MCP', 'version': '1.0.0'},
          },
          headers: {
            'mcp-session-id': ['session-123'],
          },
        );
      case 'notifications/initialized':
        return ResponseBody.fromString('', 202);
      case 'tools/list':
        return _jsonRpcResponse(id, {
          'tools': [
            {
              'name': 'search_docs',
              'description': 'Search docs',
              'inputSchema': {
                'type': 'object',
                'properties': <String, dynamic>{},
              },
            },
          ],
        });
    }

    return ResponseBody.fromString('Not found', 404);
  }

  @override
  void close({bool force = false}) {}

  ResponseBody _jsonRpcResponse(
    Object? id,
    Map<String, dynamic> result, {
    Map<String, List<String>> headers = const {},
  }) {
    return ResponseBody.fromString(
      jsonEncode({'jsonrpc': '2.0', 'id': id, 'result': result}),
      200,
      headers: {
        'content-type': ['application/json'],
        ...headers,
      },
    );
  }
}

class _UnauthorizedHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      'invalid token',
      401,
      statusMessage: 'Unauthorized',
      headers: {
        'content-type': ['text/plain'],
        'www-authenticate': ['Bearer'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
