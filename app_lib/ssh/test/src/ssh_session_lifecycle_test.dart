import 'dart:async';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';
import 'package:app_ssh/src/message/msg_channel.dart';
import 'package:app_ssh/src/ssh_channel.dart';
import 'package:app_ssh/src/ssh_message.dart';
import 'package:test/test.dart';

SSHChannelController channel(int id, List<SSHMessage> messages) {
  return SSHChannelController(
    localId: id,
    remoteId: id + 10,
    localMaximumPacketSize: 32768,
    localInitialWindowSize: 32768,
    remoteMaximumPacketSize: 32768,
    remoteInitialWindowSize: 32768,
    sendMessage: messages.add,
  );
}

void main() {
  test('cancel sends channel close once and leaves the sibling usable',
      () async {
    final messages = <SSHMessage>[];
    final firstChannel = channel(1, messages);
    final siblingChannel = channel(2, messages);
    final first = SSHSession(firstChannel.channel);
    final sibling = SSHSession(siblingChannel.channel);
    addTearDown(() {
      firstChannel.destroy();
      siblingChannel.destroy();
    });

    first.close();
    first.close();
    expect(
        messages.whereType<SSH_Message_Channel_Close>().map(
              (message) => message.recipientChannel,
            ),
        [11]);
    await first.done.timeout(const Duration(seconds: 1));

    final output = sibling.stdout.first;
    siblingChannel.handleMessage(SSH_Message_Channel_Data(
      recipientChannel: 2,
      data: Uint8List.fromList([42]),
    ));
    expect(await output, [42]);
    sibling.stdin.add(Uint8List.fromList([43]));
    await Future<void>.delayed(Duration.zero);
    expect(
        messages.whereType<SSH_Message_Channel_Data>().single.recipientChannel,
        12);
  });

  test(
      'closing stdin sends EOF and still receives final output and exit status',
      () async {
    final messages = <SSHMessage>[];
    final controller = channel(1, messages);
    final session = SSHSession(controller.channel);
    addTearDown(controller.destroy);
    final output = session.stdout.expand((data) => data).toList();
    unawaited(session.stdin.close());
    await Future<void>.delayed(Duration.zero);
    expect(messages.whereType<SSH_Message_Channel_EOF>(), hasLength(1));
    expect(messages.whereType<SSH_Message_Channel_Close>(), isEmpty);
    controller.handleMessage(SSH_Message_Channel_Data(
      recipientChannel: 1,
      data: Uint8List.fromList([42]),
    ));
    controller.handleMessage(SSH_Message_Channel_Request.exitStatus(
      recipientChannel: 1,
      exitStatus: 7,
    ));
    controller.handleMessage(SSH_Message_Channel_Close(recipientChannel: 1));
    await session.done;
    expect(await output, [42]);
    expect(session.exitCode, 7);
  });
}
