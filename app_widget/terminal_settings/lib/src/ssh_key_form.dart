import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_feedback/app_feedback.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:app_security/app_security.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';
import 'package:app_locale/app_locale.dart';

/// Shows a full screen dialog form for adding or editing an SSH key.
///
/// If [sshKey] is provided, the form will be pre-filled with the key's data
/// for editing. Otherwise, an empty form for adding a new key is shown.
void showSshKeyForm({required BuildContext context, SshKey? sshKey}) {
  // Perform side effects before showing dialog to avoid repeated calls on rebuild
  final sshKeyFormBloc = context.read<SshKeyFormBloc>();
  sshKeyFormBloc.clear();
  sshKeyFormBloc.setSshKey(sshKey);

  showDmFullscreenDialog(
    context: context,
    title: Text(
      context.l10n.addSshKey,
    ),
    builder: (context) {
      final sshKeyFormBloc = context.read<SshKeyFormBloc>();

      return DmFormBlocListener<SshKeyFormBloc, String, String>(
        onSubmitting: (context, state) {},
        onSubmissionFailed: (context, state) {},
        onSuccess: (context, state) {
          Navigator.of(context).pop();
          context.read<SshKeyBloc>().add(SshKeyLoad());
          showSuccessToast(context: context, message: state.successResponse!);
        },
        onFailure: (context, state) {
          if (state.failureResponse != null) {
            showErrorToast(context: context, message: state.failureResponse!);
          }
          context.read<SshKeyBloc>().add(SshKeyLoad());
        },
        child: AutofillGroup(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DmTextFieldBlocBuilder(
                    textFieldBloc: sshKeyFormBloc.name,
                    suffixButton: SuffixButton.clearText,
                    autofillHints: const [AutofillHints.name],
                    obscureText: false,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      hintText: context.l10n.sshKeyNameLabel,
                      labelText: context.l10n.sshKeyNameHint,
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () async {
                      try {
                        final file = await FilePicker.pickFile(
                          type: FileType.any,
                        );
                        if (file == null || !context.mounted) return;
                        final privateKey =
                            utf8.decode(await file.readAsBytes());
                        if (!context.mounted) return;
                        if (privateKey.trim().isEmpty) {
                          throw const FormatException('Empty private key file');
                        }
                        sshKeyFormBloc.content.updateValue(privateKey);
                        if (sshKeyFormBloc.name.value.trim().isEmpty) {
                          sshKeyFormBloc.name.updateValue(file.name);
                        }
                      } catch (_) {
                        if (!context.mounted) return;
                        showErrorToast(
                          context: context,
                          message: context.l10n.sshKeyImportError,
                        );
                      }
                    },
                    icon: const Icon(Icons.file_open_outlined),
                    label: Text(context.l10n.sshKeyImport),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () async {
                      final rsaHelper = RsaKeyHelper();
                      final kayPair = await rsaHelper.computeRSAKeyPair(
                        2048,
                      );
                      final priKeyStr = rsaHelper.getPrivateKeyPem(kayPair);
                      sshKeyFormBloc.content.updateValue(priKeyStr);
                    },
                    child: Text(context.l10n.sshKeyGenerate),
                  ),
                  const SizedBox(height: 20),
                  DmTextFieldBlocBuilder(
                    textFieldBloc: sshKeyFormBloc.content,
                    suffixButton: SuffixButton.clearText,
                    autofillHints: const [AutofillHints.name],
                    obscureText: false,
                    autocorrect: false,
                    enableSuggestions: false,
                    minLines: 10,
                    maxLines: 28,
                    decoration: InputDecoration(
                      labelText: context.l10n.sshKeyContentLabel,
                    ),
                    textStyle: GoogleFonts.robotoMono(
                      textStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<SshKeyFormBloc, FormBlocState>(
                    bloc: sshKeyFormBloc,
                    builder: (context, state) {
                      if (state is FormBlocSubmitting) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            minimumSize: const Size.fromHeight(50), // NEW
                          ),
                          onPressed: null,
                          child: const CircularProgressIndicator.adaptive(),
                        );
                      }
                      return state.isValid()
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                minimumSize: const Size.fromHeight(50), // NEW
                              ),
                              onPressed: sshKeyFormBloc.submit,
                              child: Text(context.l10n.save),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50), // NEW
                              ),
                              onPressed: null,
                              child: Text(context.l10n.save),
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
