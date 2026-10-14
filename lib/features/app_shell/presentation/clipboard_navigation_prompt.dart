import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_feedback_visibility.dart';
import 'package:wenyousite_mobile/features/app_shell/application/clipboard_navigation_coordinator.dart';
import 'package:wenyousite_mobile/features/app_shell/application/clipboard_navigation_ports.dart';

class ClipboardNavigationPrompt extends ConsumerStatefulWidget {
  const ClipboardNavigationPrompt({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ClipboardNavigationPrompt> createState() =>
      _ClipboardNavigationPromptState();
}

class _ClipboardNavigationPromptState
    extends ConsumerState<ClipboardNavigationPrompt>
    with WidgetsBindingObserver {
  int _readEpoch = 0;
  bool _promptOpen = false;
  AppLifecycleState? _lifecycleState;
  String? _lastObservedToken;
  String? _lastObservedFingerprint;
  late final WenyouFeedbackVisibility _visibility;
  bool _waitingForVisibility = false;

  @override
  void initState() {
    super.initState();
    _lifecycleState = WidgetsBinding.instance.lifecycleState;
    WidgetsBinding.instance.addObserver(this);
    _visibility = ref.read(feedbackVisibilityProvider);
    _visibility.addListener(_retryWhenVisible);
    _readClipboardAfterFrame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _visibility.removeListener(_retryWhenVisible);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    if (state == AppLifecycleState.resumed) {
      _readClipboardAfterFrame();
    } else {
      _readEpoch += 1;
    }
  }

  void _readClipboardAfterFrame() {
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) => unawaited(_scanClipboard()));
    binding.scheduleFrame();
  }

  void _retryWhenVisible() {
    if (_waitingForVisibility &&
        _visibility.ready &&
        (_lifecycleState == null ||
            _lifecycleState == AppLifecycleState.resumed)) {
      _waitingForVisibility = false;
      _readClipboardAfterFrame();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Future<void> _scanClipboard() async {
    if (!mounted ||
        _promptOpen ||
        (_lifecycleState != null &&
            _lifecycleState != AppLifecycleState.resumed)) {
      return;
    }
    final epoch = ++_readEpoch;
    final coordinator = ref.read(clipboardNavigationCoordinatorProvider);
    await coordinator.ready();
    if (!mounted || epoch != _readEpoch) return;
    final revision = coordinator.revision;
    final gateway = ref.read(clipboardNavigationGatewayProvider);
    final changeToken = await gateway.readChangeToken();
    if (!mounted || epoch != _readEpoch || revision != coordinator.revision) {
      return;
    }
    final handled = coordinator.handled;
    if (changeToken != null &&
        (changeToken == handled?.changeToken ||
            changeToken == _lastObservedToken)) {
      _lastObservedToken = changeToken;
      return;
    }

    final snapshot = await gateway.readSnapshot();
    if (!mounted ||
        epoch != _readEpoch ||
        revision != coordinator.revision ||
        snapshot == null) {
      return;
    }
    final normalizedText = snapshot.text.trim();
    if (normalizedText.isEmpty) return;
    final effectiveSnapshot = ClipboardNavigationSnapshot(
      text: normalizedText,
      changeToken: snapshot.changeToken ?? changeToken,
    );
    final fingerprint = ClipboardNavigationCoordinator.fingerprint(
      normalizedText,
    );
    if (await coordinator.resolveOwnReceipt(
      effectiveSnapshot,
      expectedRevision: revision,
    )) {
      _rememberObserved(effectiveSnapshot, fingerprint);
      return;
    }
    if (!mounted || epoch != _readEpoch || revision != coordinator.revision) {
      return;
    }
    if ((effectiveSnapshot.changeToken != null &&
            (effectiveSnapshot.changeToken == handled?.changeToken ||
                effectiveSnapshot.changeToken == _lastObservedToken)) ||
        (effectiveSnapshot.changeToken == null &&
            (fingerprint == handled?.fingerprint ||
                fingerprint == _lastObservedFingerprint))) {
      _rememberObserved(effectiveSnapshot, fingerprint);
      return;
    }
    final reference = parseInternalReference(normalizedText);
    if (reference == null) {
      _rememberObserved(effectiveSnapshot, fingerprint);
      return;
    }

    final router = ref.read(appRouterProvider);
    if (router.routerDelegate.currentConfiguration.uri == reference.location) {
      await coordinator.rememberIfCurrent(
        effectiveSnapshot,
        expectedRevision: revision,
      );
      return;
    }
    final navigatorContext = router.routerDelegate.navigatorKey.currentContext;
    if (navigatorContext == null || !navigatorContext.mounted) return;
    // 更新提醒等模态占用焦点时暂缓；退场后重新读剪贴板，不叠加或丢弃复制事件。
    if (!_visibility.ready) {
      _waitingForVisibility = true;
      return;
    }

    _rememberObserved(effectiveSnapshot, fingerprint);
    _promptOpen = true;
    final isInvite = reference.kind == InternalReferenceKind.invite;
    final isThread =
        reference.kind == InternalReferenceKind.thread ||
        reference.kind == InternalReferenceKind.subthread;
    final accepted = await showDialog<bool>(
      context: navigatorContext,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (dialogContext) => _ClipboardNavigationDialog(
        title: isInvite
            ? '打开私密主题邀请？'
            : isThread
            ? '打开主题链接？'
            : '打开楼层链接？',
        message: isInvite
            ? '剪贴板中有一个私密主题邀请链接，是否前往查看？'
            : isThread
            ? '剪贴板中有一个主题链接，是否前往查看？'
            : '剪贴板中有一个楼层链接，是否前往查看？',
        onDecision: (decision) async {
          await coordinator.rememberIfCurrent(
            effectiveSnapshot,
            expectedRevision: revision,
          );
          if (dialogContext.mounted) {
            Navigator.pop(dialogContext, decision);
          }
        },
      ),
    );
    _promptOpen = false;
    if (accepted == true && mounted) {
      router.go(reference.location.toString());
    }
    if (!mounted) return;
    _readClipboardAfterFrame();
  }

  void _rememberObserved(
    ClipboardNavigationSnapshot snapshot,
    String fingerprint,
  ) {
    _lastObservedToken = snapshot.changeToken;
    _lastObservedFingerprint = fingerprint;
  }
}

class _ClipboardNavigationDialog extends StatefulWidget {
  const _ClipboardNavigationDialog({
    required this.title,
    required this.message,
    required this.onDecision,
  });

  final String title;
  final String message;
  final Future<void> Function(bool accepted) onDecision;

  @override
  State<_ClipboardNavigationDialog> createState() =>
      _ClipboardNavigationDialogState();
}

class _ClipboardNavigationDialogState
    extends State<_ClipboardNavigationDialog> {
  bool _busy = false;

  Future<void> _decide(bool accepted) async {
    if (_busy) return;
    setState(() => _busy = true);
    await widget.onDecision(accepted);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_decide(false));
      },
      child: AlertDialog(
        title: Text(widget.title),
        content: Text(widget.message),
        actions: [
          TextButton(
            key: const Key('clipboard-navigation-dismiss'),
            onPressed: _busy ? null : () => _decide(false),
            child: const Text('暂不'),
          ),
          FilledButton(
            key: const Key('clipboard-navigation-open'),
            onPressed: _busy ? null : () => _decide(true),
            child: const Text('前往查看'),
          ),
        ],
      ),
    );
  }
}
