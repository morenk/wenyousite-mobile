import 'package:flutter/material.dart';

const directMessageNoticeComposerClearance = 88.0;

void showDirectMessageNotice(BuildContext context, String message) {
  final mediaQuery = MediaQuery.of(context);
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        key: const Key('direct-message-floating-notice'),
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          mediaQuery.viewInsets.bottom +
              mediaQuery.padding.bottom +
              directMessageNoticeComposerClearance,
        ),
      ),
    );
}
