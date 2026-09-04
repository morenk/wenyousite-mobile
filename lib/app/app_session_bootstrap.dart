import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/profile_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_controllers.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

class AppSessionBootstrap extends ConsumerStatefulWidget {
  const AppSessionBootstrap({
    required this.child,
    this.now,
    this.timerFactory,
    this.retryJitter,
    super.key,
  });

  final Widget child;
  final DateTime Function()? now;
  final Timer Function(Duration delay, void Function() callback)? timerFactory;
  final Duration Function()? retryJitter;

  @override
  ConsumerState<AppSessionBootstrap> createState() =>
      _AppSessionBootstrapState();
}

class _AppSessionBootstrapState extends ConsumerState<AppSessionBootstrap>
    with WidgetsBindingObserver {
  static const _beijingOffset = Duration(hours: 8);
  static const _midnightGuard = Duration(seconds: 1);
  static const _retryDelays = [Duration(seconds: 5), Duration(seconds: 30)];

  AppLifecycleState _lifecycleState =
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
  SessionScope? _activeScope;
  String? _confirmedServerDate;
  String? _retryDate;
  int _nextRetryIndex = 0;
  Timer? _rolloverTimer;
  Timer? _retryTimer;
  _CheckInAttempt? _inFlight;
  _CheckInAttempt? _pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _cancelScheduledWork();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    if (state != AppLifecycleState.resumed) {
      _rolloverTimer?.cancel();
      _rolloverTimer = null;
      _retryTimer?.cancel();
      _retryTimer = null;
      _pending = null;
      return;
    }
    final scope = _activeScope;
    if (scope == null) return;
    _evaluateCurrentDate(scope, resetRetryBudget: true);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final scope = ref.watch(sessionScopeProvider);
    _synchronizeSession(session.isAuthenticated ? scope : null);
    return widget.child;
  }

  void _synchronizeSession(SessionScope? scope) {
    if (_activeScope == scope) return;
    _cancelScheduledWork();
    _activeScope = scope;
    _confirmedServerDate = null;
    _retryDate = null;
    _nextRetryIndex = 0;
    if (scope == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _activeScope != scope) return;
      _evaluateCurrentDate(
        scope,
        resetRetryBudget: true,
        forceInitialCheck: true,
      );
    });
  }

  void _evaluateCurrentDate(
    SessionScope scope, {
    required bool resetRetryBudget,
    bool forceInitialCheck = false,
  }) {
    if (!_canRun(scope)) return;
    final date = _beijingDateKey(_now());
    _scheduleRollover(scope);
    // The local UTC+8 date only decides when to check. A server response for
    // the expected date is the authoritative completion signal.
    if (!forceInitialCheck && _serverDateSatisfies(date)) return;
    _queueAttempt(
      _CheckInAttempt(scope: scope, expectedDate: date),
      resetRetryBudget: resetRetryBudget,
    );
  }

  void _queueAttempt(
    _CheckInAttempt attempt, {
    required bool resetRetryBudget,
  }) {
    if (!_canRun(attempt.scope) || _serverDateSatisfies(attempt.expectedDate)) {
      return;
    }
    if (resetRetryBudget) {
      _retryTimer?.cancel();
      _retryTimer = null;
      _retryDate = attempt.expectedDate;
      _nextRetryIndex = 0;
    }
    if (_inFlight != null) {
      _pending = attempt;
      return;
    }
    _inFlight = attempt;
    unawaited(_performCheckIn(attempt));
  }

  Future<void> _performCheckIn(_CheckInAttempt attempt) async {
    DailyCheckInResult? result;
    ApiFailure? failure;
    try {
      result = await ref
          .read(dailyCheckInControllerProvider.notifier)
          .checkIn();
      if (result == null) {
        failure = ref.read(dailyCheckInControllerProvider).failure;
      }
    } on Object catch (error) {
      failure = error is ApiFailure ? error : null;
    }
    if (!mounted) return;

    _inFlight = null;
    final isCurrentScope = _activeScope == attempt.scope;
    if (isCurrentScope && result != null) {
      _applyResult(attempt.scope, result);
    }

    final pending = _pending;
    _pending = null;
    if (pending != null &&
        _canRun(pending.scope) &&
        !_serverDateSatisfies(pending.expectedDate)) {
      _queueAttempt(pending, resetRetryBudget: true);
      return;
    }
    if (!isCurrentScope) return;

    if (result != null) {
      if (!_serverDateSatisfies(attempt.expectedDate)) {
        _scheduleRetry(attempt, failure: null);
      }
      return;
    }
    if (_isRetryable(failure)) {
      _scheduleRetry(attempt, failure: failure);
    }
  }

  void _applyResult(SessionScope scope, DailyCheckInResult result) {
    _confirmedServerDate = result.date;
    _retryTimer?.cancel();
    _retryTimer = null;
    ref.invalidate(walletControllerProvider(_walletSessionKey(scope)));
    ref.read(profileCacheInvalidatorProvider)(scope.accountId);
    if (!result.claimedNow || _lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    showWenyouSnackBar(
      context,
      result.experienceAwarded > 0
          ? '今日签到获得 ${result.rewardAmount} 升温油和 '
                '${result.experienceAwarded} 经验。'
          : '今日签到获得 ${result.rewardAmount} 升温油。',
      pacing: WenyouSnackBarPacing.extended,
      tone: WenyouSnackBarTone.success,
    );
  }

  void _scheduleRetry(_CheckInAttempt attempt, {ApiFailure? failure}) {
    if (!_canRun(attempt.scope)) return;
    if (_retryDate != attempt.expectedDate) {
      _retryDate = attempt.expectedDate;
      _nextRetryIndex = 0;
    }
    if (_nextRetryIndex >= _retryDelays.length) return;

    // Check-in is naturally idempotent by account and Beijing date, so an
    // ambiguous transport failure is safe to retry within this bounded cycle.
    var delay = _retryDelays[_nextRetryIndex++];
    final retryAfter = failure?.retryAfter;
    if (retryAfter != null && retryAfter.compareTo(delay) > 0) {
      delay = retryAfter;
    }
    delay +=
        widget.retryJitter?.call() ??
        Duration(milliseconds: Random.secure().nextInt(251));
    _retryTimer?.cancel();
    _retryTimer = _createTimer(delay, () {
      _retryTimer = null;
      if (!_canRun(attempt.scope)) return;
      _queueAttempt(attempt, resetRetryBudget: false);
    });
  }

  bool _isRetryable(ApiFailure? failure) {
    if (failure == null) return false;
    if (failure.isExpiredAccessToken) return true;
    if (failure.reason == FailureReason.offline ||
        failure.reason == FailureReason.timeout ||
        failure.reason == FailureReason.rateLimited) {
      return true;
    }
    return failure.effectiveSource == FailureSource.service;
  }

  void _scheduleRollover(SessionScope scope) {
    _rolloverTimer?.cancel();
    _rolloverTimer = null;
    if (!_canRun(scope)) return;
    final now = _now();
    final beijingNow = now.toUtc().add(_beijingOffset);
    final nextMidnightUtc = DateTime.utc(
      beijingNow.year,
      beijingNow.month,
      beijingNow.day + 1,
    ).subtract(_beijingOffset);
    // Avoid racing a server whose clock is a few milliseconds behind the
    // device exactly at the calendar boundary.
    var delay = nextMidnightUtc.difference(now.toUtc()) + _midnightGuard;
    if (delay.isNegative) delay = _midnightGuard;
    _rolloverTimer = _createTimer(delay, () {
      _rolloverTimer = null;
      if (!_canRun(scope)) return;
      _evaluateCurrentDate(scope, resetRetryBudget: true);
    });
  }

  void _cancelScheduledWork() {
    _rolloverTimer?.cancel();
    _rolloverTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _pending = null;
  }

  bool _canRun(SessionScope scope) {
    return mounted &&
        _activeScope == scope &&
        _lifecycleState == AppLifecycleState.resumed;
  }

  bool _serverDateSatisfies(String expectedDate) {
    final date = _confirmedServerDate;
    return date != null && date.compareTo(expectedDate) >= 0;
  }

  DateTime _now() => (widget.now?.call() ?? DateTime.now()).toUtc();

  String _beijingDateKey(DateTime value) {
    final date = value.toUtc().add(_beijingOffset);
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Timer _createTimer(Duration delay, void Function() callback) {
    return widget.timerFactory?.call(delay, callback) ?? Timer(delay, callback);
  }

  String _walletSessionKey(SessionScope scope) {
    return scope.accountId ?? 'authenticated-session';
  }
}

class _CheckInAttempt {
  const _CheckInAttempt({required this.scope, required this.expectedDate});

  final SessionScope scope;
  final String expectedDate;
}
