import 'dart:async';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';
import 'package:app_ssh/src/message/msg_channel.dart';
import 'package:app_ssh/src/sftp/sftp_packet.dart';
import 'package:app_ssh/src/ssh_channel.dart';
import 'package:app_ssh/src/ssh_message.dart';
import 'package:test/test.dart';

SSHChannelController channel(int id, List<SSHMessage> messages) =>
    SSHChannelController(
      localId: id,
      remoteId: id + 10,
      localMaximumPacketSize: 32768,
      localInitialWindowSize: 32768,
      remoteMaximumPacketSize: 32768,
      remoteInitialWindowSize: 32768,
      sendMessage: messages.add,
    );

void version(SSHChannelController controller) {
  final payload = SftpVersionPacket(3).encode();
  final writer = SSHMessageWriter()
    ..writeUint32(payload.length)
    ..writeBytes(payload);
  controller.handleMessage(SSH_Message_Channel_Data(
    recipientChannel: controller.localId,
    data: writer.takeBytes(),
  ));
}

class _ErrorChannel implements SSHChannel {
  final input = StreamController<SSHChannelData>();
  int closes = 0;
  @override
  Stream<SSHChannelData> get stream => input.stream;
  @override
  void addData(Uint8List data, {int? type}) {}
  @override
  void destroy() {
    closes++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('channel errors settle handshake and close the channel once', () async {
    final channel = _ErrorChannel();
    final sftp = SftpClient(channel);
    final failed = expectLater(sftp.handshake, throwsStateError);
    channel.input.addError(StateError('fixture stream failure'));
    await failed.timeout(const Duration(seconds: 1));
    sftp.close();
    await channel.input.close();
    expect(channel.closes, 1);
  });

  test('remote EOF aborts pending requests', () async {
    final controller = channel(1, <SSHMessage>[]);
    final sftp = SftpClient(controller.channel);
    addTearDown(controller.destroy);
    version(controller);
    await sftp.handshake;
    final aborted =
        expectLater(sftp.stat('/pending'), throwsA(isA<SftpAbortError>()));
    await Future<void>.delayed(Duration.zero);
    controller.handleMessage(SSH_Message_Channel_EOF(recipientChannel: 1));
    await aborted.timeout(const Duration(seconds: 1));
  });

  test('repeated close aborts requests, closes only SFTP, preserves sibling',
      () async {
    final messages = <SSHMessage>[];
    final first = channel(1, messages);
    final second = channel(2, messages);
    final sftp = SftpClient(first.channel);
    final sibling = SSHSession(second.channel);
    addTearDown(() {
      first.destroy();
      second.destroy();
    });
    version(first);
    await sftp.handshake;
    final pending =
        expectLater(sftp.stat('/pending'), throwsA(isA<SftpAbortError>()));
    await Future<void>.delayed(Duration.zero);
    sftp.close();
    expect(sftp.close, returnsNormally);
    await pending.timeout(const Duration(seconds: 1));
    expect(
        messages
            .whereType<SSH_Message_Channel_Close>()
            .map((m) => m.recipientChannel),
        [11]);
    await expectLater(sftp.stat('/closed').timeout(const Duration(seconds: 1)),
        throwsA(isA<SftpAbortError>()));
    final output = sibling.stdout.first;
    second.handleMessage(SSH_Message_Channel_Data(
        recipientChannel: 2, data: Uint8List.fromList([42])));
    expect(await output, [42]);
    sibling.stdin.add(Uint8List.fromList([43]));
    await Future<void>.delayed(Duration.zero);
    expect(
        messages
            .whereType<SSH_Message_Channel_Data>()
            .where((m) => m.recipientChannel == 12),
        hasLength(1));
  });

  test('remote close settles an unfinished handshake', () async {
    final messages = <SSHMessage>[];
    final controller = channel(1, messages);
    final sftp = SftpClient(controller.channel);
    addTearDown(controller.destroy);
    final aborted = expectLater(
        sftp.handshake.timeout(const Duration(seconds: 1)),
        throwsA(isA<SftpAbortError>()));
    controller.handleMessage(SSH_Message_Channel_Close(recipientChannel: 1));
    await aborted;
  });

  test('local close settles an unfinished handshake', () async {
    final controller = channel(1, <SSHMessage>[]);
    final sftp = SftpClient(controller.channel);
    addTearDown(controller.destroy);
    final aborted = expectLater(
        sftp.handshake.timeout(const Duration(seconds: 1)),
        throwsA(isA<SftpAbortError>()));
    sftp.close();
    await aborted;
  });
}
