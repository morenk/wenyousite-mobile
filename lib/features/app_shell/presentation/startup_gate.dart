import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({
    required this.child,
    this.waitingRecheckInterval = const Duration(seconds: 60),
    super.key,
  }) : assert(waitingRecheckInterval > Duration.zero);

  final Widget child;
  final Duration waitingRecheckInterval;

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
    final updateAction = ref.watch(mobileUpdateControllerProvider);
    _syncWaitingRecheckTimer(state.status);
    return switch (state.status) {
      StartupStatus.ready when !_canRevealApp => StartupCheckingPage(
        onVisible: _markBrandVisible,
      ),
      StartupStatus.ready => _ReadyContent(
        update: state.update,
        action: state.update == null
            ? const MobileUpdateActionState()
            : _actionFor(updateAction, state.update!),
        onUpdate: state.update == null
            ? null
            : () => _startUpdate(state.update!),
        onDismiss: state.update == null
            ? null
            : ref
                  .read(startupControllerProvider.notifier)
                  .dismissRecommendedUpdate,
        child: widget.child,
      ),
      StartupStatus.checking => StartupCheckingPage(
        onVisible: _markBrandVisible,
      ),
      StartupStatus.updateRequired => _UpdatePage(
        update: state.update!,
        action: _actionFor(updateAction, state.update!),
        onUpdate: () => _startUpdate(state.update!),
      ),
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
  }

  MobileUpdateActionState _actionFor(
    MobileUpdateActionState action,
    MobileUpdateInfo update,
  ) {
    if (action.targetBuild == null ||
        action.targetBuild == update.targetBuild) {
      return action;
    }
    return const MobileUpdateActionState();
  }

  Future<void> _startUpdate(MobileUpdateInfo update) {
    return ref.read(mobileUpdateControllerProvider.notifier).start(update);
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

class _ReadyContent extends StatelessWidget {
  const _ReadyContent({
    required this.child,
    required this.update,
    required this.action,
    required this.onUpdate,
    required this.onDismiss,
  });

  final Widget child;
  final MobileUpdateInfo? update;
  final MobileUpdateActionState action;
  final Future<void> Function()? onUpdate;
  final Future<void> Function()? onDismiss;

  @override
  Widget build(BuildContext context) {
    final update = this.update;
    final onUpdate = this.onUpdate;
    final onDismiss = this.onDismiss;
    if (update == null || onUpdate == null || onDismiss == null) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: EdgeInsets.all(context.wenyouTokens.space12),
                  child: _RecommendedUpdateBanner(
                    update: update,
                    action: action,
                    onUpdate: onUpdate,
                    onDismiss: onDismiss,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendedUpdateBanner extends StatelessWidget {
  const _RecommendedUpdateBanner({
    required this.update,
    required this.action,
    required this.onUpdate,
    required this.onDismiss,
  });

  final MobileUpdateInfo update;
  final MobileUpdateActionState action;
  final Future<void> Function() onUpdate;
  final Future<void> Function() onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final statusMessage = _statusMessage(action);
    return Material(
      elevation: 4,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(tokens.radius12),
      child: WenyouStatusBanner(
        key: const Key('recommended-update-banner'),
        message: '温油站有新版本',
        detail:
            statusMessage ??
            '当前 ${update.currentVersion}+${update.currentBuild}，可更新到${_targetLabel(update)}。',
        tone: action.status == MobileUpdateActionStatus.failed
            ? WenyouStatusTone.error
            : WenyouStatusTone.accent,
        action: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (action.status == MobileUpdateActionStatus.downloading &&
                update.platform == MobileClientPlatform.android) ...[
              Semantics(
                label: action.progress == null
                    ? '正在下载安装包'
                    : '安装包下载进度 ${(action.progress! * 100).round()}%',
                child: LinearProgressIndicator(value: action.progress),
              ),
              SizedBox(height: tokens.space8),
            ],
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: tokens.space8,
              runSpacing: tokens.space4,
              children: [
                TextButton(
                  key: const Key('mobile-update-dismiss'),
                  onPressed: action.isBusy ? null : onDismiss,
                  child: const Text('稍后再说'),
                ),
                WenyouAsyncButton(
                  key: const Key('mobile-update-start'),
                  label: _buttonLabel(update, action),
                  loadingLabel: update.platform == MobileClientPlatform.android
                      ? _busyLabel(action)
                      : '正在打开 TestFlight',
                  icon: update.platform == MobileClientPlatform.android
                      ? WenyouIconIds.actionDownload
                      : WenyouIconIds.actionOpenExternal,
                  isLoading: action.isBusy,
                  onPressed: onUpdate,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdatePage extends StatelessWidget {
  const _UpdatePage({
    required this.update,
    required this.action,
    required this.onUpdate,
  });

  final MobileUpdateInfo update;
  final MobileUpdateActionState action;
  final Future<void> Function() onUpdate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final statusMessage = _statusMessage(action);
    return Scaffold(
      body: WenyouPageBody(
        maxWidth: 520,
        child: WenyouPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.accentedBackground,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 64,
                  child: WenyouIcon(
                    WenyouIconIds.actionUpdate,
                    size: 32,
                    color: tokens.brandForeground,
                  ),
                ),
              ),
              SizedBox(height: tokens.space16),
              Semantics(
                header: true,
                child: Text(
                  '需要更新后继续',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.wenyouStatusTitle,
                ),
              ),
              SizedBox(height: tokens.space8),
              Text(
                '当前版本已停止支持。更新后即可继续访问温油站。',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.wenyouCompactBody.copyWith(color: tokens.mutedText),
              ),
              SizedBox(height: tokens.space20),
              _BuildTransition(update: update),
              if (statusMessage != null) ...[
                SizedBox(height: tokens.space16),
                WenyouStatusBanner(
                  message: statusMessage,
                  detail: action.status == MobileUpdateActionStatus.failed
                      ? '你可以保留在此页面并重新尝试。'
                      : null,
                  tone: action.status == MobileUpdateActionStatus.failed
                      ? WenyouStatusTone.error
                      : WenyouStatusTone.neutral,
                ),
              ],
              if (action.status == MobileUpdateActionStatus.downloading &&
                  update.platform == MobileClientPlatform.android) ...[
                SizedBox(height: tokens.space12),
                Semantics(
                  label: action.progress == null
                      ? '正在下载安装包'
                      : '安装包下载进度 ${(action.progress! * 100).round()}%',
                  child: LinearProgressIndicator(value: action.progress),
                ),
              ],
              if (!update.canStartUpdate) ...[
                SizedBox(height: tokens.space16),
                const WenyouStatusBanner(
                  message: '获取新版本下载地址失败',
                  detail: '请稍后重新打开应用；若持续出现，请联系开发者。',
                  tone: WenyouStatusTone.error,
                ),
              ],
              SizedBox(height: tokens.space20),
              WenyouAsyncPrimaryButton(
                key: const Key('mobile-update-start'),
                label: _buttonLabel(update, action),
                loadingLabel: update.platform == MobileClientPlatform.android
                    ? _busyLabel(action)
                    : '正在打开 TestFlight',
                icon: update.platform == MobileClientPlatform.android
                    ? WenyouIconIds.actionDownload
                    : WenyouIconIds.actionOpenExternal,
                isLoading: action.isBusy,
                onPressed: update.canStartUpdate ? onUpdate : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuildTransition extends StatelessWidget {
  const _BuildTransition({required this.update});

  final MobileUpdateInfo update;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final textStyle = Theme.of(context).textTheme.wenyouLabel;
    return Semantics(
      label:
          '当前 ${update.currentVersion}+${update.currentBuild}，可用${_targetLabel(update)}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.softPanel,
          borderRadius: BorderRadius.circular(tokens.radius16),
          border: Border.all(color: tokens.border),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space16,
            vertical: tokens.space12,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: tokens.space12,
            runSpacing: tokens.space8,
            children: [
              Text(
                '当前 ${update.currentVersion}+${update.currentBuild}',
                style: textStyle,
              ),
              WenyouIcon(
                WenyouIconIds.navigationForward,
                size: 20,
                color: tokens.brandForeground,
              ),
              Text('可用${_targetLabel(update)}', style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
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

String _buttonLabel(MobileUpdateInfo update, MobileUpdateActionState action) {
  if (action.status == MobileUpdateActionStatus.permissionRequired) {
    return '权限已开启，继续安装';
  }
  if (action.status == MobileUpdateActionStatus.failed) return '重新尝试';
  if (update.platform == MobileClientPlatform.android) return '下载并安装';
  return '前往 TestFlight';
}

String _targetLabel(MobileUpdateInfo update) {
  final version = update.targetVersion;
  return version == null
      ? '构建 ${update.targetBuild}'
      : '$version+${update.targetBuild}';
}

String? _statusMessage(MobileUpdateActionState action) {
  return switch (action.status) {
    MobileUpdateActionStatus.idle => null,
    MobileUpdateActionStatus.checking => '正在核对安装包发布信息。',
    MobileUpdateActionStatus.downloading => null,
    MobileUpdateActionStatus.verifying => '正在校验安装包完整性。',
    MobileUpdateActionStatus.installing => '安装包已验证，正在打开系统安装器。',
    MobileUpdateActionStatus.openingExternalPage => '正在打开 TestFlight。',
    MobileUpdateActionStatus.permissionRequired =>
      '已打开系统设置。允许温油站“安装未知应用”后，返回此页继续安装。',
    MobileUpdateActionStatus.installerOpened => '系统安装器已打开，请按提示完成更新。',
    MobileUpdateActionStatus.externalPageOpened =>
      'TestFlight 已打开，请在那里完成更新后返回。',
    MobileUpdateActionStatus.failed => action.message ?? '更新失败，请重试。',
  };
}

String _busyLabel(MobileUpdateActionState action) {
  return switch (action.status) {
    MobileUpdateActionStatus.checking => '正在检查更新',
    MobileUpdateActionStatus.verifying => '正在校验安装包',
    MobileUpdateActionStatus.installing => '正在打开安装器',
    _ => '正在下载安装包',
  };
}
