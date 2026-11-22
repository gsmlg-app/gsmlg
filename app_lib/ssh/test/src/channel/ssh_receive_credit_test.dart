import 'dart:async';
import 'dart:typed_data';

import 'package:app_ssh/src/message/msg_channel.dart';
import 'package:app_ssh/src/ssh_channel.dart';
import 'package:app_ssh/src/ssh_errors.dart';
import 'package:app_ssh/src/ssh_message.dart';
import 'package:app_ssh/src/ssh_session.dart';
import 'package:test/test.dart';

SSHChannelController _controller(List<SSHMessage> sent,
        {int id = 1, bool manual = true}) =>
    SSHChannelController(
      localId: id,
      localMaximumPacketSize: 4,
      localInitialWindowSize: 8,
      remoteId: id * 10,
      remoteInitialWindowSize: 0,
      remoteMaximumPacketSize: 4,
      sendMessage: sent.add,
      manualReceiveCredit: manual,
    );

void _peerData(SSHChannelController controller, List<int> bytes,
    {int? extendedType}) {
  final data = Uint8List.fromList(bytes);
  controller.handleMessage(extendedType == null
      ? SSH_Message_Channel_Data(
          recipientChannel: controller.localId, data: data)
      : SSH_Message_Channel_Extended_Data(
          recipientChannel: controller.localId,
          dataTypeCode: extendedType,
          data: data,
        ));
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('manual window at zero stays there until real byte credit is posted',
      () async {
    final sent = <SSHMessage>[];
    final checked = _controller(sent);
    final session = SSHSession(checked.channel);
    final stdout = <int>[];
    final stderr = <int>[];
    final out = session.stdout.listen(stdout.addAll);
    final err = session.stderr.listen(stderr.addAll);
    _peerData(checked, [1, 2, 3, 4]);
    _peerData(checked, [5, 6, 7, 8], extendedType: 1);
    await _settle();
    expect(stdout, [1, 2, 3, 4]);
    expect(stderr, [5, 6, 7, 8]);
    expect(sent.whereType<SSH_Message_Channel_Window_Adjust>(), isEmpty);
    out.pause();
    out.resume();
    await _settle();
    expect(sent.whereType<SSH_Message_Channel_Window_Adjust>(), isEmpty);

    session.acknowledgeReceivedBytes(4);
    expect(
        sent.whereType<SSH_Message_Channel_Window_Adjust>().single.bytesToAdd,
        4);
    _peerData(checked, [9, 10, 11, 12]);
    await _settle();
    expect(stdout, [1, 2, 3, 4, 9, 10, 11, 12]);
    session.acknowledgeReceivedBytes(8);
    expect(() => session.acknowledgeReceivedBytes(1), throwsArgumentError);
    expect(
        sent
            .whereType<SSH_Message_Channel_Window_Adjust>()
            .map((message) => message.bytesToAdd),
        [4, 8]);
    session.close();
    await session.done;
    await out.cancel();
    await err.cancel();
  });

  test('manual receive failure closes only that channel', () async {
    final sent = <SSHMessage>[];
    final bad = _controller(sent, id: 1);
    final other = _controller(sent, id: 2, manual: false);
    final badSession = SSHSession(bad.channel);
    final otherSession = SSHSession(other.channel);
    final reported = Completer<Object>();
    final received = <int>[];
    final badOutput =
        badSession.stdout.listen((_) {}, onError: reported.complete);
    final otherOutput = otherSession.stdout.listen(received.addAll);
    _peerData(bad, [1, 2, 3, 4, 5]); // One byte above the fixture packet limit.
    _peerData(other, [6, 7]);
    expect(await reported.future, isA<SSHStateError>());
    await badSession.done;
    await _settle();
    expect(received, [6, 7]);
    expect(sent.whereType<SSH_Message_Channel_Close>().single.recipientChannel,
        10);
    expect(
        sent
            .whereType<SSH_Message_Channel_Window_Adjust>()
            .single
            .recipientChannel,
        20);
    otherSession.close();
    await badOutput.cancel();
    await otherOutput.cancel();
  });
}
