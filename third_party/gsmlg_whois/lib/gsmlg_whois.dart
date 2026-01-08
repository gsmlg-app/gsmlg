library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// WHOIS lookup client for querying domain and IP information.
class Whois {
  /// The root WHOIS server (IANA).
  static const rootServer = 'whois.iana.org';

  /// Performs a WHOIS query and returns the first result.
  static Future<String> query(String query) async {
    final whois = Whois();
    return await whois.whois(query);
  }

  /// Performs a WHOIS query and returns all results from the server chain.
  static Future<List<String>> queryList(String query) async {
    final whois = Whois();
    return await whois.whoisList(query);
  }

  /// Performs a WHOIS query and returns results with server information.
  static Future<List<Map<String, String>>> queryListWithServer(
    String query,
  ) async {
    final whois = Whois();
    return await whois.whoisQuery(query);
  }

  /// Performs a WHOIS lookup and returns the first result.
  Future<String> whois(String q) async {
    final list = await whoisQuery(q);
    final d = list.first;

    return d['data'] ?? '';
  }

  /// Performs a WHOIS lookup and returns all results as a list.
  Future<List<String>> whoisList(String q) async {
    final list = await whoisQuery(q);

    return list.map((h) => h['data'] ?? '').toList();
  }

  /// Performs a WHOIS lookup, following referrals through the server chain.
  ///
  /// Returns a list of maps containing 'server' and 'data' for each response.
  Future<List<Map<String, String>>> whoisQuery(
    String q, {
    String server = rootServer,
  }) async {
    final socket = await Socket.connect(server, 43);
    socket.write('$q\r\n');
    final c = Completer<String>();
    Uint8List buffer = Uint8List(0);
    socket.listen(
      (data) {
        buffer = Uint8List.fromList(buffer + data);
      },
      onDone: () => c.complete(utf8.decode(buffer)),
      onError: (e) => c.completeError(e),
    );

    final r = await c.future;
    socket.close();
    final lines = r.split('\n');

    var l = lines.firstWhere((element) {
      var ll = element.toLowerCase();
      if (ll.startsWith('whois:') ||
          ll.startsWith('refer:') ||
          ll.contains('WHOIS Server:')) {
        return true;
      }
      return false;
    }, orElse: () => ':');

    final nextServer = l.split(':')[1].trim();
    if (server == nextServer || nextServer.isEmpty) {
      return [
        {'server': server, 'data': r},
      ];
    }
    final list = await whoisQuery(q, server: nextServer);
    return list..add({'server': server, 'data': r});
  }

  /// Queries a specific WHOIS server directly.
  Future<String> queryServer(
    String query,
    String server, {
    int port = 43,
  }) async {
    final socket = await Socket.connect(server, port);
    socket.write('$query\r\n');
    final c = Completer<String>();
    Uint8List buffer = Uint8List(0);
    socket.listen(
      (data) {
        buffer = Uint8List.fromList(buffer + data);
      },
      onDone: () => c.complete(utf8.decode(buffer)),
      onError: (e) => c.completeError(e),
    );

    final r = await c.future;
    socket.close();
    return r;
  }
}
