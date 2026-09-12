import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/background_execution.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/application/background_reminder_preference.dart';
import 'package:wenyousite_mobile/core/application/notification_guidance.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';

/// 非阻断提示，不抢占导航、剪贴板弹窗或正在编辑的页面。
class NotificationPermissionGuidance extends ConsumerStatefulWidget {
  const NotificationPermissionGuidance({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationPermissionGuidance> createState() =>
      _NotificationPermissionGuidanceState();
}

class _NotificationPermissionGuidanceState
    extends ConsumerState<NotificationPermissionGuidance>
    with WidgetsBindingObserver {
  bool _visible = false;
  bool _scheduled = false;
  bool _busy = false;
  bool _permissionAttempted = false;
  String? _failure;
  int? _promptGeneration;
  AppLifecycleState _lifecycle =
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;

  bool get _eligible {
    final preference = ref.read(backgroundReminderPreferenceProvider);
    return ref.read(sessionControllerProvider).isAuthenticated &&
        preference.enabled &&
        !preference.isSaving &&
        ref.read(backgroundExecutionGatewayProvider).isSupported &&
        ref.read(backgroundNotificationGatewayProvider).isSupported;
  }

  bool _sameSession(int generation) =>
      mounted &&
      _eligible &&
      ref.read(sessionControllerProvider).generation == generation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(backgroundReminderPreferenceProvider, (previous, next) {
      if (!next.enabled && _visible) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _lifecycle = state);
  }

  void _schedulePrompt() {
    if (_scheduled || !_eligible || _lifecycle != AppLifecycleState.resumed) {
      return;
    }
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _scheduled = false;
      if (!_eligible || _lifecycle != AppLifecycleState.resumed) return;
      final generation = ref.read(sessionControllerProvider).generation;
      final show = await ref
          .read(notificationGuidanceControllerProvider)
          .claimAutomaticPrompt();
      if (!show || !_sameSession(generation)) return;
      setState(() {
        _promptGeneration = generation;
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    ref.watch(backgroundReminderPreferenceProvider);
    final online = ref.watch(backgroundOnlineControllerProvider);
    if (!online.isLoading) _schedulePrompt();
    final show =
        _visible && _eligible && session.generation == _promptGeneration;
    final requestPermission = online.permissionDenied && !_permissionAttempted;
    final description = requestPermission
        ? '允许通知后，离开温油站也能收到私聊和回复提醒。你可以随时在账号设置中关闭。'
        : online.permissionDenied
        ? '通知尚未开启。如需接收提醒，请在系统设置中允许温油站及“新消息提醒”的通知。'
        : '如需顶部横幅，请开启“新消息提醒”的悬浮通知；声音可选“系统默认”。“后台消息提醒”保持静音即可。';
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          if (show)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * .45,
              ),
              child: SingleChildScrollView(
                child: SafeArea(
                  bottom: false,
                  child: MaterialBanner(
                    key: const Key('notification-permission-guidance'),
                    content: Text(
                      _failure ?? online.failureMessage ?? description,
                    ),
                    forceActionsBelow: true,
                    actions: [
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => setState(() => _visible = false),
                        child: const Text('暂不设置'),
                      ),
                      TextButton(
                        onPressed: _busy || online.isLoading
                            ? null
                            : () => unawaited(_act(requestPermission)),
                        child: Text(requestPermission ? '允许通知' : '去设置'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: show,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _act(bool requestPermission) async {
    if (_busy || !_eligible || _lifecycle != AppLifecycleState.resumed) return;
    final generation = ref.read(sessionControllerProvider).generation;
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      if (requestPermission) {
        await ref
            .read(backgroundOnlineControllerProvider.notifier)
            .requestPermissionFromUser();
        if (_sameSession(generation)) {
          setState(() => _permissionAttempted = true);
        }
      } else {
        await ref
            .read(backgroundExecutionGatewayProvider)
            .openNotificationSettings();
        if (_sameSession(generation)) setState(() => _visible = false);
      }
    } on Object {
      if (_sameSession(generation)) {
        setState(() {
          _failure = '系统通知设置打开失败，请在手机设置中找到温油站后重试。';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
