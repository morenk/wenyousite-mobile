import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';

const directMessageNoticeComposerClearance = 88.0;

void showDirectMessageNotice(
  BuildContext context,
  String message, {
  WenyouSnackBarPacing pacing = WenyouSnackBarPacing.brief,
  WenyouSnackBarTone tone = WenyouSnackBarTone.success,
}) {
  final mediaQuery = MediaQuery.of(context);
  final messenger = ScaffoldMessenger.of(context);
  messenger.showWenyouSnackBar(
    message,
    pacing: pacing,
    tone: tone,
    key: const Key('direct-message-floating-notice'),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.fromLTRB(
      16,
      16,
      16,
      mediaQuery.viewInsets.bottom +
          mediaQuery.padding.bottom +
          directMessageNoticeComposerClearance,
    ),
  );
}
