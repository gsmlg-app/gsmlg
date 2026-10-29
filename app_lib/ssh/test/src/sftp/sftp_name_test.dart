import 'package:test/test.dart';
import 'package:app_ssh/src/sftp/sftp_name.dart';
import 'package:app_ssh/src/sftp/sftp_file_attrs.dart';
import 'package:app_ssh/src/ssh_message.dart';

void main() {
  group('SftpName', () {
    test('constructor sets all fields', () {
      final attr = SftpFileAttrs();
      final name = SftpName(
        filename: 'test.txt',
        longname: '-rw-r--r-- 1 user group 1024 Jan 20 12:00 test.txt',
        attr: attr,
      );

      expect(name.filename, 'test.txt');
      expect(
          name.longname, '-rw-r--r-- 1 user group 1024 Jan 20 12:00 test.txt');
      expect(name.attr, attr);
    });

    test('filename can be empty string', () {
      final name = SftpName(
        filename: '',
        longname: '',
        attr: SftpFileAttrs(),
      );
      expect(name.filename, '');
    });

    test('filename can contain special characters', () {
      final name = SftpName(
        filename: 'file with spaces.txt',
        longname: '-rw-r--r-- file with spaces.txt',
        attr: SftpFileAttrs(),
      );
      expect(name.filename, 'file with spaces.txt');
    });

    test('filename can contain unicode', () {
      final name = SftpName(
        filename: '文件名.txt',
        longname: '-rw-r--r-- 文件名.txt',
        attr: SftpFileAttrs(),
      );
      expect(name.filename, '文件名.txt');
    });

    test('toString includes all fields', () {
      final name = SftpName(
        filename: 'example.txt',
        longname: '-rw-r--r-- example.txt',
        attr: SftpFileAttrs(),
      );
      final str = name.toString();
      expect(str, contains('SftpName'));
      expect(str, contains('filename: example.txt'));
      expect(str, contains('longname:'));
      expect(str, contains('attr:'));
    });

    group('readFrom and writeTo', () {
      test('round trip preserves data', () {
        final original = SftpName(
          filename: 'document.pdf',
          longname: '-rw-r--r-- 1 owner group 2048 Jan 21 10:00 document.pdf',
          attr: SftpFileAttrs(),
        );

        // Write to buffer
        final writer = SSHMessageWriter();
        original.writeTo(writer);
        final bytes = writer.takeBytes();

        // Read back
        final reader = SSHMessageReader(bytes);
        final decoded = SftpName.readFrom(reader);

        expect(decoded.filename, original.filename);
        expect(decoded.longname, original.longname);
      });

      test('handles empty filename and longname', () {
        final original = SftpName(
          filename: '',
          longname: '',
          attr: SftpFileAttrs(),
        );

        final writer = SSHMessageWriter();
        original.writeTo(writer);
        final bytes = writer.takeBytes();

        final reader = SSHMessageReader(bytes);
        final decoded = SftpName.readFrom(reader);

        expect(decoded.filename, '');
        expect(decoded.longname, '');
      });

      test('handles unicode in filename', () {
        final original = SftpName(
          filename: '日本語ファイル.txt',
          longname: '-rw-r--r-- 日本語ファイル.txt',
          attr: SftpFileAttrs(),
        );

        final writer = SSHMessageWriter();
        original.writeTo(writer);
        final bytes = writer.takeBytes();

        final reader = SSHMessageReader(bytes);
        final decoded = SftpName.readFrom(reader);

        expect(decoded.filename, '日本語ファイル.txt');
      });

      test('handles very long filename', () {
        final longFilename = 'a' * 1000;
        final original = SftpName(
          filename: longFilename,
          longname: '-rw-r--r-- $longFilename',
          attr: SftpFileAttrs(),
        );

        final writer = SSHMessageWriter();
        original.writeTo(writer);
        final bytes = writer.takeBytes();

        final reader = SSHMessageReader(bytes);
        final decoded = SftpName.readFrom(reader);

        expect(decoded.filename, longFilename);
      });
    });

    group('typical usage scenarios', () {
      test('directory listing entry', () {
        final dirEntry = SftpName(
          filename: 'documents',
          longname: 'drwxr-xr-x 5 user group 4096 Jan 20 15:30 documents',
          attr: SftpFileAttrs(),
        );

        expect(dirEntry.filename, 'documents');
        expect(dirEntry.longname, startsWith('d')); // Directory
      });

      test('regular file entry', () {
        final fileEntry = SftpName(
          filename: 'report.pdf',
          longname: '-rw-r--r-- 1 user group 102400 Jan 19 09:00 report.pdf',
          attr: SftpFileAttrs(),
        );

        expect(fileEntry.filename, 'report.pdf');
        expect(fileEntry.longname, startsWith('-')); // Regular file
      });

      test('symbolic link entry', () {
        final linkEntry = SftpName(
          filename: 'link',
          longname: 'lrwxrwxrwx 1 user group 10 Jan 18 12:00 link -> target',
          attr: SftpFileAttrs(),
        );

        expect(linkEntry.filename, 'link');
        expect(linkEntry.longname, startsWith('l')); // Symbolic link
      });

      test('hidden file entry', () {
        final hiddenEntry = SftpName(
          filename: '.hidden',
          longname: '-rw------- 1 user group 512 Jan 17 08:00 .hidden',
          attr: SftpFileAttrs(),
        );

        expect(hiddenEntry.filename, startsWith('.'));
      });
    });
  });
}
