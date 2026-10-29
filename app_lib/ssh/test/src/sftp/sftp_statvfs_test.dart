import 'package:test/test.dart';
import 'package:app_ssh/src/sftp/sftp_statvfs.dart';
import 'package:app_ssh/src/sftp/sftp_packet_ext.dart';

void main() {
  group('SftpStatVfs', () {
    test('constructor sets all fields', () {
      final statvfs = SftpStatVfs(
        blockSize: 4096,
        fundamentalBlockSize: 4096,
        totalBlocks: 1000000,
        freeBlocks: 500000,
        freeBlocksForNonRoot: 450000,
        totalInodes: 100000,
        freeInodes: 50000,
        freeInodesForNonRoot: 45000,
        fileSystemId: 12345,
        isReadOnly: false,
        isNoSuid: false,
        maximumFilenameLength: 255,
      );

      expect(statvfs.blockSize, 4096);
      expect(statvfs.fundamentalBlockSize, 4096);
      expect(statvfs.totalBlocks, 1000000);
      expect(statvfs.freeBlocks, 500000);
      expect(statvfs.freeBlocksForNonRoot, 450000);
      expect(statvfs.totalInodes, 100000);
      expect(statvfs.freeInodes, 50000);
      expect(statvfs.freeInodesForNonRoot, 45000);
      expect(statvfs.fileSystemId, 12345);
      expect(statvfs.isReadOnly, false);
      expect(statvfs.isNoSuid, false);
      expect(statvfs.maximumFilenameLength, 255);
    });

    test('isReadOnly can be true', () {
      final statvfs = SftpStatVfs(
        blockSize: 4096,
        fundamentalBlockSize: 4096,
        totalBlocks: 1000000,
        freeBlocks: 0,
        freeBlocksForNonRoot: 0,
        totalInodes: 100000,
        freeInodes: 0,
        freeInodesForNonRoot: 0,
        fileSystemId: 67890,
        isReadOnly: true,
        isNoSuid: false,
        maximumFilenameLength: 255,
      );

      expect(statvfs.isReadOnly, true);
    });

    test('isNoSuid can be true', () {
      final statvfs = SftpStatVfs(
        blockSize: 4096,
        fundamentalBlockSize: 4096,
        totalBlocks: 1000000,
        freeBlocks: 500000,
        freeBlocksForNonRoot: 450000,
        totalInodes: 100000,
        freeInodes: 50000,
        freeInodesForNonRoot: 45000,
        fileSystemId: 12345,
        isReadOnly: false,
        isNoSuid: true,
        maximumFilenameLength: 255,
      );

      expect(statvfs.isNoSuid, true);
    });

    test('both flags can be true', () {
      final statvfs = SftpStatVfs(
        blockSize: 4096,
        fundamentalBlockSize: 4096,
        totalBlocks: 1000000,
        freeBlocks: 0,
        freeBlocksForNonRoot: 0,
        totalInodes: 100000,
        freeInodes: 0,
        freeInodesForNonRoot: 0,
        fileSystemId: 99999,
        isReadOnly: true,
        isNoSuid: true,
        maximumFilenameLength: 255,
      );

      expect(statvfs.isReadOnly, true);
      expect(statvfs.isNoSuid, true);
    });

    group('fromReply factory', () {
      test('parses reply with no flags', () {
        final reply = SftpStatVfsReply(
          blockSize: 4096,
          fundamentalBlockSize: 4096,
          totalBlocks: 2000000,
          freeBlocks: 1000000,
          freeBlocksForNonRoot: 900000,
          totalInodes: 200000,
          freeInodes: 100000,
          freeInodesForNonRoot: 90000,
          fileSystemId: 54321,
          flag: 0,
          maximumFilenameLength: 255,
        );

        final statvfs = SftpStatVfs.fromReply(reply);

        expect(statvfs.blockSize, 4096);
        expect(statvfs.totalBlocks, 2000000);
        expect(statvfs.freeBlocks, 1000000);
        expect(statvfs.fileSystemId, 54321);
        expect(statvfs.isReadOnly, false);
        expect(statvfs.isNoSuid, false);
      });

      test('parses reply with read-only flag', () {
        final reply = SftpStatVfsReply(
          blockSize: 4096,
          fundamentalBlockSize: 4096,
          totalBlocks: 2000000,
          freeBlocks: 0,
          freeBlocksForNonRoot: 0,
          totalInodes: 200000,
          freeInodes: 0,
          freeInodesForNonRoot: 0,
          fileSystemId: 54321,
          flag: 0x01, // read-only flag
          maximumFilenameLength: 255,
        );

        final statvfs = SftpStatVfs.fromReply(reply);

        expect(statvfs.isReadOnly, true);
        expect(statvfs.isNoSuid, false);
      });

      test('parses reply with nosuid flag', () {
        final reply = SftpStatVfsReply(
          blockSize: 4096,
          fundamentalBlockSize: 4096,
          totalBlocks: 2000000,
          freeBlocks: 1000000,
          freeBlocksForNonRoot: 900000,
          totalInodes: 200000,
          freeInodes: 100000,
          freeInodesForNonRoot: 90000,
          fileSystemId: 54321,
          flag: 0x02, // nosuid flag
          maximumFilenameLength: 255,
        );

        final statvfs = SftpStatVfs.fromReply(reply);

        expect(statvfs.isReadOnly, false);
        expect(statvfs.isNoSuid, true);
      });

      test('parses reply with both flags', () {
        final reply = SftpStatVfsReply(
          blockSize: 4096,
          fundamentalBlockSize: 4096,
          totalBlocks: 2000000,
          freeBlocks: 0,
          freeBlocksForNonRoot: 0,
          totalInodes: 200000,
          freeInodes: 0,
          freeInodesForNonRoot: 0,
          fileSystemId: 54321,
          flag: 0x03, // both flags
          maximumFilenameLength: 255,
        );

        final statvfs = SftpStatVfs.fromReply(reply);

        expect(statvfs.isReadOnly, true);
        expect(statvfs.isNoSuid, true);
      });

      test('copies all fields from reply', () {
        final reply = SftpStatVfsReply(
          blockSize: 512,
          fundamentalBlockSize: 1024,
          totalBlocks: 5000000,
          freeBlocks: 2500000,
          freeBlocksForNonRoot: 2000000,
          totalInodes: 500000,
          freeInodes: 250000,
          freeInodesForNonRoot: 200000,
          fileSystemId: 98765,
          flag: 0,
          maximumFilenameLength: 1024,
        );

        final statvfs = SftpStatVfs.fromReply(reply);

        expect(statvfs.blockSize, reply.blockSize);
        expect(statvfs.fundamentalBlockSize, reply.fundamentalBlockSize);
        expect(statvfs.totalBlocks, reply.totalBlocks);
        expect(statvfs.freeBlocks, reply.freeBlocks);
        expect(statvfs.freeBlocksForNonRoot, reply.freeBlocksForNonRoot);
        expect(statvfs.totalInodes, reply.totalInodes);
        expect(statvfs.freeInodes, reply.freeInodes);
        expect(statvfs.freeInodesForNonRoot, reply.freeInodesForNonRoot);
        expect(statvfs.fileSystemId, reply.fileSystemId);
        expect(statvfs.maximumFilenameLength, reply.maximumFilenameLength);
      });
    });

    test('toString includes all fields', () {
      final statvfs = SftpStatVfs(
        blockSize: 4096,
        fundamentalBlockSize: 4096,
        totalBlocks: 1000000,
        freeBlocks: 500000,
        freeBlocksForNonRoot: 450000,
        totalInodes: 100000,
        freeInodes: 50000,
        freeInodesForNonRoot: 45000,
        fileSystemId: 12345,
        isReadOnly: false,
        isNoSuid: true,
        maximumFilenameLength: 255,
      );

      final str = statvfs.toString();

      expect(str, contains('SftpStatVfs'));
      expect(str, contains('blockSize: 4096'));
      expect(str, contains('totalBlocks: 1000000'));
      expect(str, contains('freeBlocks: 500000'));
      expect(str, contains('isReadOnly: false'));
      expect(str, contains('isNoSuid: true'));
      expect(str, contains('maximumFilenameLength: 255'));
    });

    group('edge cases', () {
      test('handles zero values', () {
        final statvfs = SftpStatVfs(
          blockSize: 0,
          fundamentalBlockSize: 0,
          totalBlocks: 0,
          freeBlocks: 0,
          freeBlocksForNonRoot: 0,
          totalInodes: 0,
          freeInodes: 0,
          freeInodesForNonRoot: 0,
          fileSystemId: 0,
          isReadOnly: false,
          isNoSuid: false,
          maximumFilenameLength: 0,
        );

        expect(statvfs.blockSize, 0);
        expect(statvfs.totalBlocks, 0);
        expect(statvfs.maximumFilenameLength, 0);
      });

      test('handles large values', () {
        final statvfs = SftpStatVfs(
          blockSize: 65536,
          fundamentalBlockSize: 65536,
          totalBlocks: 0x7FFFFFFFFFFFFFFF,
          freeBlocks: 0x7FFFFFFFFFFFFFFF,
          freeBlocksForNonRoot: 0x7FFFFFFFFFFFFFFF,
          totalInodes: 0x7FFFFFFFFFFFFFFF,
          freeInodes: 0x7FFFFFFFFFFFFFFF,
          freeInodesForNonRoot: 0x7FFFFFFFFFFFFFFF,
          fileSystemId: 0xFFFFFFFF,
          isReadOnly: false,
          isNoSuid: false,
          maximumFilenameLength: 65535,
        );

        expect(statvfs.totalBlocks, 0x7FFFFFFFFFFFFFFF);
      });
    });

    group('typical scenarios', () {
      test('typical ext4 filesystem', () {
        final statvfs = SftpStatVfs(
          blockSize: 4096,
          fundamentalBlockSize: 4096,
          totalBlocks: 244190646,
          freeBlocks: 122095323,
          freeBlocksForNonRoot: 109885791,
          totalInodes: 61054976,
          freeInodes: 59876543,
          freeInodesForNonRoot: 59876543,
          fileSystemId: 0xDEADBEEF,
          isReadOnly: false,
          isNoSuid: false,
          maximumFilenameLength: 255,
        );

        // About 50% free space
        expect(statvfs.freeBlocks, greaterThan(statvfs.totalBlocks ~/ 3));
        expect(statvfs.freeBlocks, lessThan(statvfs.totalBlocks));
      });

      test('read-only mounted filesystem', () {
        final statvfs = SftpStatVfs(
          blockSize: 2048,
          fundamentalBlockSize: 2048,
          totalBlocks: 1000000,
          freeBlocks: 0,
          freeBlocksForNonRoot: 0,
          totalInodes: 100000,
          freeInodes: 50000,
          freeInodesForNonRoot: 50000,
          fileSystemId: 0x12345678,
          isReadOnly: true,
          isNoSuid: true,
          maximumFilenameLength: 255,
        );

        expect(statvfs.isReadOnly, true);
        expect(statvfs.freeBlocks, 0);
      });
    });
  });
}
