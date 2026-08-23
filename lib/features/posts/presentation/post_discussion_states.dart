import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class PostDiscussionFailure extends StatelessWidget {
  const PostDiscussionFailure({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final ApiFailure? failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.metricReplies,
          title: failure?.httpStatus == 404 ? '楼层暂时不可见' : '楼中楼讨论加载失败',
          message: failure?.userMessage ?? '请稍后重试。',
          detail: wenyouRequestDetail(failure),
          action: onRetry == null
              ? null
              : FilledButton(onPressed: onRetry, child: const Text('重试')),
        ),
      ),
    );
  }
}

class PostRouteMismatch extends StatelessWidget {
  const PostRouteMismatch({super.key});

  @override
  Widget build(BuildContext context) {
    return const WenyouPageBody(
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.actionUnlink,
          title: '楼层不属于当前主题',
          message: '请返回主题详情后重新打开。',
        ),
      ),
    );
  }
}
