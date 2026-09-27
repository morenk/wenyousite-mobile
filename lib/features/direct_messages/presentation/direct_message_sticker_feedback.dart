import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_notice.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

Future<void> saveDirectMessageStickerWithFeedback(
  BuildContext context,
  WidgetRef ref,
  String messageId,
) async {
  var failed = false;
  late final String message;
  try {
    message = await ref
        .read(stickerCollectionControllerProvider.notifier)
        .importSourceForFeedback(StickerDirectMessageSource(messageId));
  } on Object catch (error) {
    failed = true;
    message = mapApplicationFailure(error, '收藏表情失败，请稍后重试。').userMessage;
  }
  if (!context.mounted) return;
  showDirectMessageNotice(
    context,
    message,
    pacing: failed ? WenyouSnackBarPacing.extended : WenyouSnackBarPacing.brief,
    tone: failed ? WenyouSnackBarTone.error : WenyouSnackBarTone.success,
  );
}
