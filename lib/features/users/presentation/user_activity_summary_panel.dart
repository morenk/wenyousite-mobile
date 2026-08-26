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
      padding: EdgeInsets.all(tokens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WenyouSectionHeader(title: '创作概览'),
          SizedBox(height: tokens.space8),
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
    final items = [
      _ActivitySummaryItem(
        icon: WenyouIconIds.contentMoment,
        label: '发布动态',
        value: summary.momentCount,
      ),
      _ActivitySummaryItem(
        icon: WenyouIconIds.contentThread,
        label: '创建主题',
        value: summary.createdThreadCount,
      ),
      _ActivitySummaryItem(
        icon: WenyouIconIds.metricPlayers,
        label: '参与主题',
        value: summary.playedThreadCount,
      ),
      _ActivitySummaryItem(
        icon: WenyouIconIds.actionReply,
        label: '累计回复',
        value: summary.replyCount,
      ),
    ];
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: items[0]),
            SizedBox(width: tokens.space8),
            Expanded(child: items[1]),
          ],
        ),
        SizedBox(height: tokens.space8),
        Row(
          children: [
            Expanded(child: items[2]),
            SizedBox(width: tokens.space8),
            Expanded(child: items[3]),
          ],
        ),
      ],
    );
  }
}

class _ActivitySummaryItem extends StatelessWidget {
  const _ActivitySummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final displayValue = value == null
        ? '未公开'
        : formatWenyouCompactCount(value!);
    return Semantics(
      label: '$label，$displayValue',
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space4),
        child: Row(
          children: [
            WenyouIcon(icon, size: 20, color: tokens.mutedText),
            SizedBox(width: tokens.space8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayValue,
                    style: value == null
                        ? Theme.of(context).textTheme.labelLarge
                        : Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: tokens.space4),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
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
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: _ActivitySummarySkeletonItem()),
              SizedBox(width: tokens.space8),
              const Expanded(child: _ActivitySummarySkeletonItem()),
            ],
          ),
          SizedBox(height: tokens.space8),
          Row(
            children: [
              const Expanded(child: _ActivitySummarySkeletonItem()),
              SizedBox(width: tokens.space8),
              const Expanded(child: _ActivitySummarySkeletonItem()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivitySummarySkeletonItem extends StatelessWidget {
  const _ActivitySummarySkeletonItem();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.space4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: tokens.softPanel,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: tokens.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 20, color: tokens.softPanel),
                SizedBox(height: tokens.space4),
                FractionallySizedBox(
                  widthFactor: 0.72,
                  child: Container(height: 12, color: tokens.softPanel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
