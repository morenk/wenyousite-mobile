import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/data_saver_preference.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_source_ports.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_playback_coordinator.dart';

class CoverPlaybackScope extends ConsumerStatefulWidget {
  const CoverPlaybackScope({
    required this.child,
    this.navigationChanges,
    super.key,
  });

  final Widget child;
  final Listenable? navigationChanges;

  static CoverPlaybackCoordinator? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_CoverPlaybackInherited>()
      ?.coordinator;

  @override
  ConsumerState<CoverPlaybackScope> createState() => _CoverPlaybackScopeState();
}

class _CoverPlaybackScopeState extends ConsumerState<CoverPlaybackScope>
    with WidgetsBindingObserver {
  late final CoverPlaybackCoordinator _coordinator;
  bool _resumed = true;

  @override
  void initState() {
    super.initState();
    _coordinator = CoverPlaybackCoordinator(
      source: ref.read(coverAnimationSourceProvider),
    );
    _coordinator.source?.changeViewer(
      ref.read(viewerScopeProvider).session.accountId,
      purge: false,
    );
    WidgetsBinding.instance.addObserver(this);
    _resumed =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    widget.navigationChanges?.addListener(_navigationChanged);
  }

  @override
  void didUpdateWidget(covariant CoverPlaybackScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationChanges != widget.navigationChanges) {
      oldWidget.navigationChanges?.removeListener(_navigationChanged);
      widget.navigationChanges?.addListener(_navigationChanged);
    }
  }

  void _navigationChanged() {
    _coordinator.interrupt();
    _coordinator.scrollEnded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    _updateAllowed();
  }

  void _updateAllowed() {
    _coordinator.setAllowed(
      _resumed &&
          !MediaQuery.disableAnimationsOf(context) &&
          !ref.read(dataSaverPreferenceControllerProvider).enabled,
    );
  }

  @override
  void didChangeMetrics() {
    _coordinator.interrupt();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _coordinator.settle();
    });
  }

  @override
  void didHaveMemoryPressure() => _coordinator.source?.releaseMemory();

  @override
  Widget build(BuildContext context) {
    ref.listen(viewerScopeProvider, (previous, next) {
      _coordinator.interrupt();
      _coordinator.source?.changeViewer(
        next.session.accountId,
        // 启动恢复账号前尚未取文件；按持久 owner 校验可复用同账号公开缓存。
        purge:
            previous?.session.accountId != null ||
            previous?.visibilityRevision != next.visibilityRevision,
      );
      _coordinator.settle();
    });
    ref.listen(
      dataSaverPreferenceControllerProvider.select((state) => state.enabled),
      (_, _) => _updateAllowed(),
    );
    _updateAllowed();
    return _CoverPlaybackInherited(
      coordinator: _coordinator,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification ||
              notification is ScrollUpdateNotification ||
              notification is OverscrollNotification) {
            _coordinator.scrollStarted();
          } else if (notification is ScrollEndNotification) {
            _coordinator.scrollEnded();
          }
          return false;
        },
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (_) {
            // 分页只改变内容范围时保留相同中心候选，实际几何变化由重测决定。
            _coordinator.settle();
            return false;
          },
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.navigationChanges?.removeListener(_navigationChanged);
    WidgetsBinding.instance.removeObserver(this);
    _coordinator.dispose();
    super.dispose();
  }
}

class _CoverPlaybackInherited extends InheritedWidget {
  const _CoverPlaybackInherited({
    required this.coordinator,
    required super.child,
  });
  final CoverPlaybackCoordinator coordinator;
  @override
  bool updateShouldNotify(_CoverPlaybackInherited oldWidget) =>
      coordinator != oldWidget.coordinator;
}
