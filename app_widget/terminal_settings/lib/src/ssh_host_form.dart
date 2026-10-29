import 'package:flutter/material.dart';
import 'package:app_feedback/app_feedback.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';
import 'package:app_locale/app_locale.dart';

/// Shows a full screen dialog form for adding or editing an SSH host.
///
/// If [sshHost] is provided, the form will be pre-filled with the host's data
/// for editing. Otherwise, an empty form for adding a new host is shown.
void showSshHostForm({required BuildContext context, SshHost? sshHost}) {
  // Perform side effects before showing dialog to avoid repeated calls on rebuild
  final sshKeyBloc = context.read<SshKeyBloc>();
  sshKeyBloc.add(SshKeyLoad());
  final sshHostFormBloc = context.read<SshHostFormBloc>();
  sshHostFormBloc.clear();
  // Pre-populate SSH keys if already loaded
  final sshKeyState = sshKeyBloc.state;
  if (sshKeyState is SshKeyLoaded) {
    sshHostFormBloc.setSshKeys(sshKeyState.sshKeys);
  }
  sshHostFormBloc.setSshHost(sshHost);

  showDmFullscreenDialog(
    context: context,
    title: Text(
      sshHost == null ? context.l10n.addSshHost : context.l10n.editSshHost,
    ),
    builder: (context) {
      final sshHostFormBloc = context.read<SshHostFormBloc>();

      return BlocListener<SshKeyBloc, SshKeyState>(
        listener: (context, state) {
          if (state is SshKeyLoaded) {
            context.read<SshHostFormBloc>().setSshKeys(state.sshKeys);
          }
        },
        child: DmFormBlocListener<SshHostFormBloc, String, String>(
          onSubmitting: (context, state) {},
          onSubmissionFailed: (context, state) {},
          onSuccess: (context, state) {
            Navigator.of(context).pop();
            context.read<SshHostBloc>().add(SshHostLoad());
            showSuccessToast(context: context, message: state.successResponse!);
          },
          onFailure: (context, state) {
            if (state.failureResponse != null) {
              showErrorToast(context: context, message: state.failureResponse!);
            }
            context.read<SshHostBloc>().add(SshHostLoad());
          },
          child: AutofillGroup(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DmTextFieldBlocBuilder(
                      textFieldBloc: sshHostFormBloc.host,
                      suffixButton: SuffixButton.clearText,
                      obscureText: false,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        hintText: context.l10n.sshHostHostLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DmTextFieldBlocBuilder(
                      textFieldBloc: sshHostFormBloc.hostname,
                      suffixButton: SuffixButton.clearText,
                      autofillHints: const [AutofillHints.name],
                      obscureText: false,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: context.l10n.sshHostHostnameLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DmTextFieldBlocBuilder(
                      textFieldBloc: sshHostFormBloc.port,
                      suffixButton: SuffixButton.clearText,
                      autofillHints: const [AutofillHints.name],
                      obscureText: false,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: context.l10n.sshHostPortLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DmTextFieldBlocBuilder(
                      textFieldBloc: sshHostFormBloc.username,
                      suffixButton: SuffixButton.clearText,
                      autofillHints: const [AutofillHints.name],
                      obscureText: false,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: context.l10n.sshHostUsernameLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DmDropdownFieldBlocBuilder<SshIdentityType>(
                      selectFieldBloc: sshHostFormBloc.identityType,
                      itemBuilder: (context, value) {
                        return switch (value) {
                          SshIdentityType.password => FieldItem(
                              child: Text(
                                context.l10n.sshHostIdentityTypePassword,
                              ),
                            ),
                          SshIdentityType.key => FieldItem(
                                child: Text(
                              context.l10n.sshHostIdentityTypePrivateKey,
                            )),
                        };
                      },
                      decoration: InputDecoration(
                        labelText: context.l10n.sshHostIdentifyTypeLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<SelectFieldBloc<SshIdentityType, dynamic>,
                        SelectFieldBlocState>(
                      bloc: sshHostFormBloc.identityType,
                      builder: (context, state) {
                        final identityType = state.value;
                        if (identityType == SshIdentityType.password) {
                          return DmTextFieldBlocBuilder(
                            textFieldBloc: sshHostFormBloc.password,
                            suffixButton: SuffixButton.obscureText,
                            autofillHints: const [AutofillHints.password],
                            obscureText: true,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: InputDecoration(
                              labelText: context.l10n.sshHostPasswordLabel,
                            ),
                          );
                        }
                        if (identityType == SshIdentityType.key) {
                          return DmDropdownFieldBlocBuilder<SshKey>(
                            selectFieldBloc: sshHostFormBloc.identityKeyId,
                            itemBuilder: (context, value) {
                              return FieldItem(
                                child: Text(value.name ?? ''),
                              );
                            },
                            decoration: InputDecoration(
                              labelText: context.l10n.sshHostPrivateKeyLabel,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<SshHostFormBloc, FormBlocState>(
                      bloc: sshHostFormBloc,
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
                                onPressed: sshHostFormBloc.submit,
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
        ),
      );
    },
  );
}
