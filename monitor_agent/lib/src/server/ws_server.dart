import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsServer {
  WsServer({
    required this.port,
    required this.bind,
    this.securityContext,
    this.fingerprint,
  });

  final int port;
  final String bind;
  final SecurityContext? securityContext;
  final String? fingerprint;

  bool get useTls => securityContext != null;

  HttpServer? _server;
  final List<WebSocketChannel> _clients = [];
  final _clientsController = StreamController<int>.broadcast();

  Stream<int> get clientCount => _clientsController.stream;
  int get currentClientCount => _clients.length;

  Future<void> start() async {
    final wsHandler = webSocketHandler((WebSocketChannel channel, String? _) {
      _clients.add(channel);
      _clientsController.add(_clients.length);

      channel.stream.listen(
        (data) {
          try {
            final msg = MonitorMessage.fromJson(
              jsonDecode(data as String) as Map<String, dynamic>,
            );
            if (msg.type == MonitorMessageType.ping) {
              channel.sink.add(jsonEncode(
                const MonitorMessage(
                  type: MonitorMessageType.pong,
                  payload: {},
                ).toJson(),
              ));
            }
          } catch (_) {
            // Ignore malformed messages
          }
        },
        onDone: () {
          _clients.remove(channel);
          _clientsController.add(_clients.length);
        },
        onError: (_) {
          _clients.remove(channel);
          _clientsController.add(_clients.length);
        },
      );
    });

    // Build handler pipeline with fingerprint endpoint
    shelf.Handler handler;
    if (fingerprint != null) {
      handler = const shelf.Pipeline()
          .addMiddleware(_fingerprintMiddleware)
          .addHandler(wsHandler);
    } else {
      handler = wsHandler;
    }

    if (useTls) {
      _server = await HttpServer.bindSecure(
        bind,
        port,
        securityContext!,
      );
      shelf_io.serveRequests(_server!, handler);
      print('Monitor agent listening on wss://$bind:$port');
    } else {
      _server = await shelf_io.serve(handler, bind, port);
      print('Monitor agent listening on ws://$bind:$port');
    }
  }

  shelf.Middleware get _fingerprintMiddleware =>
      (shelf.Handler innerHandler) => (shelf.Request request) {
            if (request.url.path == 'cert-fingerprint' &&
                request.method == 'GET') {
              return shelf.Response.ok(
                fingerprint ?? '',
                headers: {'content-type': 'text/plain'},
              );
            }
            return innerHandler(request);
          };

  void broadcast(MonitorMessage message) {
    final data = jsonEncode(message.toJson());
    final disconnected = <WebSocketChannel>[];

    for (final client in _clients) {
      try {
        client.sink.add(data);
      } catch (_) {
        disconnected.add(client);
      }
    }

    for (final client in disconnected) {
      _clients.remove(client);
    }
    if (disconnected.isNotEmpty) {
      _clientsController.add(_clients.length);
    }
  }

  Future<void> stop() async {
    for (final client in _clients) {
      await client.sink.close();
    }
    _clients.clear();
    await _server?.close();
    await _clientsController.close();
  }
}
