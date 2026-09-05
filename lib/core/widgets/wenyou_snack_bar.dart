import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar_activity.dart';

const wenyouBriefSnackBarDuration = Duration(milliseconds: 2500);
const wenyouExtendedSnackBarDuration = Duration(seconds: 4);

enum WenyouSnackBarPacing { brief, extended }

enum WenyouSnackBarTone { neutral, success, error }

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showWenyouSnackBar(
  BuildContext context,
  String message, {
  WenyouSnackBarPacing pacing = WenyouSnackBarPacing.brief,
  WenyouSnackBarTone tone = WenyouSnackBarTone.neutral,
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
    tone: tone,
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
    WenyouSnackBarTone tone = WenyouSnackBarTone.neutral,
    String? actionLabel,
    VoidCallback? onAction,
    Key? key,
    Key? actionKey,
    SnackBarBehavior? behavior,
    EdgeInsetsGeometry? margin,
    bool deferred = false,
  }) {
    assert(
      (actionLabel == null) == (onAction == null),
      'actionLabel and onAction must be provided together.',
    );
    final hasAction = actionLabel != null && onAction != null;
    final duration = hasAction || pacing == WenyouSnackBarPacing.extended
        ? wenyouExtendedSnackBarDuration
        : wenyouBriefSnackBarDuration;

    final tokens = context.wenyouTokens;
    final (color, surface, icon) = switch (tone) {
      WenyouSnackBarTone.neutral => (
        tokens.info,
        tokens.infoSoft,
        WenyouIconIds.statusInfo,
      ),
      WenyouSnackBarTone.success => (
        tokens.success,
        tokens.successSoft,
        WenyouIconIds.statusSuccess,
      ),
      WenyouSnackBarTone.error => (
        tokens.destructive,
        tokens.destructiveSoft,
        WenyouIconIds.statusError,
      ),
    };
    final activity = WenyouSnackBarActivity.of(this);
    final epoch = deferred ? null : activity.begin();
    if (!deferred) clearSnackBars();
    final controller = showSnackBar(
      SnackBar(
        key: key,
        backgroundColor: tokens.panel,
        elevation: WenyouOverlayContract.elevation['floating'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius16),
          side: BorderSide(color: tokens.border),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: tokens.space32,
                    height: tokens.space32,
                    decoration: BoxDecoration(
                      color: surface,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: WenyouIcon(icon, color: color),
                  ),
                ),
                SizedBox(width: tokens.space12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: tokens.space4),
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.wenyouCompactBody
                          .copyWith(color: tokens.text),
                    ),
                  ),
                ),
              ],
            ),
            // Keep the action below the message: Flutter's automatic overflow
            // estimate omits text scaling and reserves width even after wrapping.
            if (hasAction)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: SnackBarAction(
                  key: actionKey,
                  label: actionLabel,
                  onPressed: onAction,
                  textColor: tokens.brandForeground,
                ),
              ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space16,
          vertical: tokens.space12,
        ),
        duration: duration,
        persist: false,
        behavior: behavior ?? SnackBarBehavior.floating,
        margin:
            margin ??
            (behavior == SnackBarBehavior.fixed
                ? null
                : EdgeInsets.all(tokens.space16)),
      ),
    );
    if (epoch != null) {
      controller.closed.then((_) => activity.finish(epoch));
    }
    return controller;
  }
}
