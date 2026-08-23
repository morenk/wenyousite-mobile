import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/profile_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_controllers.dart';

class AppSessionBootstrap extends ConsumerStatefulWidget {
  const AppSessionBootstrap({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppSessionBootstrap> createState() =>
      _AppSessionBootstrapState();
}

class _AppSessionBootstrapState extends ConsumerState<AppSessionBootstrap> {
  String? _attemptedSession;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    if (!session.isAuthenticated) {
      _attemptedSession = null;
    } else {
      final sessionKey =
          ref.read(sessionControllerProvider.notifier).currentUserId ??
          'authenticated-session';
      if (_attemptedSession != sessionKey) {
        _attemptedSession = sessionKey;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_checkIn(sessionKey));
        });
      }
    }
    return widget.child;
  }

  Future<void> _checkIn(String sessionKey) async {
    final result = await ref
        .read(dailyCheckInControllerProvider.notifier)
        .checkIn();
    if (!mounted || result == null) return;
    ref.invalidate(walletControllerProvider(sessionKey));
    final userId = ref.read(sessionControllerProvider.notifier).currentUserId;
    ref.read(profileCacheInvalidatorProvider)(userId);
    if (!result.claimedNow) return;
    showWenyouSnackBar(
      context,
      '今日签到获得 ${result.rewardAmount} 升温油和 '
      '${result.experienceAwarded} 经验。',
      pacing: WenyouSnackBarPacing.extended,
    );
  }
}
