import 'package:flutter/widgets.dart';
import 'package:wenyousite_mobile/core/application/reply_content_validation.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';

bool validateReplyContent(
  BuildContext context,
  String content, {
  bool hasAttachment = false,
}) {
  final message = replyContentValidationMessage(
    content,
    hasAttachment: hasAttachment,
  );
  if (message == null) return true;
  showWenyouSnackBar(context, message);
  return false;
}
