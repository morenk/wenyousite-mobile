import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

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
  // ponytail: process-only fingerprint dedupes prompts; use native clipboard
  // change IDs only if identical re-copies must be distinguished.
  int? _lastClipboardFingerprint;
  int _readEpoch = 0;
  bool _promptOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_readClipboard(prompt: true)),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      unawaited(_readClipboard(prompt: false));
    } else if (state == AppLifecycleState.resumed) {
      unawaited(_readClipboard(prompt: true));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Future<void> _readClipboard({required bool prompt}) async {
    final epoch = ++_readEpoch;
    final String? text;
    try {
      text = (await Clipboard.getData(Clipboard.kTextPlain))?.text?.trim();
    } on Object {
      return;
    }
    if (!mounted || epoch != _readEpoch) return;
    final fingerprint = text == null ? null : Object.hash(text.length, text);
    if (!prompt) {
      _lastClipboardFingerprint = fingerprint;
      return;
    }
    if (text == null ||
        text.isEmpty ||
        fingerprint == _lastClipboardFingerprint ||
        _promptOpen) {
      return;
    }
    final reference = parseInternalReference(text);
    if (reference == null || !_shouldOffer(reference.kind)) {
      _lastClipboardFingerprint = fingerprint;
      return;
    }

    final router = ref.read(appRouterProvider);
    if (router.routerDelegate.currentConfiguration.uri == reference.location) {
      _lastClipboardFingerprint = fingerprint;
      return;
    }
    final navigatorContext = router.routerDelegate.navigatorKey.currentContext;
    if (navigatorContext == null || !navigatorContext.mounted) return;

    _lastClipboardFingerprint = fingerprint;
    _promptOpen = true;
    final accepted = await showDialog<bool>(
      context: navigatorContext,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          reference.kind == InternalReferenceKind.invite
              ? '打开私密主题邀请？'
              : '打开楼层链接？',
        ),
        content: Text(
          reference.kind == InternalReferenceKind.invite
              ? '剪贴板中有一个私密主题邀请链接，是否前往查看？'
              : '剪贴板中有一个楼层链接，是否前往查看？',
        ),
        actions: [
          TextButton(
            key: const Key('clipboard-navigation-dismiss'),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('暂不'),
          ),
          FilledButton(
            key: const Key('clipboard-navigation-open'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('前往查看'),
          ),
        ],
      ),
    );
    _promptOpen = false;
    if (accepted == true && mounted) {
      router.go(reference.location.toString());
    }
  }
}

bool _shouldOffer(InternalReferenceKind kind) =>
    kind == InternalReferenceKind.floor ||
    kind == InternalReferenceKind.reply ||
    kind == InternalReferenceKind.invite;
