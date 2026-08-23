import 'package:flutter/material.dart';

const wenyouBriefSnackBarDuration = Duration(milliseconds: 2500);
const wenyouExtendedSnackBarDuration = Duration(seconds: 4);

enum WenyouSnackBarPacing { brief, extended }

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showWenyouSnackBar(
  BuildContext context,
  String message, {
  WenyouSnackBarPacing pacing = WenyouSnackBarPacing.brief,
  String? actionLabel,
  VoidCallback? onAction,
  Key? key,
  Key? actionKey,
  SnackBarBehavior? behavior,
  EdgeInsetsGeometry? margin,
}) {
  return ScaffoldMessenger.maybeOf(context)?.showWenyouSnackBar(
    message,
    pacing: pacing,
    actionLabel: actionLabel,
    onAction: onAction,
    key: key,
    actionKey: actionKey,
    behavior: behavior,
    margin: margin,
  );
}

extension WenyouSnackBarMessenger on ScaffoldMessengerState {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showWenyouSnackBar(
    String message, {
    WenyouSnackBarPacing pacing = WenyouSnackBarPacing.brief,
    String? actionLabel,
    VoidCallback? onAction,
    Key? key,
    Key? actionKey,
    SnackBarBehavior? behavior,
    EdgeInsetsGeometry? margin,
  }) {
    assert(
      (actionLabel == null) == (onAction == null),
      'actionLabel and onAction must be provided together.',
    );
    final hasAction = actionLabel != null && onAction != null;
    final duration = hasAction || pacing == WenyouSnackBarPacing.extended
        ? wenyouExtendedSnackBarDuration
        : wenyouBriefSnackBarDuration;

    clearSnackBars();
    return showSnackBar(
      SnackBar(
        key: key,
        content: Text(message),
        duration: duration,
        persist: false,
        behavior: behavior,
        margin: margin,
        action: hasAction
            ? SnackBarAction(
                key: actionKey,
                label: actionLabel,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
