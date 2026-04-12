import 'package:duskmoon_feedback/duskmoon_feedback.dart';
import 'package:flutter/material.dart';

/// Backward-compatible aliases mapping old app_feedback names to DuskMoon equivalents.

typedef AppDialogAction = DmDialogAction;

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required Widget title,
  required Widget content,
  List<Widget>? actions,
}) =>
    showDmDialog<T>(
      context: context,
      title: title,
      content: content,
      actions: actions,
    );

void showSuccessToast({
  required BuildContext context,
  required String message,
  String? title,
  Duration duration = const Duration(seconds: 5),
  bool showCloseIcon = false,
  String? actionLabel,
  void Function()? onActionPressed,
}) =>
    showDmSuccessToast(
      context: context,
      message: message,
      title: title ?? 'Success',
      duration: duration,
      showCloseIcon: showCloseIcon,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );

void showErrorToast({
  required BuildContext context,
  String? title,
  required String message,
  String? actionLabel,
  void Function()? onActionPressed,
}) =>
    showDmErrorToast(
      context: context,
      message: message,
      title: title ?? 'Error',
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );

void showSnackbar({
  required Widget message,
  required BuildContext context,
  Duration duration = const Duration(seconds: 5),
  bool showCloseIcon = false,
  String? actionLabel,
  VoidCallback? onActionPressed,
}) =>
    showDmSnackbar(
      context: context,
      message: message,
      duration: duration,
      showCloseIcon: showCloseIcon,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );

void showUndoSnackbar({
  required BuildContext context,
  required void Function() onUndoPressed,
  required Widget message,
  Duration duration = const Duration(seconds: 5),
  bool showCloseIcon = true,
}) =>
    showDmUndoSnackbar(
      context: context,
      onUndoPressed: onUndoPressed,
      message: message,
      duration: duration,
      showCloseIcon: showCloseIcon,
    );
