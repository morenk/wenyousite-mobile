import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';

class UserActivitySummaryPanel extends StatelessWidget {
  const UserActivitySummaryPanel({
    required this.state,
    required this.onRetry,
    this.keyPrefix = 'user-activity',
    super.key,
  });

  final PublicUserState state;
  final VoidCallback onRetry;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      padding: EdgeInsets.all(tokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WenyouSectionHeader(title: '创作概览'),
          SizedBox(height: tokens.space12),
          switch (state.activityPhase) {
            PublicUserActivityPhase.idle || PublicUserActivityPhase.loading =>
              _ActivitySummarySkeleton(key: Key('$keyPrefix-loading')),
            PublicUserActivityPhase.failed => WenyouStatusBanner(
              key: Key('$keyPrefix-failure'),
              tone: WenyouStatusTone.error,
              message: state.activityFailure?.userMessage ?? '创作概览加载失败。',
              detail: state.activityFailure?.requestId == null
                  ? null
                  : '问题编号：${state.activityFailure!.requestId}',
              action: TextButton(
                key: Key('$keyPrefix-retry'),
                onPressed: onRetry,
                child: const Text('重试'),
              ),
            ),
            PublicUserActivityPhase.ready => _ActivitySummaryGrid(
              summary: state.activitySummary!,
            ),
          },
        ],
      ),
    );
  }
}

class _ActivitySummaryGrid extends StatelessWidget {
  const _ActivitySummaryGrid({required this.summary});

  final PublicUserActivitySummary summary;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - tokens.space8) / 2;
        return Wrap(
          spacing: tokens.space8,
          runSpacing: tokens.space8,
          children: [
            _ActivitySummaryItem(
              width: itemWidth,
              icon: WenyouIconIds.contentMoment,
              label: '发布动态',
              hint: '短内容',
              value: summary.momentCount,
            ),
            _ActivitySummaryItem(
              width: itemWidth,
              icon: WenyouIconIds.contentThread,
              label: '创建主题',
              hint: '担任楼主',
              value: summary.createdThreadCount,
            ),
            _ActivitySummaryItem(
              width: itemWidth,
              icon: WenyouIconIds.metricPlayers,
              label: '参与主题',
              hint: '玩家身份',
              value: summary.playedThreadCount,
            ),
            _ActivitySummaryItem(
              width: itemWidth,
              icon: WenyouIconIds.actionReply,
              label: '累计回复',
              hint: '楼层讨论',
              value: summary.replyCount,
            ),
          ],
        );
      },
    );
  }
}

class _ActivitySummaryItem extends StatelessWidget {
  const _ActivitySummaryItem({
    required this.width,
    required this.icon,
    required this.label,
    required this.hint,
    required this.value,
  });

  final double width;
  final String icon;
  final String label;
  final String hint;
  final int? value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final displayValue = value == null
        ? '未公开'
        : formatWenyouCompactCount(value!);
    return Semantics(
      label: '$label，$displayValue，$hint',
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.softPanel,
            borderRadius: BorderRadius.circular(tokens.radius12),
          ),
          child: Padding(
            padding: EdgeInsets.all(tokens.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    WenyouIcon(icon, size: 18, color: tokens.brandForeground),
                  ],
                ),
                SizedBox(height: tokens.space8),
                Text(
                  displayValue,
                  style: value == null
                      ? Theme.of(context).textTheme.labelLarge
                      : Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: tokens.space4),
                Text(hint, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivitySummarySkeleton extends StatelessWidget {
  const _ActivitySummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      label: '创作概览加载中',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - tokens.space8) / 2;
          return Wrap(
            spacing: tokens.space8,
            runSpacing: tokens.space8,
            children: [
              for (var index = 0; index < 4; index++)
                Container(
                  width: itemWidth,
                  height: 96,
                  decoration: BoxDecoration(
                    color: tokens.softPanel,
                    borderRadius: BorderRadius.circular(tokens.radius12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
