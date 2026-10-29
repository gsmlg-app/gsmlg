import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:app_ssh/src/message/msg_channel.dart';

void main() {
  group('SSH_Message_Channel_Open', () {
    test('has correct messageId', () {
      expect(SSH_Message_Channel_Open.messageId, 90);
    });

    group('session channel', () {
      test('session factory creates correct type', () {
        final msg = SSH_Message_Channel_Open.session(
          senderChannel: 1,
          initialWindowSize: 1048576,
          maximumPacketSize: 32768,
        );
        expect(msg.channelType, 'session');
        expect(msg.senderChannel, 1);
        expect(msg.initialWindowSize, 1048576);
        expect(msg.maximumPacketSize, 32768);
      });

      test('encodes and decodes session channel', () {
        final original = SSH_Message_Channel_Open.session(
          senderChannel: 42,
          initialWindowSize: 2097152,
          maximumPacketSize: 16384,
        );
        final encoded = original.encode();
        final decoded = SSH_Message_Channel_Open.decode(encoded);

        expect(decoded.channelType, 'session');
        expect(decoded.senderChannel, 42);
        expect(decoded.initialWindowSize, 2097152);
        expect(decoded.maximumPacketSize, 16384);
      });
    });

    group('x11 channel', () {
      test('x11 factory creates correct type', () {
        final msg = SSH_Message_Channel_Open.x11(
          senderChannel: 2,
          initialWindowSize: 1048576,
          maximumPacketSize: 32768,
          originatorIP: '192.168.1.100',
          originatorPort: 6010,
        );
        expect(msg.channelType, 'x11');
        expect(msg.originatorIP, '192.168.1.100');
        expect(msg.originatorPort, 6010);
      });

      test('encodes and decodes x11 channel', () {
        final original = SSH_Message_Channel_Open.x11(
          senderChannel: 3,
          initialWindowSize: 1048576,
          maximumPacketSize: 32768,
          originatorIP: '10.0.0.1',
          originatorPort: 6000,
        );
        final encoded = original.encode();
        final decoded = SSH_Message_Channel_Open.decode(encoded);

        expect(decoded.channelType, 'x11');
        expect(decoded.originatorIP, '10.0.0.1');
        expect(decoded.originatorPort, 6000);
      });
    });

    group('forwarded-tcpip channel', () {
      test('forwardedTcpip factory creates correct type', () {
        final msg = SSH_Message_Channel_Open.forwardedTcpip(
          senderChannel: 4,
          initialWindowSize: 1048576,
          maximumPacketSize: 32768,
          host: 'example.com',
          port: 80,
          originatorIP: '192.168.1.1',
          originatorPort: 54321,
        );
        expect(msg.channelType, 'forwarded-tcpip');
        expect(msg.host, 'example.com');
        expect(msg.port, 80);
      });

      test('encodes and decodes forwarded-tcpip channel', () {
        final original = SSH_Message_Channel_Open.forwardedTcpip(
          senderChannel: 5,
          initialWindowSize: 1048576,
          maximumPacketSize: 32768,
          host: 'localhost',
          port: 8080,
          originatorIP: '127.0.0.1',
          originatorPort: 12345,
        );
        final encoded = original.encode();
        final decoded = SSH_Message_Channel_Open.decode(encoded);

        expect(decoded.channelType, 'forwarded-tcpip');
        expect(decoded.host, 'localhost');
        expect(decoded.port, 8080);
        expect(decoded.originatorIP, '127.0.0.1');
        expect(decoded.originatorPort, 12345);
      });
    });

    group('direct-tcpip channel', () {
      test('directTcpip factory creates correct type', () {
        final msg = SSH_Message_Channel_Open.directTcpip(
          senderChannel: 6,
          initialWindowSize: 1048576,
          maximumPacketSize: 32768,
          host: 'database.internal',
          port: 5432,
          originatorIP: '10.0.0.50',
          originatorPort: 33333,
        );
        expect(msg.channelType, 'direct-tcpip');
        expect(msg.host, 'database.internal');
        expect(msg.port, 5432);
      });

      test('encodes and decodes direct-tcpip channel', () {
        final original = SSH_Message_Channel_Open.directTcpip(
          senderChannel: 7,
          initialWindowSize: 2097152,
          maximumPacketSize: 65535,
          host: 'redis.internal',
          port: 6379,
          originatorIP: '192.168.0.1',
          originatorPort: 44444,
        );
        final encoded = original.encode();
        final decoded = SSH_Message_Channel_Open.decode(encoded);

        expect(decoded.channelType, 'direct-tcpip');
        expect(decoded.host, 'redis.internal');
        expect(decoded.port, 6379);
        expect(decoded.originatorIP, '192.168.0.1');
        expect(decoded.originatorPort, 44444);
      });
    });

    group('unknown channel type', () {
      test('handles unknown channel type gracefully', () {
        final msg = SSH_Message_Channel_Open(
          channelType: 'custom-channel',
          senderChannel: 100,
          initialWindowSize: 1048576,
          maximumPacketSize: 32768,
        );
        final encoded = msg.encode();
        final decoded = SSH_Message_Channel_Open.decode(encoded);

        expect(decoded.channelType, 'custom-channel');
        expect(decoded.senderChannel, 100);
      });
    });

    group('encode', () {
      test('first byte is message id', () {
        final msg = SSH_Message_Channel_Open.session(
          senderChannel: 0,
          initialWindowSize: 1024,
          maximumPacketSize: 512,
        );
        final encoded = msg.encode();
        expect(encoded[0], SSH_Message_Channel_Open.messageId);
      });
    });

    group('toString', () {
      test('session toString includes channel type', () {
        final msg = SSH_Message_Channel_Open.session(
          senderChannel: 1,
          initialWindowSize: 1024,
          maximumPacketSize: 512,
        );
        expect(msg.toString(), contains('SSH_Message_Channel_Open'));
        expect(msg.toString(), contains('session'));
      });

      test('direct-tcpip toString includes host and port', () {
        final msg = SSH_Message_Channel_Open.directTcpip(
          senderChannel: 1,
          initialWindowSize: 1024,
          maximumPacketSize: 512,
          host: 'myhost',
          port: 1234,
          originatorIP: '127.0.0.1',
          originatorPort: 5678,
        );
        expect(msg.toString(), contains('myhost'));
        expect(msg.toString(), contains('1234'));
      });
    });
  });

  group('SSH_Message_Channel_Confirmation', () {
    test('has correct messageId', () {
      expect(SSH_Message_Channel_Confirmation.messageId, 91);
    });

    test('constructor sets all fields', () {
      final msg = SSH_Message_Channel_Confirmation(
        recipientChannel: 1,
        senderChannel: 2,
        initialWindowSize: 1048576,
        maximumPacketSize: 32768,
        data: Uint8List.fromList([1, 2, 3]),
      );
      expect(msg.recipientChannel, 1);
      expect(msg.senderChannel, 2);
      expect(msg.initialWindowSize, 1048576);
      expect(msg.maximumPacketSize, 32768);
      expect(msg.data, [1, 2, 3]);
    });

    test('encodes and decodes', () {
      final original = SSH_Message_Channel_Confirmation(
        recipientChannel: 10,
        senderChannel: 20,
        initialWindowSize: 2097152,
        maximumPacketSize: 65535,
        data: Uint8List.fromList([4, 5, 6, 7, 8]),
      );
      final encoded = original.encode();
      final decoded = SSH_Message_Channel_Confirmation.decode(encoded);

      expect(decoded.recipientChannel, 10);
      expect(decoded.senderChannel, 20);
      expect(decoded.initialWindowSize, 2097152);
      expect(decoded.maximumPacketSize, 65535);
      expect(decoded.data, [4, 5, 6, 7, 8]);
    });

    test('encodes and decodes empty data', () {
      final original = SSH_Message_Channel_Confirmation(
        recipientChannel: 0,
        senderChannel: 0,
        initialWindowSize: 0,
        maximumPacketSize: 0,
        data: Uint8List(0),
      );
      final decoded =
          SSH_Message_Channel_Confirmation.decode(original.encode());
      expect(decoded.data.isEmpty, true);
    });

    test('toString includes channel numbers', () {
      final msg = SSH_Message_Channel_Confirmation(
        recipientChannel: 5,
        senderChannel: 10,
        initialWindowSize: 1024,
        maximumPacketSize: 512,
        data: Uint8List(0),
      );
      expect(msg.toString(), contains('SSH_Message_Channel_Confirmation'));
      expect(msg.toString(), contains('5'));
      expect(msg.toString(), contains('10'));
    });
  });

  group('SSH_Message_Channel_Open_Failure', () {
    test('has correct messageId', () {
      expect(SSH_Message_Channel_Open_Failure.messageId, 92);
    });

    test('has correct reason codes', () {
      expect(
          SSH_Message_Channel_Open_Failure.codeAdministrativelyProhibited, 1);
      expect(SSH_Message_Channel_Open_Failure.codeConnectFailed, 2);
      expect(SSH_Message_Channel_Open_Failure.codeUnknownChannelType, 3);
      expect(SSH_Message_Channel_Open_Failure.codeResourceShortage, 4);
    });

    test('constructor sets all fields', () {
      final msg = SSH_Message_Channel_Open_Failure(
        recipientChannel: 5,
        reasonCode: SSH_Message_Channel_Open_Failure.codeConnectFailed,
        description: 'Connection refused',
        languageTag: 'en',
      );
      expect(msg.recipientChannel, 5);
      expect(msg.reasonCode, 2);
      expect(msg.description, 'Connection refused');
      expect(msg.languageTag, 'en');
    });

    test('languageTag defaults to empty', () {
      final msg = SSH_Message_Channel_Open_Failure(
        recipientChannel: 1,
        reasonCode: 1,
        description: 'test',
      );
      expect(msg.languageTag, '');
    });

    test('encodes and decodes', () {
      final original = SSH_Message_Channel_Open_Failure(
        recipientChannel: 42,
        reasonCode: SSH_Message_Channel_Open_Failure.codeUnknownChannelType,
        description: 'Unknown channel type: custom',
        languageTag: 'en-US',
      );
      final decoded =
          SSH_Message_Channel_Open_Failure.decode(original.encode());

      expect(decoded.recipientChannel, 42);
      expect(decoded.reasonCode, 3);
      expect(decoded.description, 'Unknown channel type: custom');
      expect(decoded.languageTag, 'en-US');
    });

    test('toString includes description', () {
      final msg = SSH_Message_Channel_Open_Failure(
        recipientChannel: 1,
        reasonCode: 1,
        description: 'Access denied',
      );
      expect(msg.toString(), contains('SSH_Message_Channel_Open_Failure'));
      expect(msg.toString(), contains('Access denied'));
    });
  });

  group('SSH_Message_Channel_Window_Adjust', () {
    test('has correct messageId', () {
      expect(SSH_Message_Channel_Window_Adjust.messageId, 93);
    });

    test('constructor sets all fields', () {
      final msg = SSH_Message_Channel_Window_Adjust(
        recipientChannel: 10,
        bytesToAdd: 1048576,
      );
      expect(msg.recipientChannel, 10);
      expect(msg.bytesToAdd, 1048576);
    });

    test('encodes and decodes', () {
      final original = SSH_Message_Channel_Window_Adjust(
        recipientChannel: 99,
        bytesToAdd: 2097152,
      );
      final decoded =
          SSH_Message_Channel_Window_Adjust.decode(original.encode());

      expect(decoded.recipientChannel, 99);
      expect(decoded.bytesToAdd, 2097152);
    });

    test('handles large window size', () {
      final original = SSH_Message_Channel_Window_Adjust(
        recipientChannel: 0,
        bytesToAdd: 0xFFFFFFFF, // Max uint32
      );
      final decoded =
          SSH_Message_Channel_Window_Adjust.decode(original.encode());
      expect(decoded.bytesToAdd, 0xFFFFFFFF);
    });

    test('toString includes bytes to add', () {
      final msg = SSH_Message_Channel_Window_Adjust(
        recipientChannel: 1,
        bytesToAdd: 12345,
      );
      expect(msg.toString(), contains('SSH_Message_Channel_Window_Adjust'));
      expect(msg.toString(), contains('12345'));
    });
  });

  group('SSH_Message_Channel_Data', () {
    test('has correct messageId', () {
      expect(SSH_Message_Channel_Data.messageId, 94);
    });

    test('constructor sets all fields', () {
      final msg = SSH_Message_Channel_Data(
        recipientChannel: 7,
        data: Uint8List.fromList([1, 2, 3, 4, 5]),
      );
      expect(msg.recipientChannel, 7);
      expect(msg.data, [1, 2, 3, 4, 5]);
    });

    test('encodes and decodes', () {
      final testData = Uint8List.fromList('Hello, SSH!'.codeUnits);
      final original = SSH_Message_Channel_Data(
        recipientChannel: 15,
        data: testData,
      );
      final decoded = SSH_Message_Channel_Data.decode(original.encode());

      expect(decoded.recipientChannel, 15);
      expect(String.fromCharCodes(decoded.data), 'Hello, SSH!');
    });

    test('handles empty data', () {
      final original = SSH_Message_Channel_Data(
        recipientChannel: 0,
        data: Uint8List(0),
      );
      final decoded = SSH_Message_Channel_Data.decode(original.encode());
      expect(decoded.data.isEmpty, true);
    });

    test('handles large data', () {
      final largeData =
          Uint8List.fromList(List.generate(10000, (i) => i % 256));
      final original = SSH_Message_Channel_Data(
        recipientChannel: 1,
        data: largeData,
      );
      final decoded = SSH_Message_Channel_Data.decode(original.encode());
      expect(decoded.data.length, 10000);
      expect(decoded.data, original.data);
    });

    test('toString includes data length', () {
      final msg = SSH_Message_Channel_Data(
        recipientChannel: 1,
        data: Uint8List(100),
      );
      expect(msg.toString(), contains('SSH_Message_Channel_Data'));
      expect(msg.toString(), contains('100'));
    });
  });

  group('SSH_Message_Channel_Extended_Data', () {
    test('has correct messageId', () {
      expect(SSH_Message_Channel_Extended_Data.messageId, 95);
    });

    test('has correct data type constant', () {
      expect(SSH_Message_Channel_Extended_Data.dataTypeStderr, 1);
    });

    test('constructor sets all fields', () {
      final msg = SSH_Message_Channel_Extended_Data(
        recipientChannel: 3,
        dataTypeCode: SSH_Message_Channel_Extended_Data.dataTypeStderr,
        data: Uint8List.fromList('Error message'.codeUnits),
      );
      expect(msg.recipientChannel, 3);
      expect(msg.dataTypeCode, 1);
      expect(String.fromCharCodes(msg.data), 'Error message');
    });

    test('encodes and decodes', () {
      final original = SSH_Message_Channel_Extended_Data(
        recipientChannel: 25,
        dataTypeCode: 1,
        data: Uint8List.fromList('stderr output'.codeUnits),
      );
      final decoded =
          SSH_Message_Channel_Extended_Data.decode(original.encode());

      expect(decoded.recipientChannel, 25);
      expect(decoded.dataTypeCode, 1);
      expect(String.fromCharCodes(decoded.data), 'stderr output');
    });

    test('toString includes data type code', () {
      final msg = SSH_Message_Channel_Extended_Data(
        recipientChannel: 1,
        dataTypeCode: 1,
        data: Uint8List(50),
      );
      expect(msg.toString(), contains('SSH_Message_Channel_Extended_Data'));
      expect(msg.toString(), contains('dataTypeCode: 1'));
    });
  });

  group('SSH_Message_Channel_EOF', () {
    test('has correct messageId', () {
      expect(SSH_Message_Channel_EOF.messageId, 96);
    });

    test('constructor sets channel', () {
      final msg = SSH_Message_Channel_EOF(recipientChannel: 42);
      expect(msg.recipientChannel, 42);
    });

    test('encodes and decodes', () {
      final original = SSH_Message_Channel_EOF(recipientChannel: 100);
      final decoded = SSH_Message_Channel_EOF.decode(original.encode());
      expect(decoded.recipientChannel, 100);
    });

    test('toString includes channel', () {
      final msg = SSH_Message_Channel_EOF(recipientChannel: 55);
      expect(msg.toString(), contains('SSH_Message_Channel_EOF'));
      expect(msg.toString(), contains('55'));
    });
  });

  group('SSH_Message_Channel_Close', () {
    test('has correct messageId', () {
      expect(SSH_Message_Channel_Close.messageId, 97);
    });

    test('constructor sets channel', () {
      final msg = SSH_Message_Channel_Close(recipientChannel: 33);
      expect(msg.recipientChannel, 33);
    });

    test('encodes and decodes', () {
      final original = SSH_Message_Channel_Close(recipientChannel: 77);
      final decoded = SSH_Message_Channel_Close.decode(original.encode());
      expect(decoded.recipientChannel, 77);
    });

    test('toString includes channel', () {
      final msg = SSH_Message_Channel_Close(recipientChannel: 88);
      expect(msg.toString(), contains('SSH_Message_Channel_Close'));
      expect(msg.toString(), contains('88'));
    });
  });

  group('SSHChannelRequestType', () {
    test('has correct constants', () {
      expect(SSHChannelRequestType.pty, 'pty-req');
      expect(SSHChannelRequestType.x11, 'x11-req');
      expect(SSHChannelRequestType.env, 'env');
      expect(SSHChannelRequestType.shell, 'shell');
      expect(SSHChannelRequestType.exec, 'exec');
      expect(SSHChannelRequestType.subsystem, 'subsystem');
      expect(SSHChannelRequestType.windowChange, 'window-change');
      expect(SSHChannelRequestType.xon, 'xon-xoff');
      expect(SSHChannelRequestType.signal, 'signal');
      expect(SSHChannelRequestType.exitStatus, 'exit-status');
      expect(SSHChannelRequestType.exitSignal, 'exit-signal');
    });
  });

  group('SSH_Message_Channel_Request', () {
    test('has correct messageId', () {
      expect(SSH_Message_Channel_Request.messageId, 98);
    });

    group('pty request', () {
      test('pty factory creates correct request', () {
        final msg = SSH_Message_Channel_Request.pty(
          recipientChannel: 1,
          wantReply: true,
          termType: 'xterm-256color',
          termWidth: 80,
          termHeight: 24,
          termPixelWidth: 640,
          termPixelHeight: 480,
          termModes: Uint8List.fromList([0]),
        );
        expect(msg.requestType, 'pty-req');
        expect(msg.termType, 'xterm-256color');
        expect(msg.termWidth, 80);
        expect(msg.termHeight, 24);
      });

      test('encodes and decodes pty request', () {
        final original = SSH_Message_Channel_Request.pty(
          recipientChannel: 5,
          wantReply: false,
          termType: 'vt100',
          termWidth: 120,
          termHeight: 40,
          termPixelWidth: 800,
          termPixelHeight: 600,
          termModes: Uint8List.fromList([0, 1, 2]),
        );
        final decoded = SSH_Message_Channel_Request.decode(original.encode());

        expect(decoded.requestType, 'pty-req');
        expect(decoded.termType, 'vt100');
        expect(decoded.termWidth, 120);
        expect(decoded.termHeight, 40);
        expect(decoded.termPixelWidth, 800);
        expect(decoded.termPixelHeight, 600);
      });
    });

    group('shell request', () {
      test('shell factory creates correct request', () {
        final msg = SSH_Message_Channel_Request.shell(
          recipientChannel: 2,
          wantReply: true,
        );
        expect(msg.requestType, 'shell');
        expect(msg.wantReply, true);
      });

      test('encodes and decodes shell request', () {
        final original = SSH_Message_Channel_Request.shell(
          recipientChannel: 10,
          wantReply: false,
        );
        final decoded = SSH_Message_Channel_Request.decode(original.encode());

        expect(decoded.requestType, 'shell');
        expect(decoded.recipientChannel, 10);
        expect(decoded.wantReply, false);
      });
    });

    group('exec request', () {
      test('exec factory creates correct request', () {
        final msg = SSH_Message_Channel_Request.exec(
          recipientChannel: 3,
          wantReply: true,
          command: 'ls -la',
        );
        expect(msg.requestType, 'exec');
        expect(msg.command, 'ls -la');
      });

      test('encodes and decodes exec request', () {
        final original = SSH_Message_Channel_Request.exec(
          recipientChannel: 7,
          wantReply: true,
          command: 'cat /etc/passwd',
        );
        final decoded = SSH_Message_Channel_Request.decode(original.encode());

        expect(decoded.requestType, 'exec');
        expect(decoded.command, 'cat /etc/passwd');
      });
    });

    group('subsystem request', () {
      test('subsystem factory creates correct request', () {
        final msg = SSH_Message_Channel_Request.subsystem(
          recipientChannel: 4,
          wantReply: true,
          subsystemName: 'sftp',
        );
        expect(msg.requestType, 'subsystem');
        expect(msg.subsystemName, 'sftp');
      });

      test('encodes and decodes subsystem request', () {
        final original = SSH_Message_Channel_Request.subsystem(
          recipientChannel: 8,
          wantReply: true,
          subsystemName: 'netconf',
        );
        final decoded = SSH_Message_Channel_Request.decode(original.encode());

        expect(decoded.requestType, 'subsystem');
        expect(decoded.subsystemName, 'netconf');
      });
    });

    group('env request', () {
      test('env factory creates correct request', () {
        final msg = SSH_Message_Channel_Request.env(
          recipientChannel: 5,
          wantReply: false,
          variableName: 'LANG',
          variableValue: 'en_US.UTF-8',
        );
        expect(msg.requestType, 'env');
        expect(msg.variableName, 'LANG');
        expect(msg.variableValue, 'en_US.UTF-8');
      });

      test('encodes and decodes env request', () {
        final original = SSH_Message_Channel_Request.env(
          recipientChannel: 9,
          variableName: 'PATH',
          variableValue: '/usr/bin:/bin',
        );
        final decoded = SSH_Message_Channel_Request.decode(original.encode());

        expect(decoded.requestType, 'env');
        expect(decoded.variableName, 'PATH');
        expect(decoded.variableValue, '/usr/bin:/bin');
      });
    });

    group('window-change request', () {
      test('windowChange factory creates correct request', () {
        final msg = SSH_Message_Channel_Request.windowChange(
          recipientChannel: 6,
          termWidth: 100,
          termHeight: 50,
          termPixelWidth: 1000,
          termPixelHeight: 800,
        );
        expect(msg.requestType, 'window-change');
        expect(msg.wantReply, false); // Always false for window-change
        expect(msg.termWidth, 100);
        expect(msg.termHeight, 50);
      });

      test('encodes and decodes window-change request', () {
        final original = SSH_Message_Channel_Request.windowChange(
          recipientChannel: 11,
          termWidth: 200,
          termHeight: 60,
          termPixelWidth: 1600,
          termPixelHeight: 1200,
        );
        final decoded = SSH_Message_Channel_Request.decode(original.encode());

        expect(decoded.requestType, 'window-change');
        expect(decoded.termWidth, 200);
        expect(decoded.termHeight, 60);
      });
    });

    group('signal request', () {
      test('signal factory creates correct request', () {
        final msg = SSH_Message_Channel_Request.signal(
          recipientChannel: 7,
          signalName: 'INT',
        );
        expect(msg.requestType, 'signal');
        expect(msg.signalName, 'INT');
        expect(msg.wantReply, false); // Always false for signal
      });

      test('encodes and decodes signal request', () {
        final original = SSH_Message_Channel_Request.signal(
          recipientChannel: 12,
          signalName: 'TERM',
        );
        final decoded = SSH_Message_Channel_Request.decode(original.encode());

        expect(decoded.requestType, 'signal');
        expect(decoded.signalName, 'TERM');
      });
    });

    group('exit-status request', () {
      test('exitStatus factory creates correct request', () {
        final msg = SSH_Message_Channel_Request.exitStatus(
          recipientChannel: 8,
          exitStatus: 0,
        );
        expect(msg.requestType, 'exit-status');
        expect(msg.exitStatus, 0);
        expect(msg.wantReply, false); // Always false for exit-status
      });

      test('encodes and decodes exit-status request', () {
        final original = SSH_Message_Channel_Request.exitStatus(
          recipientChannel: 13,
          exitStatus: 127,
        );
        final decoded = SSH_Message_Channel_Request.decode(original.encode());

        expect(decoded.requestType, 'exit-status');
        expect(decoded.exitStatus, 127);
      });
    });

    group('exit-signal request', () {
      test('exitSignal factory creates correct request', () {
        final msg = SSH_Message_Channel_Request.exitSignal(
          recipientChannel: 9,
          exitSignalName: 'KILL',
          coreDumped: true,
          errorMessage: 'Process killed',
          languageTag: 'en',
        );
        expect(msg.requestType, 'exit-signal');
        expect(msg.exitSignalName, 'KILL');
        expect(msg.coreDumped, true);
        expect(msg.errorMessage, 'Process killed');
        expect(msg.languageTag, 'en');
      });

      test('encodes and decodes exit-signal request', () {
        final original = SSH_Message_Channel_Request.exitSignal(
          recipientChannel: 14,
          exitSignalName: 'SEGV',
          coreDumped: true,
          errorMessage: 'Segmentation fault',
          languageTag: 'en-US',
        );
        final decoded = SSH_Message_Channel_Request.decode(original.encode());

        expect(decoded.requestType, 'exit-signal');
        expect(decoded.exitSignalName, 'SEGV');
        expect(decoded.coreDumped, true);
        expect(decoded.errorMessage, 'Segmentation fault');
        expect(decoded.languageTag, 'en-US');
      });
    });

    group('x11 request', () {
      test('x11 factory creates correct request', () {
        final msg = SSH_Message_Channel_Request.x11(
          recipientChannel: 10,
          singleConnection: true,
          x11AuthenticationProtocol: 'MIT-MAGIC-COOKIE-1',
          x11AuthenticationCookie: 'abcd1234',
          x11ScreenNumber: '0',
        );
        expect(msg.requestType, 'x11-req');
        expect(msg.singleConnection, true);
        expect(msg.x11AuthenticationProtocol, 'MIT-MAGIC-COOKIE-1');
      });

      test('encodes and decodes x11 request', () {
        final original = SSH_Message_Channel_Request.x11(
          recipientChannel: 15,
          singleConnection: false,
          x11AuthenticationProtocol: 'MIT-MAGIC-COOKIE-1',
          x11AuthenticationCookie: 'deadbeef',
          x11ScreenNumber: '1',
        );
        final decoded = SSH_Message_Channel_Request.decode(original.encode());

        expect(decoded.requestType, 'x11-req');
        expect(decoded.x11AuthenticationProtocol, 'MIT-MAGIC-COOKIE-1');
        expect(decoded.x11AuthenticationCookie, 'deadbeef');
      });
    });

    group('unknown request type', () {
      test('handles unknown request type', () {
        final msg = SSH_Message_Channel_Request(
          recipientChannel: 99,
          requestType: 'custom-request',
          wantReply: true,
        );
        final decoded = SSH_Message_Channel_Request.decode(msg.encode());

        expect(decoded.requestType, 'custom-request');
        expect(decoded.recipientChannel, 99);
        expect(decoded.wantReply, true);
      });
    });

    group('toString', () {
      test('pty toString includes term info', () {
        final msg = SSH_Message_Channel_Request.pty(
          recipientChannel: 1,
          termType: 'xterm',
          termWidth: 80,
          termHeight: 24,
          termPixelWidth: 640,
          termPixelHeight: 480,
          termModes: Uint8List(0),
        );
        expect(msg.toString(), contains('SSH_Message_Channel_Request'));
        expect(msg.toString(), contains('pty-req'));
        expect(msg.toString(), contains('xterm'));
      });

      test('exec toString includes command', () {
        final msg = SSH_Message_Channel_Request.exec(
          recipientChannel: 1,
          wantReply: true,
          command: 'whoami',
        );
        expect(msg.toString(), contains('exec'));
        expect(msg.toString(), contains('whoami'));
      });
    });
  });

  group('SSH_Message_Channel_Success', () {
    test('has correct messageId', () {
      expect(SSH_Message_Channel_Success.messageId, 99);
    });

    test('constructor sets channel', () {
      final msg = SSH_Message_Channel_Success(recipientChannel: 25);
      expect(msg.recipientChannel, 25);
    });

    test('encodes and decodes', () {
      final original = SSH_Message_Channel_Success(recipientChannel: 50);
      final decoded = SSH_Message_Channel_Success.decode(original.encode());
      expect(decoded.recipientChannel, 50);
    });

    test('encode first byte is message id', () {
      final msg = SSH_Message_Channel_Success(recipientChannel: 0);
      final encoded = msg.encode();
      expect(encoded[0], SSH_Message_Channel_Success.messageId);
    });

    test('toString includes channel', () {
      final msg = SSH_Message_Channel_Success(recipientChannel: 75);
      expect(msg.toString(), contains('SSH_Message_Channel_Success'));
      expect(msg.toString(), contains('75'));
    });
  });

  group('SSH_Message_Channel_Failure', () {
    test('has correct messageId', () {
      expect(SSH_Message_Channel_Failure.messageId, 100);
    });

    test('constructor sets channel', () {
      final msg = SSH_Message_Channel_Failure(recipientChannel: 30);
      expect(msg.recipientChannel, 30);
    });

    test('encodes and decodes', () {
      final original = SSH_Message_Channel_Failure(recipientChannel: 60);
      final decoded = SSH_Message_Channel_Failure.decode(original.encode());
      expect(decoded.recipientChannel, 60);
    });

    test('encode first byte is message id', () {
      final msg = SSH_Message_Channel_Failure(recipientChannel: 0);
      final encoded = msg.encode();
      expect(encoded[0], SSH_Message_Channel_Failure.messageId);
    });

    test('toString includes channel', () {
      final msg = SSH_Message_Channel_Failure(recipientChannel: 90);
      expect(msg.toString(), contains('SSH_Message_Channel_Failure'));
      expect(msg.toString(), contains('90'));
    });
  });

  group('Message ID sequence', () {
    test('message IDs are sequential from 90 to 100', () {
      expect(SSH_Message_Channel_Open.messageId, 90);
      expect(SSH_Message_Channel_Confirmation.messageId, 91);
      expect(SSH_Message_Channel_Open_Failure.messageId, 92);
      expect(SSH_Message_Channel_Window_Adjust.messageId, 93);
      expect(SSH_Message_Channel_Data.messageId, 94);
      expect(SSH_Message_Channel_Extended_Data.messageId, 95);
      expect(SSH_Message_Channel_EOF.messageId, 96);
      expect(SSH_Message_Channel_Close.messageId, 97);
      expect(SSH_Message_Channel_Request.messageId, 98);
      expect(SSH_Message_Channel_Success.messageId, 99);
      expect(SSH_Message_Channel_Failure.messageId, 100);
    });
  });

  group('Typical usage scenarios', () {
    test('channel open and confirm flow', () {
      // Client requests session channel
      final openRequest = SSH_Message_Channel_Open.session(
        senderChannel: 0,
        initialWindowSize: 1048576,
        maximumPacketSize: 32768,
      );

      // Server confirms
      final confirmation = SSH_Message_Channel_Confirmation(
        recipientChannel: 0,
        senderChannel: 1,
        initialWindowSize: 1048576,
        maximumPacketSize: 32768,
        data: Uint8List(0),
      );

      expect(openRequest.channelType, 'session');
      expect(confirmation.recipientChannel, openRequest.senderChannel);
    });

    test('pty allocation and shell request flow', () {
      // Request PTY
      final ptyRequest = SSH_Message_Channel_Request.pty(
        recipientChannel: 1,
        wantReply: true,
        termType: 'xterm-256color',
        termWidth: 80,
        termHeight: 24,
        termPixelWidth: 640,
        termPixelHeight: 480,
        termModes: Uint8List.fromList([0]),
      );

      // Request shell
      final shellRequest = SSH_Message_Channel_Request.shell(
        recipientChannel: 1,
        wantReply: true,
      );

      expect(ptyRequest.requestType, 'pty-req');
      expect(shellRequest.requestType, 'shell');
    });

    test('data transfer flow', () {
      // Send data
      final sendData = SSH_Message_Channel_Data(
        recipientChannel: 1,
        data: Uint8List.fromList('ls -la\n'.codeUnits),
      );

      // Receive output - demonstrates receiving data from server
      final receiveData = SSH_Message_Channel_Data(
        recipientChannel: 0,
        data: Uint8List.fromList('file.txt  2024-01-01'.codeUnits),
      );

      // Receive stderr
      final stderrData = SSH_Message_Channel_Extended_Data(
        recipientChannel: 0,
        dataTypeCode: SSH_Message_Channel_Extended_Data.dataTypeStderr,
        data: Uint8List.fromList('Permission denied\n'.codeUnits),
      );

      expect(String.fromCharCodes(sendData.data), 'ls -la\n');
      expect(String.fromCharCodes(receiveData.data), 'file.txt  2024-01-01');
      expect(stderrData.dataTypeCode, 1);
    });

    test('channel close flow', () {
      // Send EOF
      final eof = SSH_Message_Channel_EOF(recipientChannel: 1);

      // Send close
      final close = SSH_Message_Channel_Close(recipientChannel: 1);

      expect(eof.recipientChannel, 1);
      expect(close.recipientChannel, 1);
    });

    test('port forwarding flow', () {
      // Request direct-tcpip channel for local port forwarding
      final directTcpip = SSH_Message_Channel_Open.directTcpip(
        senderChannel: 2,
        initialWindowSize: 1048576,
        maximumPacketSize: 32768,
        host: 'internal-db.example.com',
        port: 5432,
        originatorIP: '127.0.0.1',
        originatorPort: 15432,
      );

      // Server might respond with failure
      final failure = SSH_Message_Channel_Open_Failure(
        recipientChannel: 2,
        reasonCode: SSH_Message_Channel_Open_Failure.codeConnectFailed,
        description: 'Connection to internal-db.example.com:5432 failed',
      );

      expect(directTcpip.channelType, 'direct-tcpip');
      expect(failure.reasonCode, 2);
    });
  });
}
