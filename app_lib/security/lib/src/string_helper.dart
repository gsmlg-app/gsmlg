import 'dart:math';

class StringHelper {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  static String randomString(int length) {
    final rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(rnd.nextInt(_chars.length))));
  }

  static String randomAscii(int length) {
    final rnd = Random();
    final Iterable<int> l = Iterable.generate(127 - 33, (n) => n + 33);
    final String chars = String.fromCharCodes(l);

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
