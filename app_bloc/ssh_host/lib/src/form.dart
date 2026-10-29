import 'dart:async';

import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';

import 'bloc.dart';

class SshHostFormBloc extends FormBloc<String, String> {
  final SshHostBloc sshHostBloc;
  List<SshKey> _sshKeys = [];
  int? _editingHostId;

  final host = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final hostname = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final port = TextFieldBloc<int>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final username = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final identityType = SelectFieldBloc<SshIdentityType, dynamic>(
    items: SshIdentityType.values,
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final password = TextFieldBloc<String>(validators: [
    (pwd) {
      // if (identityType.value == SshIdentityType.password) {
      //   if (pwd.isEmpty) {
      //     return 'Required';
      //   }
      // }
      return null;
    },
  ]);

  final identityKeyId = SelectFieldBloc<SshKey, dynamic>(validators: [
    (key) {
      // if (identityType.value == SshIdentityType.key) {
      //   if (key.isEmpty) {
      //     return 'Required';
      //   }
      // }
      return null;
    },
  ]);

  SshHostFormBloc(this.sshHostBloc) {
    addFieldBlocs(
      fieldBlocs: [
        host,
        hostname,
        port,
        username,
        identityType,
        password,
        identityKeyId
      ],
    );
  }

  void setSshKeys(List<SshKey> sshKeys) {
    _sshKeys = sshKeys;
    identityKeyId.updateItems(sshKeys);
  }

  void setSshHost(SshHost? sshHost) {
    _editingHostId = sshHost?.id;
    host.updateValue(sshHost?.host ?? '');
    hostname.updateValue(sshHost?.hostname ?? '');
    port.updateValue((sshHost?.port ?? 22).toString());
    username.updateValue(sshHost?.username ?? '');
    identityType.updateValue(SshIdentityType.fromValue(sshHost?.identityType));
    password.updateValue('');
    identityKeyId.updateItems(_sshKeys);
    if (sshHost?.identityKeyId != null) {
      final sshKey =
          _sshKeys.where((k) => k.id == sshHost!.identityKeyId!).firstOrNull;
      identityKeyId.updateValue(sshKey);
    }
  }

  @override
  void onSubmitting() async {
    try {
      final completion = Completer<void>();
      if (_editingHostId != null) {
        sshHostBloc.add(SshHostUpdate(
          completion: completion,
          id: _editingHostId!,
          host: host.value,
          hostname: hostname.value,
          port: int.parse(port.value),
          username: username.value,
          identityType: identityType.value?.value,
          password: identityType.value == SshIdentityType.password
              ? password.value
              : null,
          identityKeyId: identityType.value == SshIdentityType.key
              ? identityKeyId.value?.id
              : null,
        ));
      } else {
        sshHostBloc.add(SshHostAdd(
          completion: completion,
          host: host.value,
          hostname: hostname.value,
          port: int.parse(port.value),
          username: username.value,
          identityType: identityType.value?.value,
          password: identityType.value == SshIdentityType.password
              ? password.value
              : null,
          identityKeyId: identityType.value == SshIdentityType.key
              ? identityKeyId.value?.id
              : null,
        ));
      }
      await completion.future;
      if (isClosed) return;
      emitSuccess(
        successResponse:
            _editingHostId != null ? 'Host updated' : 'Host created',
      );
    } catch (e) {
      if (isClosed) return;
      emitFailure(
        failureResponse: e.toString(),
      );
    }
  }
}
