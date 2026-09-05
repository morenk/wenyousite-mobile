import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_controllers.dart';

class DailyCheckInStatus extends ConsumerWidget {
  const DailyCheckInStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyCheckInControllerProvider);
    final tokens = context.wenyouTokens;
    final result = state.result;
    final confirmed =
        result != null &&
        state.expectedDate != null &&
        result.date.compareTo(state.expectedDate!) >= 0;
    if (state.phase == DailyCheckInPhase.failed) {
      return WenyouStatusBanner(
        key: const Key('wallet-check-in-status'),
        tone: WenyouStatusTone.error,
        message: '签到失败。',
        detail: wenyouFailureDetail(state.failure),
        action: state.canRetry
            ? TextButton(
                key: const Key('wallet-check-in-retry'),
                onPressed: () => ref
                    .read(dailyCheckInControllerProvider.notifier)
                    .requestRetry(),
                child: const Text('重试签到'),
              )
            : null,
      );
    }
    final message = confirmed
        ? '今日已签到，获得 ${result.rewardAmount} 升温油'
        : state.phase == DailyCheckInPhase.idle
        ? '今日签到待完成'
        : '正在签到…';
    return WenyouPanel(
      key: const Key('wallet-check-in-status'),
      child: Semantics(
        liveRegion: true,
        child: Row(
          children: [
            ExcludeSemantics(
              child: WenyouIcon(
                confirmed
                    ? WenyouIconIds.statusSuccess
                    : WenyouIconIds.statusInfo,
                color: confirmed ? tokens.success : tokens.mutedText,
              ),
            ),
            SizedBox(width: tokens.space12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.wenyouCompactBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
