import 'package:test/test.dart';
import 'package:app_ssh/src/sftp/sftp_file_attrs.dart';

void main() {
  group('SftpFileType', () {
    test('has all expected values', () {
      expect(SftpFileType.values.length, 9);
      expect(SftpFileType.unknown, isNotNull);
      expect(SftpFileType.regularFile, isNotNull);
      expect(SftpFileType.directory, isNotNull);
      expect(SftpFileType.symbolicLink, isNotNull);
      expect(SftpFileType.blockDevice, isNotNull);
      expect(SftpFileType.characterDevice, isNotNull);
      expect(SftpFileType.pipe, isNotNull);
      expect(SftpFileType.socket, isNotNull);
      expect(SftpFileType.whiteout, isNotNull);
    });
  });

  group('SftpFileMode', () {
    group('factory constructor', () {
      test('creates mode with all permissions by default', () {
        final mode = SftpFileMode();
        expect(mode.userRead, isTrue);
        expect(mode.userWrite, isTrue);
        expect(mode.userExecute, isTrue);
        expect(mode.groupRead, isTrue);
        expect(mode.groupWrite, isTrue);
        expect(mode.groupExecute, isTrue);
        expect(mode.otherRead, isTrue);
        expect(mode.otherWrite, isTrue);
        expect(mode.otherExecute, isTrue);
      });

      test('creates mode with selective permissions', () {
        final mode = SftpFileMode(
          userRead: true,
          userWrite: true,
          userExecute: false,
          groupRead: true,
          groupWrite: false,
          groupExecute: false,
          otherRead: true,
          otherWrite: false,
          otherExecute: false,
        );
        expect(mode.userRead, isTrue);
        expect(mode.userWrite, isTrue);
        expect(mode.userExecute, isFalse);
        expect(mode.groupRead, isTrue);
        expect(mode.groupWrite, isFalse);
        expect(mode.groupExecute, isFalse);
        expect(mode.otherRead, isTrue);
        expect(mode.otherWrite, isFalse);
        expect(mode.otherExecute, isFalse);
      });

      test('creates mode with no permissions', () {
        final mode = SftpFileMode(
          userRead: false,
          userWrite: false,
          userExecute: false,
          groupRead: false,
          groupWrite: false,
          groupExecute: false,
          otherRead: false,
          otherWrite: false,
          otherExecute: false,
        );
        expect(mode.userRead, isFalse);
        expect(mode.userWrite, isFalse);
        expect(mode.userExecute, isFalse);
        expect(mode.groupRead, isFalse);
        expect(mode.groupWrite, isFalse);
        expect(mode.groupExecute, isFalse);
        expect(mode.otherRead, isFalse);
        expect(mode.otherWrite, isFalse);
        expect(mode.otherExecute, isFalse);
      });
    });

    group('value constructor', () {
      test('creates mode from octal value 755', () {
        // 755 octal = 493 decimal = rwxr-xr-x
        const mode = SftpFileMode.value(493);
        expect(mode.userRead, isTrue);
        expect(mode.userWrite, isTrue);
        expect(mode.userExecute, isTrue);
        expect(mode.groupRead, isTrue);
        expect(mode.groupWrite, isFalse);
        expect(mode.groupExecute, isTrue);
        expect(mode.otherRead, isTrue);
        expect(mode.otherWrite, isFalse);
        expect(mode.otherExecute, isTrue);
      });

      test('creates mode from octal value 644', () {
        // 644 octal = 420 decimal = rw-r--r--
        const mode = SftpFileMode.value(420);
        expect(mode.userRead, isTrue);
        expect(mode.userWrite, isTrue);
        expect(mode.userExecute, isFalse);
        expect(mode.groupRead, isTrue);
        expect(mode.groupWrite, isFalse);
        expect(mode.groupExecute, isFalse);
        expect(mode.otherRead, isTrue);
        expect(mode.otherWrite, isFalse);
        expect(mode.otherExecute, isFalse);
      });

      test('creates mode from octal value 600', () {
        // 600 octal = 384 decimal = rw-------
        const mode = SftpFileMode.value(384);
        expect(mode.userRead, isTrue);
        expect(mode.userWrite, isTrue);
        expect(mode.userExecute, isFalse);
        expect(mode.groupRead, isFalse);
        expect(mode.groupWrite, isFalse);
        expect(mode.groupExecute, isFalse);
        expect(mode.otherRead, isFalse);
        expect(mode.otherWrite, isFalse);
        expect(mode.otherExecute, isFalse);
      });

      test('creates mode from octal value 777', () {
        // 777 octal = 511 decimal = rwxrwxrwx
        const mode = SftpFileMode.value(511);
        expect(mode.userRead, isTrue);
        expect(mode.userWrite, isTrue);
        expect(mode.userExecute, isTrue);
        expect(mode.groupRead, isTrue);
        expect(mode.groupWrite, isTrue);
        expect(mode.groupExecute, isTrue);
        expect(mode.otherRead, isTrue);
        expect(mode.otherWrite, isTrue);
        expect(mode.otherExecute, isTrue);
      });
    });

    group('type detection', () {
      test('detects regular file', () {
        // 0100644 = 33188 decimal
        const mode = SftpFileMode.value(33188);
        expect(mode.type, SftpFileType.regularFile);
      });

      test('detects directory', () {
        // 0040755 = 16877 decimal
        const mode = SftpFileMode.value(16877);
        expect(mode.type, SftpFileType.directory);
      });

      test('detects symbolic link', () {
        // 0120777 = 41471 decimal
        const mode = SftpFileMode.value(41471);
        expect(mode.type, SftpFileType.symbolicLink);
      });

      test('detects block device', () {
        // 0060660 = 25008 decimal
        const mode = SftpFileMode.value(25008);
        expect(mode.type, SftpFileType.blockDevice);
      });

      test('detects character device', () {
        // 0020666 = 8630 decimal
        const mode = SftpFileMode.value(8630);
        expect(mode.type, SftpFileType.characterDevice);
      });

      test('detects pipe (FIFO)', () {
        // 0010644 = 4516 decimal
        const mode = SftpFileMode.value(4516);
        expect(mode.type, SftpFileType.pipe);
      });

      test('detects socket', () {
        // 0140755 = 49645 decimal
        const mode = SftpFileMode.value(49645);
        expect(mode.type, SftpFileType.socket);
      });

      test('detects whiteout', () {
        // 0160000 = 57344 decimal
        const mode = SftpFileMode.value(57344);
        expect(mode.type, SftpFileType.whiteout);
      });

      test('returns unknown for invalid type', () {
        const mode = SftpFileMode.value(0);
        expect(mode.type, SftpFileType.unknown);
      });
    });

    group('toString', () {
      test('includes runtime type and octal value', () {
        const mode = SftpFileMode.value(420);
        final str = mode.toString();
        expect(str, contains('SftpFileMode'));
        expect(str, contains('644')); // 420 decimal = 644 octal
      });
    });
  });

  group('SftpFileAttrs', () {
    group('constructor', () {
      test('creates attrs with all optional fields null', () {
        final attrs = SftpFileAttrs();
        expect(attrs.size, isNull);
        expect(attrs.userID, isNull);
        expect(attrs.groupID, isNull);
        expect(attrs.mode, isNull);
        expect(attrs.accessTime, isNull);
        expect(attrs.modifyTime, isNull);
        expect(attrs.extended, isNull);
      });

      test('creates attrs with size', () {
        final attrs = SftpFileAttrs(size: 1024);
        expect(attrs.size, 1024);
      });

      test('creates attrs with user and group ID', () {
        final attrs = SftpFileAttrs(userID: 1000, groupID: 1000);
        expect(attrs.userID, 1000);
        expect(attrs.groupID, 1000);
      });

      test('creates attrs with mode', () {
        const mode = SftpFileMode.value(420);
        final attrs = SftpFileAttrs(mode: mode);
        expect(attrs.mode, isNotNull);
        expect(attrs.mode!.value, 420);
      });

      test('creates attrs with timestamps', () {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final attrs = SftpFileAttrs(accessTime: now, modifyTime: now);
        expect(attrs.accessTime, now);
        expect(attrs.modifyTime, now);
      });

      test('creates attrs with extended attributes', () {
        final attrs = SftpFileAttrs(extended: {'custom': 'value'});
        expect(attrs.extended, {'custom': 'value'});
      });
    });

    group('type helpers', () {
      test('isDirectory returns true for directory', () {
        const mode = SftpFileMode.value(16877); // 0040755
        final attrs = SftpFileAttrs(mode: mode);
        expect(attrs.isDirectory, isTrue);
        expect(attrs.isFile, isFalse);
      });

      test('isFile returns true for regular file', () {
        const mode = SftpFileMode.value(33188); // 0100644
        final attrs = SftpFileAttrs(mode: mode);
        expect(attrs.isFile, isTrue);
        expect(attrs.isDirectory, isFalse);
      });

      test('isSymbolicLink returns true for symbolic link', () {
        const mode = SftpFileMode.value(41471); // 0120777
        final attrs = SftpFileAttrs(mode: mode);
        expect(attrs.isSymbolicLink, isTrue);
      });

      test('isBlockDevice returns true for block device', () {
        const mode = SftpFileMode.value(25008); // 0060660
        final attrs = SftpFileAttrs(mode: mode);
        expect(attrs.isBlockDevice, isTrue);
      });

      test('isCharacterDevice returns true for character device', () {
        const mode = SftpFileMode.value(8630); // 0020666
        final attrs = SftpFileAttrs(mode: mode);
        expect(attrs.isCharacterDevice, isTrue);
      });

      test('isPipe returns true for pipe', () {
        const mode = SftpFileMode.value(4516); // 0010644
        final attrs = SftpFileAttrs(mode: mode);
        expect(attrs.isPipe, isTrue);
      });

      test('isSocket returns true for socket', () {
        const mode = SftpFileMode.value(49645); // 0140755
        final attrs = SftpFileAttrs(mode: mode);
        expect(attrs.isSocket, isTrue);
      });

      test('isWhiteout returns true for whiteout', () {
        const mode = SftpFileMode.value(57344); // 0160000
        final attrs = SftpFileAttrs(mode: mode);
        expect(attrs.isWhiteout, isTrue);
      });

      test('type returns null when mode is null', () {
        final attrs = SftpFileAttrs();
        expect(attrs.type, isNull);
        expect(attrs.isDirectory, isFalse);
        expect(attrs.isFile, isFalse);
      });
    });

    group('toString', () {
      test('includes size when present', () {
        final attrs = SftpFileAttrs(size: 1024);
        expect(attrs.toString(), contains('size: 1024'));
      });

      test('includes uid when present', () {
        final attrs = SftpFileAttrs(userID: 1000);
        expect(attrs.toString(), contains('uid: 1000'));
      });

      test('includes gid when present', () {
        final attrs = SftpFileAttrs(groupID: 100);
        expect(attrs.toString(), contains('gid: 100'));
      });

      test('includes mode when present', () {
        const mode = SftpFileMode.value(420);
        final attrs = SftpFileAttrs(mode: mode);
        expect(attrs.toString(), contains('mode'));
      });

      test('empty attrs has minimal string', () {
        final attrs = SftpFileAttrs();
        expect(attrs.toString(), 'SftpFileAttrs()');
      });
    });
  });
}
