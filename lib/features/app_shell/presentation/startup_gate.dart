import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref.read(startupControllerProvider.notifier).recheckForUpdate(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startupControllerProvider);
    final updateAction = ref.watch(mobileUpdateControllerProvider);
    return switch (state.status) {
      StartupStatus.ready => widget.child,
      StartupStatus.checking => const _CheckingPage(),
      StartupStatus.recommendedUpdate => _UpdatePage(
        update: state.update!,
        action: _actionFor(updateAction, state.update!),
        isRequired: false,
        onUpdate: () => _startUpdate(state.update!),
        onDismiss: ref
            .read(startupControllerProvider.notifier)
            .dismissRecommendedUpdate,
      ),
      StartupStatus.updateRequired => _UpdatePage(
        update: state.update!,
        action: _actionFor(updateAction, state.update!),
        isRequired: true,
        onUpdate: () => _startUpdate(state.update!),
      ),
      StartupStatus.incompatible => _IncompatiblePage(
        reason: state.reason ?? '当前版本需要更新后继续使用。',
        contractVersion: state.contract?.contractVersion,
        update: state.update,
        action: state.update == null
            ? null
            : _actionFor(updateAction, state.update!),
        onUpdate: state.update == null
            ? null
            : () => _startUpdate(state.update!),
      ),
      StartupStatus.failed => _FailurePage(
        message: state.failure?.userMessage ?? '启动检查失败。',
        requestId: state.failure?.requestId,
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
}

class _CheckingPage extends StatelessWidget {
  const _CheckingPage();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Scaffold(
      body: WenyouPageBody(
        maxWidth: 420,
        child: WenyouPanel(
          child: Semantics(
            label: '正在准备温油站',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: tokens.space16),
                Text('正在连接温油站', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: tokens.space8),
                Text(
                  '正在确认是否可以正常使用。',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdatePage extends StatelessWidget {
  const _UpdatePage({
    required this.update,
    required this.action,
    required this.isRequired,
    required this.onUpdate,
    this.onDismiss,
  });

  final MobileUpdateInfo update;
  final MobileUpdateActionState action;
  final bool isRequired;
  final Future<void> Function() onUpdate;
  final Future<void> Function()? onDismiss;

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
                    isRequired
                        ? WenyouIconIds.actionUpdate
                        : WenyouIconIds.statusNew,
                    size: 32,
                    color: tokens.brandForeground,
                  ),
                ),
              ),
              SizedBox(height: tokens.space16),
              Semantics(
                header: true,
                child: Text(
                  isRequired ? '需要更新后继续' : '温油站有新版本',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(height: tokens.space8),
              Text(
                isRequired ? '当前版本已停止支持。更新后即可继续访问温油站。' : '建议现在更新，以获得最新功能和问题修复。',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
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
              if (!isRequired && onDismiss != null) ...[
                SizedBox(height: tokens.space8),
                SizedBox(
                  width: double.infinity,
                  height: tokens.minimumTouchTarget,
                  child: TextButton(
                    key: const Key('mobile-update-dismiss'),
                    onPressed: action.isBusy ? null : onDismiss,
                    child: const Text('稍后再说'),
                  ),
                ),
              ],
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
    final textStyle = Theme.of(context).textTheme.labelLarge;
    return Semantics(
      label: '当前构建 ${update.currentBuild}，可用构建 ${update.targetBuild}',
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
              Text('可用构建 ${update.targetBuild}', style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncompatiblePage extends StatelessWidget {
  const _IncompatiblePage({
    required this.reason,
    this.contractVersion,
    this.update,
    this.action,
    this.onUpdate,
  });

  final String reason;
  final String? contractVersion;
  final MobileUpdateInfo? update;
  final MobileUpdateActionState? action;
  final Future<void> Function()? onUpdate;

  @override
  Widget build(BuildContext context) {
    final update = this.update;
    final action = this.action;
    final onUpdate = this.onUpdate;
    final statusMessage = action == null ? null : _statusMessage(action);
    return _MessagePage(
      icon: WenyouIconIds.actionUpdate,
      title: '需要升级温油站',
      message: reason,
      detail: contractVersion == null ? null : '兼容信息：$contractVersion',
      action: update == null || action == null || onUpdate == null
          ? null
          : SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (statusMessage != null) ...[
                    WenyouStatusBanner(
                      message: statusMessage,
                      tone: action.status == MobileUpdateActionStatus.failed
                          ? WenyouStatusTone.error
                          : WenyouStatusTone.neutral,
                    ),
                    SizedBox(height: context.wenyouTokens.space12),
                  ],
                  WenyouAsyncPrimaryButton(
                    key: const Key('mobile-update-start'),
                    label: _buttonLabel(update, action),
                    isLoading: action.isBusy,
                    onPressed: update.canStartUpdate ? onUpdate : null,
                    icon: WenyouIconIds.actionUpdate,
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
    this.requestId,
  });

  final String message;
  final String? requestId;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return _MessagePage(
      icon: WenyouIconIds.statusOffline,
      title: '暂时连不上温油站',
      message: message,
      detail: requestId == null ? null : '问题编号：$requestId',
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
