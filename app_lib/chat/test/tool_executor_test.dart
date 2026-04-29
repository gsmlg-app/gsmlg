import 'dart:convert';

import 'package:app_chat/app_chat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      );

      final result = await executor.execute('mcp_docs_search_docs', {
        'query': 'flutter',
      });

      expect(result['error'], isNot('Unknown tool: mcp_docs_search_docs'));
      expect(result['server'], 'Docs MCP');
      expect(result['tool'], 'search_docs');
    });
  });
}
