import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_draft.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

typedef PostComposerOpeningBuilder =
    Widget Function(BuildContext context, PreparedPostComposer composer);

class PostComposerOpening extends ConsumerStatefulWidget {
  const PostComposerOpening({
    required this.target,
    required this.builder,
    this.initialDraft,
    this.onDraftChanged,
    super.key,
  });

  final PostComposerTarget target;
  final PostComposerDraft? initialDraft;
  final ValueChanged<PostComposerDraft?>? onDraftChanged;
  final PostComposerOpeningBuilder builder;

  @override
  ConsumerState<PostComposerOpening> createState() =>
      _PostComposerOpeningState();
}

class _PostComposerOpeningState extends ConsumerState<PostComposerOpening> {
  PreparedPostComposer? _prepared;
  PostComposerBaseline? _divergedBaseline;
  ApiFailure? _failure;
  late final Object _openedSessionScope;
  ModalRoute<Object?>? _outerRoute;
  NavigatorState? _outerNavigator;
  var _loading = true;
  var _epoch = 0;

  @override
  void initState() {
    super.initState();
    _openedSessionScope = ref.read(sessionScopeProvider);
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _outerRoute ??= ModalRoute.of(context);
    _outerNavigator ??= Navigator.of(context);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionScopeProvider, (previous, next) {
      if (next == _openedSessionScope) return;
      final route = _outerRoute;
      final navigator = _outerNavigator;
      if (route != null && navigator != null && route.isActive) {
        navigator.removeRoute<Object?>(route);
      }
    });
    final prepared = _prepared;
    if (prepared != null) return widget.builder(context, prepared);

    return _OpeningSurface(
      loading: _loading,
      failure: _failure,
      hasDivergedDraft: _divergedBaseline != null,
      onClose: () => Navigator.of(context).pop(),
      onRetry: _load,
      onUseLatest: _useLatest,
      onKeepLocal: _keepLocal,
    );
  }

  Future<void> _load() async {
    final epoch = ++_epoch;
    setState(() {
      _loading = true;
      _failure = null;
      _divergedBaseline = null;
    });
    if (!_requiresLatest) {
      _prepare(null);
      return;
    }
    try {
      final latest = await _fetchLatest();
      if (!mounted || epoch != _epoch) return;
      _prepare(latest);
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      setState(() {
        _loading = false;
        _failure = mapApplicationFailure(error, '正文加载失败，请重试。');
      });
    }
  }

  bool get _requiresLatest {
    final target = widget.target;
    return target.postId != null &&
        (target.kind == PostComposerKind.editPost ||
            target.kind == PostComposerKind.upsertBody);
  }

  Future<PostItem> _fetchLatest() async {
    final target = widget.target;
    final postId = target.postId!;
    final latest = await ref.read(postRepositoryProvider).fetchPost(postId);
    final matchesTarget =
        latest.id == postId &&
        latest.threadId == target.threadId &&
        latest.subthreadId == target.subthreadId &&
        (target.kind == PostComposerKind.upsertBody
            ? latest.isBody
            : !latest.isBody);
    if (!matchesTarget || latest.isDeleted) {
      throw const ApiFailure(userMessage: '正文加载失败，请重新打开。');
    }
    return latest;
  }

  void _prepare(PostItem? latest) {
    final baseline = latest == null
        ? PostComposerBaseline(
            content: widget.target.initialContent,
            postId: widget.target.postId,
            version: widget.target.version,
          )
        : PostComposerBaseline(
            content: latest.content,
            postId: latest.id,
            version: latest.version,
          );
    final resolution = resolvePostComposerDraft(
      draft: widget.initialDraft,
      baseline: baseline,
    );
    if (resolution == PostComposerDraftResolution.diverged) {
      setState(() {
        _loading = false;
        _divergedBaseline = baseline;
      });
      return;
    }
    final content = resolution == PostComposerDraftResolution.restore
        ? widget.initialDraft!.content
        : baseline.content;
    if (resolution == PostComposerDraftResolution.saved) {
      widget.onDraftChanged?.call(null);
    }
    _open(content: content, baseline: baseline);
  }

  void _useLatest() {
    final baseline = _divergedBaseline;
    if (baseline == null) return;
    widget.onDraftChanged?.call(null);
    _open(content: baseline.content, baseline: baseline);
  }

  void _keepLocal() {
    final baseline = _divergedBaseline;
    final draft = widget.initialDraft;
    if (baseline == null || draft == null) return;
    _open(content: draft.content, baseline: baseline);
  }

  void _open({
    required String content,
    required PostComposerBaseline baseline,
  }) {
    setState(() {
      _loading = false;
      _divergedBaseline = null;
      _prepared = PreparedPostComposer(
        target: postComposerTargetWithBaseline(
          target: widget.target,
          content: content,
          version: baseline.version,
          postId: baseline.postId,
        ),
        baseline: baseline,
      );
    });
  }
}

class _OpeningSurface extends StatelessWidget {
  const _OpeningSurface({
    required this.loading,
    required this.failure,
    required this.hasDivergedDraft,
    required this.onClose,
    required this.onRetry,
    required this.onUseLatest,
    required this.onKeepLocal,
  });

  final bool loading;
  final ApiFailure? failure;
  final bool hasDivergedDraft;
  final VoidCallback onClose;
  final VoidCallback onRetry;
  final VoidCallback onUseLatest;
  final VoidCallback onKeepLocal;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        key: const Key('post-composer-opening'),
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space16,
              tokens.space16,
              tokens.space16,
              tokens.space24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  hasDivergedDraft ? '正文已有更新' : '准备编辑正文',
                  style: Theme.of(context).textTheme.wenyouRowTitle,
                ),
                SizedBox(height: tokens.space12),
                if (loading) ...[
                  const Center(child: CircularProgressIndicator()),
                  SizedBox(height: tokens.space12),
                  const Text('正在读取最新正文…', textAlign: TextAlign.center),
                ] else if (hasDivergedDraft) ...[
                  const WenyouStatusBanner(
                    key: Key('post-composer-draft-diverged'),
                    message: '本机保留的修改基于较早版本。',
                    detail: '可以使用最新版，或继续编辑本机内容；之后保存会替换刚读取的最新版。',
                  ),
                  SizedBox(height: tokens.space16),
                  OutlinedButton(
                    key: const Key('post-composer-use-latest'),
                    onPressed: onUseLatest,
                    child: const Text('使用最新版'),
                  ),
                  SizedBox(height: tokens.space8),
                  FilledButton(
                    key: const Key('post-composer-keep-local'),
                    onPressed: onKeepLocal,
                    child: const Text('继续编辑本机内容'),
                  ),
                ] else ...[
                  WenyouStatusBanner(
                    key: const Key('post-composer-opening-failure'),
                    message: failure?.userMessage ?? '正文加载失败，请重试。',
                    tone: WenyouStatusTone.error,
                  ),
                  SizedBox(height: tokens.space16),
                  FilledButton(
                    key: const Key('post-composer-opening-retry'),
                    onPressed: onRetry,
                    child: const Text('重试'),
                  ),
                ],
                SizedBox(height: tokens.space8),
                TextButton(onPressed: onClose, child: const Text('关闭')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
