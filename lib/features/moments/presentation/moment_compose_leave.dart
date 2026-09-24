import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

enum MomentLeaveDraftDecision { save, discard }

Future<MomentLeaveDraftDecision?> showMomentLeaveDraftSheet(
  BuildContext context, {
  required bool pending,
  required bool hasPendingImages,
}) {
  return showModalBottomSheet<MomentLeaveDraftDecision>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) {
      final tokens = context.wenyouTokens;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.space16,
          0,
          tokens.space16,
          tokens.space16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              pending ? '已保留这次发布的内容' : '要保存这次编辑吗？',
              style: Theme.of(context).textTheme.wenyouOverlayTitle,
            ),
            if (hasPendingImages) ...[
              SizedBox(height: tokens.space8),
              Text(
                '图片和正文会保存到本机。',
                style: Theme.of(
                  context,
                ).textTheme.wenyouCompactBody.copyWith(color: tokens.mutedText),
              ),
            ],
            SizedBox(height: tokens.space16),
            FilledButton(
              key: const Key('moment-leave-save'),
              onPressed: () =>
                  Navigator.pop(context, MomentLeaveDraftDecision.save),
              child: Text(pending ? '保留并退出' : '保存草稿并退出'),
            ),
            SizedBox(height: tokens.space8),
            if (!pending)
              TextButton(
                key: const Key('moment-leave-discard'),
                onPressed: () =>
                    Navigator.pop(context, MomentLeaveDraftDecision.discard),
                child: const Text('不保存'),
              ),
          ],
        ),
      );
    },
  );
}
