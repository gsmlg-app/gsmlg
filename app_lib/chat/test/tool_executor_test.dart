import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:app_chat/app_chat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ToolExecutor web_fetch', () {
    test('adds web_fetch to chat tool definitions', () {
      final executor = ToolExecutor();

      final tools = executor.openAiToolDefinitions;
      final functions = tools
          .map((tool) => tool['function'] as Map<String, dynamic>)
          .toList();

      final webFetch = functions.firstWhere(
        (function) => function['name'] == 'web_fetch',
      );
      expect(webFetch['description'], contains('Fetch a public'));
      expect(webFetch['parameters'], {
        'type': 'object',
        'properties': {
          'url': {
            'type': 'string',
            'description': 'The public URL to fetch, e.g. https://example.com',
          },
          'max_chars': {
            'type': 'integer',
            'description':
                'Optional maximum number of content characters to return',
          },
        },
        'required': ['url'],
      });
    });

    test('fetches readable HTML content and metadata', () async {
      final executor = ToolExecutor(
        dio: _dioWithResponses({
          'https://example.com/article': _HttpResponse(
            body: '''
              <html>
                <head>
                  <title>Example Article</title>
                  <meta name="description" content="An example page">
                </head>
                <body>
                  <nav>Navigation junk</nav>
                  <article>
                    <h1>Heading</h1>
                    <p>First paragraph.</p>
                    <script>ignored()</script>
                  </article>
                </body>
              </html>
            ''',
            headers: {
              'content-type': ['text/html; charset=utf-8']
            },
          ),
        }),
      );

      final result = await executor.execute('web_fetch', {
        'url': 'https://example.com/article',
      });

      expect(result['final_url'], 'https://example.com/article');
      expect(result['status_code'], 200);
      expect(result['title'], 'Example Article');
      expect(result['description'], 'An example page');
      expect(result['content'], contains('Heading'));
      expect(result['content'], contains('First paragraph.'));
      expect(result['content'], isNot(contains('Navigation junk')));
      expect(result['content'], isNot(contains('ignored')));
      expect(result['truncated'], false);
    });

    test('follows redirects after validating each target URL', () async {
      final executor = ToolExecutor(
        dio: _dioWithResponses({
          'https://example.com/start': _HttpResponse(
            statusCode: 302,
            headers: {
              'location': ['/final'],
            },
          ),
          'https://example.com/final': const _HttpResponse(
            body: 'Done',
            headers: {
              'content-type': ['text/plain'],
            },
          ),
        }),
      );

      final result = await executor.execute('web_fetch', {
        'url': 'https://example.com/start',
      });

      expect(result['final_url'], 'https://example.com/final');
      expect(result['content'], 'Done');
    });

    test('blocks private and internal hosts', () async {
      final executor = ToolExecutor(dio: _dioWithResponses({}));

      final result = await executor.execute('web_fetch', {
        'url': 'http://127.0.0.1/admin',
      });

      expect(result['error'], contains('private or internal hosts'));
    });

    test('truncates content to max_chars', () async {
      final executor = ToolExecutor(
        dio: _dioWithResponses({
          'https://example.com/long': _HttpResponse(
            body: 'a' * 1200,
            headers: {
              'content-type': ['text/plain']
            },
          ),
        }),
      );

      final result = await executor.execute('web_fetch', {
        'url': 'https://example.com/long',
        'max_chars': 1000,
      });

      expect((result['content'] as String).length, 1000);
      expect(result['truncated'], true);
    });
  });

  group('ToolExecutor remote MCP tools', () {
    test('adds enabled remote MCP tools to chat tool definitions', () {
      final executor = ToolExecutor(
        remoteMcpProfilesProvider: () => [
          jsonEncode({
            'id': 'docs-server',
            'name': 'Docs MCP',
            'url': 'https://mcp.example.com/http',
            'transport': 'http',
            'enabled': true,
            'tools': [
              {
                'name': 'search_docs',
                'description': 'Search documentation',
                'inputSchema': {
                  'type': 'object',
                  'properties': {
                    'query': {'type': 'string'},
                  },
                  'required': ['query'],
                },
              },
            ],
          }),
          jsonEncode({
            'id': 'disabled-server',
            'name': 'Disabled MCP',
            'url': 'https://disabled.example.com/http',
            'transport': 'http',
            'enabled': false,
            'tools': [
              {'name': 'disabled_tool'},
            ],
          }),
        ],
        remoteMcpToolCaller: (server, tool, args) async {
          return {
            'server': server['name'],
            'tool': tool['name'],
            'arguments': args,
          };
        },
      );

      final tools = executor.openAiToolDefinitions;
      final functions = tools
          .map((tool) => tool['function'] as Map<String, dynamic>)
          .toList();

      expect(
        functions.map((function) => function['name']),
        contains('mcp_docs_server_search_docs'),
      );
      expect(
        functions.map((function) => function['name']),
        isNot(contains('mcp_disabled_server_disabled_tool')),
      );

      final remoteTool = functions.firstWhere(
        (function) => function['name'] == 'mcp_docs_server_search_docs',
      );
      expect(remoteTool['description'], 'Docs MCP: Search documentation');
      expect(remoteTool['parameters'], {
        'type': 'object',
        'properties': {
          'query': {'type': 'string'},
        },
        'required': ['query'],
      });
    });

    test('remote MCP tool calls are routed instead of unknown', () async {
      final executor = ToolExecutor(
        remoteMcpProfilesProvider: () => [
          jsonEncode({
            'id': 'docs',
            'name': 'Docs MCP',
            'url': 'https://mcp.example.com/http',
            'transport': 'http',
            'enabled': true,
            'tools': [
              {'name': 'search_docs'},
            ],
          }),
        ],
        dartMcpToolClient: _FakeDartMcpToolClient(),
      );

      final result = await executor.execute('mcp_docs_search_docs', {
        'query': 'flutter',
      });

      expect(result['error'], isNot('Unknown tool: mcp_docs_search_docs'));
      expect(result['server'], 'Docs MCP');
      expect(result['tool'], 'search_docs');
    });

    test('HTTP MCP tool calls use dart_mcp client', () async {
      final executor = ToolExecutor(
        remoteMcpProfilesProvider: () => [
          jsonEncode({
            'id': 'local-docs',
            'name': 'Local Docs MCP',
            'url': 'https://mcp.example.com/http',
            'transport': 'http',
            'enabled': true,
            'tools': [
              {'name': 'search_docs'},
            ],
          }),
        ],
        dartMcpToolClient: _FakeDartMcpToolClient(),
      );

      final result = await executor.execute('mcp_local_docs_search_docs', {
        'query': 'flutter',
      });

      expect(result['server'], 'Local Docs MCP');
      expect(result['tool'], 'search_docs');
      expect(result['response'], {
        'url': 'https://mcp.example.com/http',
        'tool': 'search_docs',
        'argumentsPayload': {'query': 'flutter'},
      });
    });
  });
}

Dio _dioWithResponses(Map<String, _HttpResponse> responses) {
  final dio = Dio();
  dio.httpClientAdapter = _FakeHttpClientAdapter(responses);
  return dio;
}

class _HttpResponse {
  const _HttpResponse({
    this.statusCode = 200,
    this.body = '',
    this.headers = const {},
  });

  final int statusCode;
  final String body;
  final Map<String, List<String>> headers;
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this.responses);

  final Map<String, _HttpResponse> responses;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = responses[options.uri.toString()];
    if (response == null) {
      return ResponseBody.fromString(
        'Not found',
        404,
        headers: {
          'content-type': ['text/plain'],
        },
      );
    }
    return ResponseBody.fromString(
      response.body,
      response.statusCode,
      headers: response.headers,
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeDartMcpToolClient extends DartMcpToolClient {
  @override
  Future<Map<String, dynamic>> callHttpTool({
    required DartMcpHttpServerConfig config,
    required String name,
    required Map<String, dynamic> arguments,
  }) async {
    return {
      'url': config.url,
      'tool': name,
      'argumentsPayload': arguments,
    };
  }
}
