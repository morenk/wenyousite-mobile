import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_navigation.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_number_sheet.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';

Future<void> showDiscussionNavigation<S>({
  required BuildContext context,
  required DiscussionNavigation<S> navigation,
  required bool replies,
  required int maxNumber,
}) async {
  navigation.reading.close();
  var completed = false;
  var cleared = false;
  final revision = navigation.revision;
  await showDiscussionNumberSheet(
    context: context,
    replies: replies,
    currentNumber: navigation.reading.visibleBookmark?.number,
    maxNumber: maxNumber,
    onLocate: (number, active) async {
      cleared = await navigation.jump(number, active);
      completed = active() && navigation.revision != revision;
    },
  );
  if (!context.mounted || !completed) return;
  Future<void> returnToPrevious() async {
    try {
      await navigation.returnToPrevious();
    } on Object catch (error) {
      final failure = mapApplicationFailure(error, '返回失败，请重试。');
      if (failure.httpStatus == 404) navigation.forgetPrevious();
      if (!context.mounted) return;
      showWenyouSnackBar(
        context,
        failure.userMessage,
        tone: WenyouSnackBarTone.error,
        actionLabel: navigation.canReturn ? '重试' : null,
        onAction: navigation.canReturn ? returnToPrevious : null,
      );
    }
  }

  showWenyouSnackBar(
    context,
    cleared ? '已取消发言者筛选并定位。' : '已定位到目标${replies ? '回复' : '楼层'}。',
    actionLabel: navigation.canReturn ? '回到刚才' : null,
    onAction: navigation.canReturn ? returnToPrevious : null,
  );
}
