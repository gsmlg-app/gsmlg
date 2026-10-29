import 'package:test/test.dart';
import 'package:app_ssh/src/sftp/sftp_file_open_mode.dart';

void main() {
  group('SftpFileOpenMode', () {
    group('constants', () {
      test('read has flag 1', () {
        expect(SftpFileOpenMode.read.flag, 1);
      });

      test('write has flag 2', () {
        expect(SftpFileOpenMode.write.flag, 2);
      });

      test('append has flag 4', () {
        expect(SftpFileOpenMode.append.flag, 4);
      });

      test('create has flag 8', () {
        expect(SftpFileOpenMode.create.flag, 8);
      });

      test('truncate has flag 16', () {
        expect(SftpFileOpenMode.truncate.flag, 16);
      });

      test('exclusive has flag 32', () {
        expect(SftpFileOpenMode.exclusive.flag, 32);
      });
    });

    group('bitwise OR operator', () {
      test('read | write combines flags', () {
        final mode = SftpFileOpenMode.read | SftpFileOpenMode.write;
        expect(mode.flag, 3); // 1 | 2 = 3
      });

      test('read | write | append combines all three', () {
        final mode = SftpFileOpenMode.read |
            SftpFileOpenMode.write |
            SftpFileOpenMode.append;
        expect(mode.flag, 7); // 1 | 2 | 4 = 7
      });

      test('create | truncate combines flags', () {
        final mode = SftpFileOpenMode.create | SftpFileOpenMode.truncate;
        expect(mode.flag, 24); // 8 | 16 = 24
      });

      test('combining same flag twice has no effect', () {
        final mode = SftpFileOpenMode.read | SftpFileOpenMode.read;
        expect(mode.flag, 1);
      });

      test('all flags combined', () {
        final mode = SftpFileOpenMode.read |
            SftpFileOpenMode.write |
            SftpFileOpenMode.append |
            SftpFileOpenMode.create |
            SftpFileOpenMode.truncate |
            SftpFileOpenMode.exclusive;
        expect(mode.flag, 63); // 1|2|4|8|16|32 = 63
      });
    });

    group('common combinations', () {
      test('read only', () {
        final mode = SftpFileOpenMode.read;
        expect(mode.flag & SftpFileOpenMode.read.flag, isNot(0));
        expect(mode.flag & SftpFileOpenMode.write.flag, 0);
      });

      test('write with create and truncate', () {
        final mode = SftpFileOpenMode.write |
            SftpFileOpenMode.create |
            SftpFileOpenMode.truncate;
        expect(mode.flag, 26); // 2 | 8 | 16
      });

      test('append with create', () {
        final mode = SftpFileOpenMode.write |
            SftpFileOpenMode.append |
            SftpFileOpenMode.create;
        expect(mode.flag, 14); // 2 | 4 | 8
      });

      test('create with exclusive', () {
        final mode = SftpFileOpenMode.write |
            SftpFileOpenMode.create |
            SftpFileOpenMode.exclusive;
        expect(mode.flag, 42); // 2 | 8 | 32
      });
    });

    group('flag checking', () {
      test('can check if read flag is set', () {
        final mode = SftpFileOpenMode.read | SftpFileOpenMode.write;
        expect(mode.flag & SftpFileOpenMode.read.flag, isNot(0));
      });

      test('can check if write flag is set', () {
        final mode = SftpFileOpenMode.read | SftpFileOpenMode.write;
        expect(mode.flag & SftpFileOpenMode.write.flag, isNot(0));
      });

      test('can check if flag is not set', () {
        final mode = SftpFileOpenMode.read;
        expect(mode.flag & SftpFileOpenMode.write.flag, 0);
        expect(mode.flag & SftpFileOpenMode.create.flag, 0);
      });
    });

    group('real-world use cases', () {
      test('opening file for reading', () {
        final mode = SftpFileOpenMode.read;
        expect(mode.flag, 1);
      });

      test('creating new file for writing', () {
        final mode = SftpFileOpenMode.write | SftpFileOpenMode.create;
        expect(mode.flag & SftpFileOpenMode.write.flag, isNot(0));
        expect(mode.flag & SftpFileOpenMode.create.flag, isNot(0));
      });

      test('truncating existing file', () {
        final mode = SftpFileOpenMode.write |
            SftpFileOpenMode.create |
            SftpFileOpenMode.truncate;
        expect(mode.flag & SftpFileOpenMode.truncate.flag, isNot(0));
      });

      test('appending to file', () {
        final mode = SftpFileOpenMode.write |
            SftpFileOpenMode.append |
            SftpFileOpenMode.create;
        expect(mode.flag & SftpFileOpenMode.append.flag, isNot(0));
      });

      test('exclusive creation (fail if exists)', () {
        final mode = SftpFileOpenMode.write |
            SftpFileOpenMode.create |
            SftpFileOpenMode.exclusive;
        expect(mode.flag & SftpFileOpenMode.exclusive.flag, isNot(0));
      });
    });
  });
}
