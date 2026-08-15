import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_controllers.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionKey = walletSessionKey(ref);
    final provider = walletControllerProvider(sessionKey);
    final state = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的温油')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(provider.notifier).refresh(),
        child: ListView(
          key: const PageStorageKey('wallet-page-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: _pagePadding(context),
          children: [
            _WalletSummaryPanel(
              state: state,
              onRetry: () => ref.read(provider.notifier).retrySummary(),
            ),
            SizedBox(height: context.wenyouTokens.space12),
            _WalletTransactionsPanel(
              state: state,
              onRetry: () => ref.read(provider.notifier).retryTransactions(),
              onLoadMore: () => ref.read(provider.notifier).loadMore(),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _pagePadding(BuildContext context) {
    final tokens = context.wenyouTokens;
    final horizontal = MediaQuery.sizeOf(context).width <= 400
        ? tokens.space12
        : tokens.space24;
    return EdgeInsets.fromLTRB(
      horizontal,
      tokens.space16,
      horizontal,
      tokens.space32,
    );
  }
}

class _WalletSummaryPanel extends StatelessWidget {
  const _WalletSummaryPanel({required this.state, required this.onRetry});

  final WalletState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final summary = state.summary;
    return WenyouPanel(
      child: summary == null
          ? state.isLoadingSummary
                ? const _WalletLoading(label: '正在读取温油余额…')
                : WenyouEmptyState(
                    icon: WenyouIconIds.statusOffline,
                    title: '钱包余额没有加载完成',
                    message: state.summaryFailure?.userMessage ?? '请稍后重试。',
                    detail: state.summaryFailure?.requestId == null
                        ? null
                        : '请求 ID：${state.summaryFailure!.requestId}',
                    action: OutlinedButton.icon(
                      key: const Key('wallet-summary-retry'),
                      onPressed: onRetry,
                      icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                      label: const Text('重试余额'),
                    ),
                  )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '温油余额',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: tokens.mutedText),
                          ),
                          SizedBox(height: tokens.space4),
                          Semantics(
                            label: '温油余额 ${summary.balance} 升',
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text.rich(
                                TextSpan(
                                  text: WenyouAmount.format(summary.balance),
                                  children: const [
                                    TextSpan(
                                      text: ' 升',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: tokens.space12),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: tokens.accentedBackground,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox.square(
                        dimension: 52,
                        child: WenyouIcon(
                          WenyouIconIds.actionTip,
                          color: tokens.brand,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.space16),
                Divider(color: tokens.border),
                SizedBox(height: tokens.space12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryStat(
                        label: '累计收到',
                        value:
                            '${WenyouAmount.format(summary.receivedTipTotal)} 升',
                      ),
                    ),
                    SizedBox(
                      height: tokens.minimumTouchTarget,
                      child: const VerticalDivider(),
                    ),
                    Expanded(
                      child: _SummaryStat(
                        label: '收到次数',
                        value: '${summary.receivedTipCount} 次',
                      ),
                    ),
                  ],
                ),
                if (state.summaryFailure != null) ...[
                  SizedBox(height: tokens.space12),
                  WenyouStatusBanner(
                    tone: WenyouStatusTone.error,
                    message: '余额刷新失败，当前仍显示上次结果。',
                    detail: state.summaryFailure!.requestId == null
                        ? null
                        : '请求 ID：${state.summaryFailure!.requestId}',
                    action: TextButton(
                      onPressed: onRetry,
                      child: const Text('重新刷新'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      children: [
        Text(label, style: TextStyle(color: tokens.mutedText)),
        SizedBox(height: tokens.space4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _WalletTransactionsPanel extends StatelessWidget {
  const _WalletTransactionsPanel({
    required this.state,
    required this.onRetry,
    required this.onLoadMore,
  });

  final WalletState state;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WenyouSectionHeader(title: '收支记录'),
          SizedBox(height: tokens.space16),
          if (state.transactions.isEmpty && state.isLoadingTransactions)
            const _WalletLoading(label: '正在读取温油流水…')
          else if (state.transactions.isEmpty &&
              state.transactionsFailure != null)
            WenyouEmptyState(
              icon: WenyouIconIds.statusOffline,
              title: '温油流水没有加载完成',
              message: state.transactionsFailure!.userMessage,
              detail: state.transactionsFailure!.requestId == null
                  ? null
                  : '请求 ID：${state.transactionsFailure!.requestId}',
              action: OutlinedButton.icon(
                key: const Key('wallet-transactions-retry'),
                onPressed: onRetry,
                icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                label: const Text('重试'),
              ),
            )
          else if (state.transactions.isEmpty)
            const WenyouEmptyState(
              icon: WenyouIconIds.economyTransaction,
              title: '暂无收支记录',
              message: '',
            )
          else ...[
            for (var index = 0; index < state.transactions.length; index++) ...[
              if (index > 0) Divider(color: tokens.border),
              _TransactionTile(transaction: state.transactions[index]),
            ],
            if (state.loadMoreFailure != null) ...[
              SizedBox(height: tokens.space12),
              WenyouStatusBanner(
                tone: WenyouStatusTone.error,
                message: state.loadMoreFailure!.userMessage,
                detail: state.loadMoreFailure!.requestId == null
                    ? null
                    : '请求 ID：${state.loadMoreFailure!.requestId}',
                action: TextButton(
                  key: const Key('wallet-load-more-retry'),
                  onPressed: onLoadMore,
                  child: const Text('重试加载'),
                ),
              ),
            ],
            if (state.hasMore) ...[
              SizedBox(height: tokens.space12),
              Center(
                child: OutlinedButton.icon(
                  key: const Key('wallet-load-more'),
                  onPressed: state.isLoadingMore ? null : onLoadMore,
                  icon: state.isLoadingMore
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const WenyouIcon(WenyouIconIds.navigationExpand),
                  label: const Text('加载更多'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final income = transaction.direction == WalletTransactionDirection.income;
    final title = _title(transaction);
    final detail = transaction.type == WalletTransactionType.tip && income
        ? '对方投入 ${WenyouAmount.format(transaction.grossAmount)} 升，'
              '实际到账 ${WenyouAmount.format(transaction.recipientAmount)} 升'
        : null;
    final content = Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CounterpartyAvatar(counterparty: transaction.counterparty),
          SizedBox(width: tokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: tokens.space4),
                Text(
                  DateFormat(
                    'yyyy-MM-dd HH:mm',
                  ).format(transaction.createdAt.toLocal()),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                ),
                if (detail != null) ...[
                  SizedBox(height: tokens.space4),
                  Text(
                    detail,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: tokens.space12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${income ? '+' : '−'}${WenyouAmount.format(transaction.amount)} 升',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: income
                      ? Theme.of(context).colorScheme.tertiary
                      : tokens.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: tokens.space4),
              Text(
                '余额 ${WenyouAmount.format(transaction.balanceAfter)} 升',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
    final path = _targetPath(transaction.target);
    return path == null
        ? content
        : InkWell(
            onTap: () => context.push(path),
            borderRadius: BorderRadius.circular(tokens.radius12),
            child: content,
          );
  }

  String _title(WalletTransaction item) {
    if (item.type == WalletTransactionType.dailyCheckIn) return '每日在线签到';
    final targetTitle = item.target.title?.trim();
    final target = targetTitle != null && targetTitle.isNotEmpty
        ? '「$targetTitle」'
        : item.counterparty?.username ?? '用户';
    return item.direction == WalletTransactionDirection.expense
        ? '投入给$target'
        : '${item.counterparty?.username ?? '用户'} 的投入';
  }

  String? _targetPath(WalletTransactionTarget target) {
    final id = target.id;
    if (id == null) return null;
    return switch (target.type) {
      WalletTargetType.thread => AppRouteLocations.thread(id),
      WalletTargetType.user => AppRouteLocations.user(id),
      WalletTargetType.moment => AppRouteLocations.moment(id),
      WalletTargetType.none => null,
    };
  }
}

class _CounterpartyAvatar extends StatelessWidget {
  const _CounterpartyAvatar({required this.counterparty});

  final WalletCounterparty? counterparty;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: WenyouIcon(WenyouIconIds.identityMember, color: tokens.mutedText),
    );
    final url = counterparty?.avatarUrl;
    return ClipOval(
      child: SizedBox.square(
        dimension: 40,
        child: url == null
            ? fallback
            : WenyouCachedImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, _) => fallback,
                errorWidget: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class _WalletLoading extends StatelessWidget {
  const _WalletLoading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space24),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: tokens.space12),
            Text(label),
          ],
        ),
      ),
    );
  }
}
