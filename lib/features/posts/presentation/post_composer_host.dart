import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_page_transitions.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_draft.dart';
import 'package:wenyousite_mobile/features/posts/application/post_publish_draft.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_expansion.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';

class PostComposerRouteHost extends StatefulWidget {
  const PostComposerRouteHost({
    required this.target,
    required this.baseline,
    this.onDraftChanged,
    this.supportsRpIdentity = false,
    this.publishDraft,
    this.initialInsertion,
    super.key,
  });

  final PostComposerTarget target;
  final PostComposerBaseline baseline;
  final bool supportsRpIdentity;
  final PostPublishDraft? publishDraft;
  final String? initialInsertion;
  final ValueChanged<PostComposerDraft?>? onDraftChanged;

  @override
  State<PostComposerRouteHost> createState() => _PostComposerRouteHostState();
}

class _PostComposerRouteHostState extends State<PostComposerRouteHost> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _composerKey = GlobalKey<PostComposerSheetState>();
  ModalRoute<Object?>? _outerRoute;
  NavigatorState? _outerNavigator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _outerRoute ??= ModalRoute.of(context);
    _outerNavigator ??= Navigator.of(context);
  }

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) return;
      final navigator = _navigatorKey.currentState;
      if (navigator != null && navigator.canPop()) {
        navigator.pop();
        return;
      }
      _composerKey.currentState?.handleSystemBack();
    },
    child: Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) => wenyouSheetContentRoute<void>(
        settings: settings,
        builder: (context) => ExpandablePostComposer(
          supportsRpIdentity: widget.supportsRpIdentity,
          publishDraft: widget.publishDraft,
          initialInsertion: widget.initialInsertion,
          target: widget.target,
          baseline: widget.baseline,
          onDraftChanged: widget.onDraftChanged,
          composerKey: _composerKey,
          onRequestClose: () =>
              _composerKey.currentState?.requestCloseFromOutside(),
          onClose: _close,
        ),
      ),
    ),
  );

  void _close(PostItem? result) {
    final route = _outerRoute;
    final navigator = _outerNavigator;
    if (route == null || navigator == null || !route.isActive) return;
    navigator.removeRoute<Object?>(route, result);
  }
}
