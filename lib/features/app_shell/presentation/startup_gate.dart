import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_feedback_visibility.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/mobile_update_notice_dialog.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/mobile_update_notice_host.dart';

class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({
    required this.child,
    this.waitingRecheckInterval = const Duration(seconds: 60),
    this.navigatorKey,
    this.feedbackVisibility,
    super.key,
  }) : assert(waitingRecheckInterval > Duration.zero);

  final Widget child;
  final Duration waitingRecheckInterval;
  final GlobalKey<NavigatorState>? navigatorKey;
  final WenyouFeedbackVisibility? feedbackVisibility;

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate>
    with WidgetsBindingObserver {
  static const _minimumBrandDuration = Duration(milliseconds: 700);

  Timer? _brandTimer;
  Timer? _waitingRecheckTimer;
  bool _canRevealApp = false;
  bool _isForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _markBrandVisible() {
    if (_brandTimer != null || _canRevealApp) return;
    _brandTimer = Timer(_minimumBrandDuration, () {
      if (!mounted) return;
      setState(() => _canRevealApp = true);
    });
  }

  @override
  void dispose() {
    _brandTimer?.cancel();
    _waitingRecheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isForeground = true;
      unawaited(
        ref.read(startupControllerProvider.notifier).recheckForUpdate(),
      );
      _syncWaitingRecheckTimer(ref.read(startupControllerProvider).status);
    } else {
      _isForeground = false;
      _waitingRecheckTimer?.cancel();
      _waitingRecheckTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startupControllerProvider);
    _syncWaitingRecheckTimer(state.status);
    final content = switch (state.status) {
      StartupStatus.ready when !_canRevealApp => StartupCheckingPage(
        onVisible: _markBrandVisible,
      ),
      StartupStatus.ready => widget.child,
      StartupStatus.checking => StartupCheckingPage(
        onVisible: _markBrandVisible,
      ),
      StartupStatus.updateRequired => _UpdatePage(update: state.update!),
      StartupStatus.updateWaiting => _UpdateWaitingPage(
        update: state.update,
        isRechecking: state.isRechecking,
        recheckMessage: state.recheckMessage,
        onRecheck: () => ref
            .read(startupControllerProvider.notifier)
            .recheckForUpdate(showFailure: true),
      ),
      StartupStatus.failed => _FailurePage(
        message: state.failure?.userMessage ?? '启动检查失败。',
        detail: wenyouFailureDetail(state.failure),
        onRetry: ref.read(startupControllerProvider.notifier).check,
      ),
    };
    final navigatorKey = widget.navigatorKey;
    final visibility = widget.feedbackVisibility;
    if (navigatorKey == null || visibility == null) return content;
    return MobileUpdateNoticeHost(
      enabled: state.status == StartupStatus.ready && _canRevealApp,
      policyChecking: state.isRechecking,
      navigatorKey: navigatorKey,
      visibility: visibility,
      update: state.update,
      child: content,
    );
  }

  void _syncWaitingRecheckTimer(StartupStatus status) {
    if (!_isForeground || status != StartupStatus.updateWaiting) {
      _waitingRecheckTimer?.cancel();
      _waitingRecheckTimer = null;
      return;
    }
    _waitingRecheckTimer ??= Timer.periodic(
      widget.waitingRecheckInterval,
      (_) => unawaited(
        ref.read(startupControllerProvider.notifier).recheckForUpdate(),
      ),
    );
  }
}

class StartupCheckingPage extends StatelessWidget {
  const StartupCheckingPage({this.onVisible, super.key});

  final VoidCallback? onVisible;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.space24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
                return const SizedBox.shrink();
              }
              final onVisible = this.onVisible;
              if (onVisible != null) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => onVisible(),
                );
              }
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Semantics(
                      container: true,
                      label: '正在准备温油站',
                      child: Column(
                        key: const Key('startup-brand-content'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const WenyouBrandMark.decorative(
                            key: Key('startup-brand-mark'),
                            size: WenyouBrandContract.startupMarkSize,
                          ),
                          SizedBox(height: tokens.space16),
                          Text(
                            WenyouBrandContract.name,
                            style: Theme.of(context).textTheme.wenyouPageTitle
                                .copyWith(color: tokens.brandForeground),
                          ),
                          SizedBox(height: tokens.space8),
                          Text(
                            WenyouBrandContract.tagline,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .wenyouSubsectionTitle
                                .copyWith(color: tokens.brandForeground),
                          ),
                          SizedBox(height: tokens.space32),
                          CircularProgressIndicator(
                            color: tokens.brandForeground,
                          ),
                          SizedBox(height: tokens.space12),
                          Text(
                            '正在连接温油站',
                            style: Theme.of(context).textTheme.wenyouStatusTitle
                                .copyWith(color: tokens.brandForeground),
                          ),
                          SizedBox(height: tokens.space8),
                          Text(
                            '正在确认是否可以正常使用。',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.wenyouCompactBody
                                .copyWith(color: tokens.brandForeground),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _UpdatePage extends StatelessWidget {
  const _UpdatePage({required this.update});
  final MobileUpdateInfo update;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Scaffold(
      body: SafeArea(
        child: MobileUpdateNoticeDialog(
          title: '需要更新后继续',
          update: update,
          target:
              update.platform == MobileClientPlatform.android &&
                  update.targetVersion != null
              ? (
                  platform: update.platform,
                  build: update.targetBuild,
                  version: update.targetVersion!,
                )
              : null,
        ),
      ),
    ),
  );
}

class _UpdateWaitingPage extends StatelessWidget {
  const _UpdateWaitingPage({
    required this.isRechecking,
    required this.onRecheck,
    this.update,
    this.recheckMessage,
  });

  final bool isRechecking;
  final Future<void> Function() onRecheck;
  final MobileUpdateInfo? update;
  final String? recheckMessage;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return _MessagePage(
      icon: WenyouIconIds.actionUpdate,
      title: '新版正在准备中',
      message: '当前版本暂时无法继续使用。新版正在发布，请稍后再试。',
      detail: '新版准备好后会自动出现更新入口。',
      action: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (update != null) ...[
              Text(
                '当前 ${update!.currentVersion}+${update!.currentBuild}',
                style: Theme.of(
                  context,
                ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
              ),
              SizedBox(height: tokens.space12),
            ],
            if (recheckMessage != null) ...[
              WenyouStatusBanner(
                message: recheckMessage!,
                tone: WenyouStatusTone.error,
              ),
              SizedBox(height: tokens.space12),
            ],
            WenyouAsyncPrimaryButton(
              key: const Key('mobile-update-recheck'),
              label: '重新检查',
              loadingLabel: '正在检查新版',
              icon: WenyouIconIds.actionRefresh,
              isLoading: isRechecking,
              onPressed: onRecheck,
            ),
          ],
        ),
      ),
    );
  }
}

class _FailurePage extends StatelessWidget {
  const _FailurePage({
    required this.message,
    required this.onRetry,
    this.detail,
  });

  final String message;
  final String? detail;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return _MessagePage(
      icon: WenyouIconIds.statusOffline,
      title: '暂时连不上温油站',
      message: message,
      detail: detail,
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const WenyouIcon(WenyouIconIds.actionRefresh),
        label: const Text('重试'),
      ),
    );
  }
}

class _MessagePage extends StatelessWidget {
  const _MessagePage({
    required this.icon,
    required this.title,
    required this.message,
    this.detail,
    this.action,
  });

  final String icon;
  final String title;
  final String message;
  final String? detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WenyouPageBody(
        maxWidth: 520,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: icon,
            title: title,
            message: message,
            detail: detail,
            action: action,
          ),
        ),
      ),
    );
  }
}
