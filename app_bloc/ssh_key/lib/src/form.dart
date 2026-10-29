import 'dart:async';

import 'package:duskmoon_ui/duskmoon_ui.dart';

import 'bloc.dart';

class SshKeyFormBloc extends FormBloc<String, String> {
  final SshKeyBloc sshKeyBloc;
  int _keyLoadGeneration = 0;

  final name = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final content = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  SshKeyFormBloc(this.sshKeyBloc) {
    addFieldBlocs(
      fieldBlocs: [name, content],
    );
  }

  Future<void> setSshKey(SshKey? sshKey) async {
    final generation = ++_keyLoadGeneration;
    name.updateValue(sshKey?.name ?? '');
    content.updateValue('');
    if (sshKey == null) return;
    try {
      final privateKey = await sshKeyBloc.credentials.readPrivateKey(sshKey);
      if (!isClosed &&
          generation == _keyLoadGeneration &&
          content.value.isEmpty) {
        content.updateValue(privateKey);
      }
    } catch (error) {
      if (!isClosed && generation == _keyLoadGeneration) {
        content.addFieldError('Unable to load SSH private key');
        emitFailure(failureResponse: error.toString());
      }
    }
  }

  @override
  void onSubmitting() async {
    try {
      final completion = Completer<void>();
      sshKeyBloc.add(SshKeyAdd(
        completion: completion,
        name: name.value,
        content: content.value,
        algorithm: SshKeyAlgorithm.rsa.value,
      ));
      await completion.future;
      if (isClosed) return;
      emitSuccess(
        successResponse: 'SSH Key saved',
      );
    } catch (e) {
      if (isClosed) return;
      emitFailure(
        failureResponse: e.toString(),
      );
    }
  }
}
