import 'dart:typed_data';
import 'package:zmodem/src/consts.dart' as consts;

extension BytesBuilderExtension on BytesBuilder {
  void addEscapedByte(int byte) {
    if (byte == consts.ZDLE) {
      addByte(consts.ZDLE);
      addByte(consts.ZDLEE);
    } else if ((byte & 0x7f) < 0x20) {
      // Escape every C0/C1 control character (like `sz -e`): terminals in
      // the path may act on them (XON/XOFF, VLNEXT, VDISCARD, ...).
      addByte(consts.ZDLE);
      addByte(byte ^ 0x40);
    } else if (byte == 0x7f) {
      addByte(consts.ZDLE);
      addByte(consts.ZRUB0);
    } else if (byte == 0xff) {
      addByte(consts.ZDLE);
      addByte(consts.ZRUB1);
    } else {
      addByte(byte);
    }
  }

  void addEscapedData(Uint8List data) {
    for (final byte in data) {
      addEscapedByte(byte);
    }
  }
}

Uint8List escapeData(Uint8List data) {
  final builder = BytesBuilder();
  builder.addEscapedData(data);
  return builder.takeBytes();
}
