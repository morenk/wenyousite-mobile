import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';
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
  String? _activeEntryToken;
  String? _lastObservedToken;
  String? _lastObservedFingerprint;
  HandledClipboardNavigation? _handled;
  Future<HandledClipboardNavigation?>? _handledLoad;

  @override
  void initState() {
    super.initState();
    _lifecycleState = WidgetsBinding.instance.lifecycleState;
    WidgetsBinding.instance.addObserver(this);
    _readClipboardAfterFrame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final previous = _lifecycleState;
    _lifecycleState = state;
    if (state == AppLifecycleState.inactive &&
        previous == AppLifecycleState.resumed) {
      unawaited(_captureActiveClipboardChange());
    } else if (state == AppLifecycleState.resumed) {
      _readClipboardAfterFrame();
    }
  }

  void _readClipboardAfterFrame() {
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) => unawaited(_scanClipboard()));
    binding.scheduleFrame();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Future<void> _scanClipboard() async {
    if (_promptOpen) return;
    final epoch = ++_readEpoch;
    final gateway = ref.read(clipboardNavigationGatewayProvider);
    final changeToken = await gateway.readChangeToken();
    final handled = await _readHandled();
    if (!mounted || epoch != _readEpoch) return;

    _activeEntryToken = changeToken;
    if (changeToken != null &&
        (changeToken == handled?.changeToken ||
            changeToken == _lastObservedToken)) {
      _lastObservedToken = changeToken;
      return;
    }

    final snapshot = await gateway.readSnapshot();
    if (!mounted || epoch != _readEpoch || snapshot == null) return;
    final normalizedText = snapshot.text.trim();
    if (normalizedText.isEmpty) return;
    final effectiveSnapshot = ClipboardNavigationSnapshot(
      text: normalizedText,
      changeToken: snapshot.changeToken ?? changeToken,
    );
    final fingerprint = _fingerprint(normalizedText);
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
      _activeEntryToken = effectiveSnapshot.changeToken;
      _rememberObserved(effectiveSnapshot, fingerprint);
      return;
    }

    final router = ref.read(appRouterProvider);
    if (router.routerDelegate.currentConfiguration.uri == reference.location) {
      await _rememberHandled(effectiveSnapshot, fingerprint);
      return;
    }
    final navigatorContext = router.routerDelegate.navigatorKey.currentContext;
    if (navigatorContext == null || !navigatorContext.mounted) return;

    _activeEntryToken = effectiveSnapshot.changeToken;
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
          await _rememberHandled(effectiveSnapshot, fingerprint);
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

  Future<void> _captureActiveClipboardChange() async {
    if (_promptOpen || _activeEntryToken == null) return;
    final epoch = ++_readEpoch;
    final gateway = ref.read(clipboardNavigationGatewayProvider);
    final changeToken = await gateway.readChangeToken();
    if (!mounted ||
        epoch != _readEpoch ||
        changeToken == null ||
        changeToken == _activeEntryToken) {
      return;
    }
    final snapshot = await gateway.readSnapshot();
    if (!mounted || epoch != _readEpoch || snapshot == null) return;
    final normalizedText = snapshot.text.trim();
    if (normalizedText.isEmpty ||
        parseInternalReference(normalizedText) == null) {
      return;
    }
    final effectiveSnapshot = ClipboardNavigationSnapshot(
      text: normalizedText,
      changeToken: snapshot.changeToken ?? changeToken,
    );
    await _rememberHandled(effectiveSnapshot, _fingerprint(normalizedText));
  }

  Future<HandledClipboardNavigation?> _readHandled() {
    return _handledLoad ??= _loadHandled();
  }

  Future<HandledClipboardNavigation?> _loadHandled() async {
    try {
      _handled = await ref.read(handledClipboardNavigationStoreProvider).read();
    } on Object {
      _handled = null;
    }
    return _handled;
  }

  Future<void> _rememberHandled(
    ClipboardNavigationSnapshot snapshot,
    String fingerprint,
  ) async {
    final value = HandledClipboardNavigation(
      changeToken: snapshot.changeToken,
      fingerprint: fingerprint,
    );
    _handled = value;
    _handledLoad = Future.value(value);
    _rememberObserved(snapshot, fingerprint);
    try {
      await ref.read(handledClipboardNavigationStoreProvider).write(value);
    } on Object {
      // Keep the choice for this process when preference storage is unavailable.
      // A storage failure must not trap the user in the navigation dialog.
    }
  }

  void _rememberObserved(
    ClipboardNavigationSnapshot snapshot,
    String fingerprint,
  ) {
    _lastObservedToken = snapshot.changeToken;
    _lastObservedFingerprint = fingerprint;
  }

  String _fingerprint(String value) {
    return sha256.convert(utf8.encode(value)).toString();
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
