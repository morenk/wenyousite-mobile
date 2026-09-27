import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_feedback_visibility.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_notice_tracker.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_release.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update_notice.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/mobile_update_notice_dialog.dart';

typedef _Attempt = ({MobileUpdateNoticeKind phase, MobileReleaseTarget target});

/// 持续挂载在启动门禁之外；只在实际可用的 Navigator 上取得一次展示机会。
class MobileUpdateNoticeHost extends ConsumerStatefulWidget {
  const MobileUpdateNoticeHost({
    required this.enabled,
    required this.navigatorKey,
    required this.visibility,
    required this.child,
    this.update,
    this.policyChecking = false,
    super.key,
  });

  final bool enabled;
  final GlobalKey<NavigatorState> navigatorKey;
  final WenyouFeedbackVisibility visibility;
  final MobileUpdateInfo? update;
  final bool policyChecking;
  final Widget child;

  @override
  ConsumerState<MobileUpdateNoticeHost> createState() =>
      _MobileUpdateNoticeHostState();
}

class _MobileUpdateNoticeHostState extends ConsumerState<MobileUpdateNoticeHost>
    with WidgetsBindingObserver {
  final _attempted = <_Attempt>{};
  DialogRoute<void>? _route;
  _Attempt? _active;
  bool _rendered = false;
  bool _recorded = false;
  bool _recording = false;
  bool _busy = false;
  bool _scheduled = false;
  bool _foreground = true;
  bool _waitForNextForeground = false;
  bool _recommendationTurn = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    widget.visibility.addListener(_schedule);
    _schedule();
  }

  @override
  void didUpdateWidget(MobileUpdateNoticeHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visibility != widget.visibility) {
      oldWidget.visibility.removeListener(_schedule);
      widget.visibility.addListener(_schedule);
    }
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.update != widget.update ||
        oldWidget.policyChecking != widget.policyChecking) {
      _generation++;
      _schedule();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasForeground = _foreground;
    _foreground = state == AppLifecycleState.resumed;
    _generation++;
    if (_foreground && !wasForeground) {
      _waitForNextForeground = false;
      _attempted.clear();
      _schedule();
    }
  }

  bool get _canOpen =>
      mounted &&
      widget.enabled &&
      !widget.policyChecking &&
      _foreground &&
      !_waitForNextForeground &&
      _route == null &&
      widget.visibility.ready;

  MobileReleaseTarget? get _recommendedTarget {
    final update = widget.update;
    if (update == null || update.isRequired) return null;
    if (update.platform == MobileClientPlatform.android &&
        update.targetVersion == null) {
      return null;
    }
    return (
      platform: update.platform,
      build: update.targetBuild,
      version: update.targetVersion ?? 'TestFlight',
    );
  }

  bool get _activeStillValid =>
      widget.enabled &&
      (_active?.phase != MobileUpdateNoticeKind.beforeUpdate ||
          _active?.target == _recommendedTarget);

  void _schedule() {
    if (!mounted || _scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      if (_route != null) {
        if (!_activeStillValid) {
          final route = _route!;
          if (route.navigator?.mounted == true) {
            route.navigator!.removeRoute(route);
          } else {
            _finishRoute(route);
          }
        } else if (_rendered) {
          _recordVisible();
        }
      }
      if (_canOpen && !_busy) unawaited(_evaluate());
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  Future<void> _evaluate() async {
    _busy = true;
    final generation = _generation;
    try {
      final service = ref.read(mobileUpdateServiceProvider);
      if (service.platform == MobileClientPlatform.unsupported) return;
      final tracker = ref.read(mobileUpdateNoticeTrackerProvider);
      // 每个安全机会读取实际安装身份；不以服务器最新版本推断安装完成。
      final installed = await service.readInstalledApp();
      if (!_canOpen || generation != _generation) return;
      final installedTarget = await tracker.observeInstalled(installed);
      if (!_canOpen || generation != _generation) return;
      final update = widget.update;
      final target = _recommendedTarget;
      if (_recommendationTurn && update != null && target != null) {
        final recommend = await tracker.shouldRecommend(update);
        if (!_canOpen || generation != _generation) return;
        if (recommend) {
          _recommendationTurn = false;
          _show(
            (phase: MobileUpdateNoticeKind.beforeUpdate, target: target),
            title: '温油站有新版本',
            update: update,
          );
          return;
        }
      }
      _recommendationTurn = false;
      if (installedTarget != null) {
        final attempt = (
          phase: MobileUpdateNoticeKind.afterUpdate,
          target: installedTarget,
        );
        if (!_attempted.contains(attempt)) {
          final release = await _loadInstalledRelease(installedTarget);
          if (!_canOpen || generation != _generation) return;
          _attempted.add(attempt);
          if (release != null) {
            final current = await service.readInstalledApp();
            if (!_canOpen || generation != _generation) return;
            if (current.platform != installedTarget.platform ||
                current.build != installedTarget.build ||
                current.version != installedTarget.version) {
              _generation++;
              return;
            }
            _show(
              attempt,
              title: tracker.isInstallationMigration(installedTarget)
                  ? '已安装当前版本'
                  : '已更新',
              preloadedRelease: release,
            );
            return;
          }
        }
      }
      if (update == null || target == null) return;
      final attempt = (
        phase: MobileUpdateNoticeKind.beforeUpdate,
        target: target,
      );
      if (_attempted.contains(attempt)) return;
      final recommend = await tracker.shouldRecommend(update);
      if (!_canOpen || generation != _generation || !recommend) return;
      _show(attempt, title: '温油站有新版本', update: update);
    } on Object {
      // 安装或偏好读取失败时保守跳过本次机会；前台返回可重试，不阻塞应用。
      debugPrint('更新提醒的安装或本机记录读取失败，本次未展示。');
    } finally {
      _busy = false;
      if (mounted && generation != _generation) _schedule();
    }
  }

  Future<MobileRelease?> _loadInstalledRelease(
    MobileReleaseTarget target,
  ) async {
    // 安装版没有下载动作；缺失或失败的空壳不能占用用户每次启动。
    // 临时订阅只覆盖本次读取，下一前台机会重新获取，不把失败记为已读。
    final provider = mobileReleaseProvider(target);
    final subscription = ref.listenManual(provider, (_, _) {});
    try {
      return await ref.read(provider.future);
    } on Object {
      debugPrint('当前安装版说明暂不可用，保留待提示。');
      return null;
    } finally {
      subscription.close();
    }
  }

  void _show(
    _Attempt attempt, {
    required String title,
    MobileUpdateInfo? update,
    MobileRelease? preloadedRelease,
  }) {
    final navigator = widget.navigatorKey.currentState;
    if (navigator == null || !navigator.mounted || !_canOpen) return;
    _active = attempt;
    _rendered = false;
    _recorded = false;
    _attempted.add(attempt);
    final route = DialogRoute<void>(
      context: navigator.context,
      barrierDismissible: true,
      builder: (context) => MobileUpdateNoticeDialog(
        title: title,
        target: attempt.target.platform == MobileClientPlatform.android
            ? attempt.target
            : null,
        update: update,
        preloadedRelease: preloadedRelease,
        onClose: () => Navigator.of(context).pop(),
        onVisible: () {
          if (_active != attempt) return;
          _rendered = true;
          _recordVisible();
        },
      ),
    );
    _route = route;
    unawaited(navigator.push(route).whenComplete(() => _finishRoute(route)));
  }

  void _finishRoute(DialogRoute<void> route, {bool invalidated = false}) {
    if (_route != route) return;
    final interrupted = invalidated || !_activeStillValid;
    if (interrupted && !_recorded) _attempted.remove(_active);
    if (!interrupted && _active?.phase == MobileUpdateNoticeKind.afterUpdate) {
      _recommendationTurn = true;
    }
    _route = null;
    _active = null;
    _rendered = false;
    // 不在关闭回调或退场动画后连续接弹；保留当前任务到下一次前台机会。
    _waitForNextForeground = !interrupted;
  }

  void _recordVisible() {
    final active = _active;
    if (!mounted ||
        !_foreground ||
        widget.policyChecking ||
        !_activeStillValid ||
        !_rendered ||
        _recorded ||
        _recording ||
        active == null ||
        _route?.animation?.status != AnimationStatus.completed ||
        _route?.isCurrent != true) {
      return;
    }
    _recording = true;
    unawaited(_persistPresentation(active));
  }

  Future<void> _persistPresentation(_Attempt active) async {
    final generation = _generation;
    try {
      final installed = await ref
          .read(mobileUpdateServiceProvider)
          .readInstalledApp();
      if (!mounted ||
          _active != active ||
          !_foreground ||
          !_activeStillValid ||
          widget.policyChecking ||
          generation != _generation ||
          _route?.isCurrent != true) {
        return;
      }
      if (active.phase == MobileUpdateNoticeKind.afterUpdate &&
          (installed.platform != active.target.platform ||
              installed.build != active.target.build ||
              installed.version != active.target.version)) {
        final route = _route!;
        _finishRoute(route, invalidated: true);
        if (route.navigator?.mounted == true) {
          route.navigator!.removeRoute(route);
        }
        _schedule();
        return;
      }
      _recorded = true;
      await ref
          .read(mobileUpdateNoticeTrackerProvider)
          .presented(active.phase, active.target);
    } on Object {
      // Tracker 留存本进程收据，后续观察补写；这里不谎称跨进程保存成功。
      debugPrint('更新提醒已展示，本机记录保存失败，待后续补写。');
    } finally {
      _recording = false;
      if (mounted && (_active != active || generation != _generation)) {
        _schedule();
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    widget.visibility.removeListener(_schedule);
    WidgetsBinding.instance.removeObserver(this);
    final route = _route;
    if (route != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (route.navigator?.mounted == true) {
          route.navigator!.removeRoute(route);
        }
      });
    }
    super.dispose();
  }
}
