import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_management_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/subthread_management_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_invitation_controls.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_autosave.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_body_editor.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_settings_sections.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_member_management_page.dart';

enum ThreadManagementSection { settings, subthreads, members }

class ThreadManagementPage extends ConsumerStatefulWidget {
  const ThreadManagementPage({
    required this.threadId,
    this.initialSection = ThreadManagementSection.settings,
    this.openTagEditor = false,
    super.key,
  });

  final String threadId;
  final ThreadManagementSection initialSection;
  final bool openTagEditor;

  @override
  ConsumerState<ThreadManagementPage> createState() =>
      _ThreadManagementPageState();
}

class _ThreadManagementPageState extends ConsumerState<ThreadManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _bodyEditorController = ThreadManagementBodyEditorController();
  late final ThreadManagementAutosaveCoordinator _autosave;
  late ThreadManagementSection _section;
  String? _categorySlug;
  ThreadManagementStatus _status = ThreadManagementStatus.recruiting;
  ThreadManagementVisibility _visibility = ThreadManagementVisibility.public;
  String _body = '';
  List<String> _tagNames = const [];
  String? _boundSignature;
  bool _changed = false;
  bool _allowPop = false;
  bool _tagEditorScheduled = false;

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection;
    _titleFocusNode.addListener(_handleTitleFocusChanged);
    _autosave = ThreadManagementAutosaveCoordinator(
      hasChanges: _hasAutosaveChanges,
      onSave: _saveAutomatically,
    );
  }

  @override
  void dispose() {
    _autosave.dispose();
    _titleFocusNode
      ..removeListener(_handleTitleFocusChanged)
      ..dispose();
    _titleController.dispose();
    _bodyEditorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = threadManagementControllerProvider(widget.threadId);
    final state = ref.watch(provider);
    final bootstrap = state.bootstrap;
    if (state.phase == ThreadManagementPhase.ready && bootstrap != null) {
      _bindSnapshot(bootstrap.thread);
      if (widget.openTagEditor && !_tagEditorScheduled) {
        _tagEditorScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_editTags());
        });
      }
    }
    return PopScope<Object?>(
      canPop: _allowPop || state.phase != ThreadManagementPhase.ready,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_handlePopAttempt(state));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('管理主题'),
          actions: [
            if (_section == ThreadManagementSection.settings)
              _ThreadManagementAutosaveIndicator(coordinator: _autosave),
          ],
        ),
        body: Column(
          children: [
            WenyouContentTabs<ThreadManagementSection>(
              key: const Key('thread-management-tabs'),
              options: const [
                WenyouFilterOption(
                  value: ThreadManagementSection.settings,
                  label: '主题设置',
                ),
                WenyouFilterOption(
                  value: ThreadManagementSection.subthreads,
                  label: '子贴内容',
                ),
                WenyouFilterOption(
                  value: ThreadManagementSection.members,
                  label: '成员权限',
                ),
              ],
              selected: _section,
              onSelected: (value) => unawaited(_switchSection(value, state)),
              semanticsLabel: '主题管理分区',
              placement: WenyouTabPlacement.page,
              keyPrefix: 'thread-management-tab',
              enabled: !state.isDeleting,
            ),
            Expanded(
              child: switch (state.phase) {
                ThreadManagementPhase.loading => const WenyouPageBody(
                  child: WenyouDetailSkeleton(label: '正在加载主题管理'),
                ),
                ThreadManagementPhase.failed => _ManagementFatalState(
                  failureMessage: state.failure?.userMessage,
                  requestId: state.failure?.requestId,
                  onRetry: () => ref.read(provider.notifier).load(),
                ),
                ThreadManagementPhase.ready => switch (_section) {
                  ThreadManagementSection.settings => _buildSettings(
                    state,
                    bootstrap!,
                  ),
                  ThreadManagementSection.subthreads =>
                    SubthreadManagementContent(threadId: widget.threadId),
                  ThreadManagementSection.members =>
                    ThreadMemberManagementContent(threadId: widget.threadId),
                },
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings(
    ThreadManagementState state,
    ThreadManagementBootstrap bootstrap,
  ) {
    final tokens = context.wenyouTokens;
    final thread = bootstrap.thread;
    final locked = state.isDeleting;
    return WenyouPageBody(
      maxWidth: 640,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ThreadManagementBasicsPanel(
              titleController: _titleController,
              titleFocusNode: _titleFocusNode,
              categories: bootstrap.categories,
              categorySlug: _categorySlug,
              enabled: !locked,
              version: thread.version,
              onTitleChanged: (_) => _autosave.schedule(),
              onCategoryChanged: (value) {
                setState(() => _categorySlug = value);
                unawaited(_autosave.saveNow());
              },
            ),
            SizedBox(height: tokens.space12),
            ThreadManagementPublishingPanel(
              status: _status,
              visibility: _visibility,
              enabled: !locked,
              canChangeVisibility: thread.isOwner,
              onStatusChanged: (value) {
                setState(() => _status = value);
                unawaited(_autosave.saveNow());
              },
              onVisibilityChanged: (value) {
                setState(() => _visibility = value);
                unawaited(_autosave.saveNow());
              },
            ),
            SizedBox(height: tokens.space12),
            ThreadManagementTagsPanel(
              tags: _tagNames,
              enabled: !locked,
              onEdit: _editTags,
              onDeleteTag: (tag) {
                setState(
                  () => _tagNames = List.unmodifiable(
                    _tagNames.where((value) => value != tag),
                  ),
                );
                unawaited(_autosave.saveNow());
              },
            ),
            SizedBox(height: tokens.space20),
            const WenyouSectionHeader(
              title: '主正文',
              subtitle: '这里的内容会显示在默认子贴顶部。',
            ),
            SizedBox(height: tokens.space12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.panel,
                border: Border.all(color: tokens.border),
                borderRadius: BorderRadius.circular(tokens.radius12),
              ),
              child: SizedBox(
                height: 440,
                child: ThreadManagementBodyEditor(
                  key: const Key('thread-management-body'),
                  threadId: widget.threadId,
                  initialMarkdown: _body,
                  onChanged: (value) {
                    _body = value;
                    _autosave.schedule();
                  },
                  onFocusChanged: (hasFocus) {
                    if (!hasFocus) unawaited(_autosave.saveNow());
                  },
                  controller: _bodyEditorController,
                  enabled: !locked,
                  label: '主题主正文编辑器',
                  dockToolbarToKeyboard: true,
                ),
              ),
            ),
            if (state.failure != null) ...[
              SizedBox(height: tokens.space12),
              WenyouStatusBanner(
                key: const Key('thread-management-failure'),
                tone: WenyouStatusTone.error,
                message: state.failure!.userMessage,
                detail: state.failure!.requestId == null
                    ? null
                    : '问题编号：${state.failure!.requestId}',
                action: state.conflict != null
                    ? TextButton(
                        key: const Key('thread-management-resolve-conflict'),
                        onPressed: locked ? null : _resolveConflict,
                        child: const Text('处理冲突'),
                      )
                    : _isDirty(state)
                    ? TextButton(
                        key: const Key('thread-management-autosave-retry'),
                        onPressed: state.isBusy
                            ? null
                            : () => unawaited(_autosave.saveNow()),
                        child: const Text('重试保存'),
                      )
                    : TextButton(
                        key: const Key('thread-management-dismiss-failure'),
                        onPressed: state.isBusy
                            ? null
                            : () => ref
                                  .read(
                                    threadManagementControllerProvider(
                                      widget.threadId,
                                    ).notifier,
                                  )
                                  .clearFailure(),
                        child: const Text('知道了'),
                      ),
              ),
            ],
            if (thread.isOwner &&
                thread.published &&
                thread.visibility == ThreadManagementVisibility.private) ...[
              SizedBox(height: tokens.space16),
              ThreadInviteLinkPanel(threadId: thread.id, enabled: !locked),
            ],
            if (thread.isOwner) ...[
              SizedBox(height: tokens.space24),
              WenyouPanel(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WenyouSectionHeader(
                      title: '删除主题',
                      subtitle: '主题、子贴和全部内容会永久删除，且无法恢复。',
                    ),
                    SizedBox(height: tokens.space12),
                    OutlinedButton.icon(
                      key: const Key('thread-management-delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: state.isBusy ? null : _confirmDelete,
                      icon: const WenyouIcon(WenyouIconIds.actionDelete),
                      label: const Text('删除这个主题'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  ThreadManagementDraft get _draft => ThreadManagementDraft(
    title: _titleController.text,
    categorySlug: _categorySlug,
    status: _status,
    visibility: _visibility,
    body: _body,
    tagNames: _tagNames,
  );

  bool _isDirty(ThreadManagementState state) {
    final thread = state.bootstrap?.thread;
    return thread != null && _draft.differsFrom(thread);
  }

  bool _hasAutosaveChanges() {
    if (!mounted || _boundSignature == null) return false;
    return _isDirty(
      ref.read(threadManagementControllerProvider(widget.threadId)),
    );
  }

  void _bindSnapshot(ThreadManagementSnapshot snapshot, {bool force = false}) {
    final signature = [
      snapshot.version,
      snapshot.defaultSubthreadVersion,
      snapshot.bodyVersion,
      snapshot.body,
      snapshot.tagNames.join('\u0000'),
    ].join(':');
    if (!force && _boundSignature != null) return;
    _boundSignature = signature;
    _titleController.text = snapshot.title;
    _categorySlug = snapshot.categorySlug;
    _status = snapshot.status;
    _visibility = snapshot.visibility;
    _body = snapshot.body;
    _tagNames = List.unmodifiable(snapshot.tagNames);
  }

  Future<bool> _saveAutomatically() async {
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    if (!await _bodyEditorController.flush()) return false;
    if (!mounted) return false;
    final provider = threadManagementControllerProvider(widget.threadId);
    final state = ref.read(provider);
    if (!_isDirty(state)) return true;
    if (state.conflict != null) return false;
    final succeeded = await ref.read(provider.notifier).save(_draft);
    if (!succeeded || !mounted) return false;
    _changed = true;
    return true;
  }

  void _handleTitleFocusChanged() {
    if (!_titleFocusNode.hasFocus) unawaited(_autosave.saveNow());
  }

  Future<void> _switchSection(
    ThreadManagementSection next,
    ThreadManagementState state,
  ) async {
    if (next == _section || state.isDeleting) return;
    if (_section == ThreadManagementSection.settings &&
        !await _autosave.saveNow()) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _section = next;
      if (next != ThreadManagementSection.settings) _changed = true;
    });
  }

  Future<void> _handlePopAttempt(ThreadManagementState state) async {
    if (state.isDeleting || _bodyEditorController.closeToolbarTray()) return;
    final saved = await _autosave.saveNow();
    if (!mounted) return;
    final current = ref.read(
      threadManagementControllerProvider(widget.threadId),
    );
    if (!saved && _isDirty(current)) {
      final discard = await _confirmDiscardExit();
      if (!mounted || discard != true) return;
    }
    await _popWithResult(_changed ? true : null);
  }

  Future<bool?> _confirmDiscardExit() {
    final failure = ref
        .read(threadManagementControllerProvider(widget.threadId))
        .failure;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('修改还没有保存'),
        content: Text(failure?.userMessage ?? '请检查当前内容后重试，或者放弃修改并离开。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('继续编辑'),
          ),
          FilledButton(
            key: const Key('thread-management-discard-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('放弃并离开'),
          ),
        ],
      ),
    );
  }

  Future<void> _editTags() async {
    final result = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ThreadTagSelectorDialog(initial: _tagNames),
    );
    if (result != null && mounted) {
      setState(() => _tagNames = result);
      unawaited(_autosave.saveNow());
    }
  }

  Future<void> _resolveConflict() async {
    final provider = threadManagementControllerProvider(widget.threadId);
    final conflict = ref.read(provider).conflict;
    if (conflict == null) return;
    final choice = await showDialog<_ConflictChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('主题内容已经变化'),
        content: const Text('其他位置先保存了这个主题。当前表单会继续保留，直到你明确选择。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('继续编辑'),
          ),
          TextButton(
            key: const Key('thread-management-use-latest'),
            onPressed: () =>
                Navigator.pop(dialogContext, _ConflictChoice.useLatest),
            child: const Text('载入最新版'),
          ),
          FilledButton(
            key: const Key('thread-management-overwrite-latest'),
            onPressed: () =>
                Navigator.pop(dialogContext, _ConflictChoice.overwrite),
            child: const Text('覆盖最新版'),
          ),
        ],
      ),
    );
    if (!mounted || choice == null) return;
    final notifier = ref.read(provider.notifier);
    if (choice == _ConflictChoice.useLatest) {
      notifier.adoptLatest();
      _bindSnapshot(conflict.latest.thread, force: true);
      _autosave.markSaved();
      setState(() {});
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false) ||
        !await _bodyEditorController.flush() ||
        !mounted) {
      return;
    }
    final succeeded = await notifier.overwriteConflict(_draft);
    if (succeeded && mounted) {
      _changed = true;
      _autosave.markSaved();
    }
  }

  Future<void> _confirmDelete() async {
    final state = ref.read(threadManagementControllerProvider(widget.threadId));
    final thread = state.bootstrap?.thread;
    if (thread == null || !thread.isOwner) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认删除这个主题？'),
        content: const Text('主题、子贴和全部内容会永久删除，且无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('thread-management-delete-confirm'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final succeeded = await ref
        .read(threadManagementControllerProvider(widget.threadId).notifier)
        .remove();
    if (!succeeded || !mounted) return;
    showWenyouSnackBar(context, '主题已删除。');
    _allowPop = true;
    context.go(AppRouteLocations.home);
  }

  Future<void> _popWithResult(Object? result) async {
    _allowPop = true;
    setState(() {});
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) context.pop(result);
  }
}

enum _ConflictChoice { useLatest, overwrite }

class _ThreadManagementAutosaveIndicator extends StatelessWidget {
  const _ThreadManagementAutosaveIndicator({required this.coordinator});

  final ThreadManagementAutosaveCoordinator coordinator;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return AnimatedBuilder(
      animation: coordinator,
      builder: (context, _) {
        final status = coordinator.status;
        final label = switch (status) {
          ThreadManagementAutosaveStatus.idle => null,
          ThreadManagementAutosaveStatus.scheduled => '待保存',
          ThreadManagementAutosaveStatus.saving => '保存中',
          ThreadManagementAutosaveStatus.saved => '已保存',
          ThreadManagementAutosaveStatus.failed => '未保存',
        };
        final color = status == ThreadManagementAutosaveStatus.failed
            ? Theme.of(context).colorScheme.error
            : tokens.mutedText;
        return SizedBox(
          key: const Key('thread-management-autosave-status'),
          width: 88,
          height: tokens.minimumTouchTarget,
          child: label == null
              ? null
              : Semantics(
                  liveRegion: true,
                  label: label,
                  child: ExcludeSemantics(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (status == ThreadManagementAutosaveStatus.saving)
                          const SizedBox.square(
                            dimension: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          WenyouIcon(
                            status == ThreadManagementAutosaveStatus.failed
                                ? WenyouIconIds.statusError
                                : WenyouIconIds.actionConfirm,
                            size: 16,
                            color: color,
                          ),
                        SizedBox(width: tokens.space4),
                        Text(
                          label,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: color),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _ThreadTagSelectorDialog extends StatefulWidget {
  const _ThreadTagSelectorDialog({required this.initial});

  final List<String> initial;

  @override
  State<_ThreadTagSelectorDialog> createState() =>
      _ThreadTagSelectorDialogState();
}

class _ThreadTagSelectorDialogState extends State<_ThreadTagSelectorDialog> {
  final _controller = TextEditingController();
  late final List<String> _tags = [...widget.initial];
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return AlertDialog(
      title: const Text('编辑主题标签'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('thread-management-tag-input'),
              controller: _controller,
              autofocus: true,
              enabled: _tags.length < 5,
              maxLength: 20,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _add(),
              decoration: InputDecoration(
                labelText: '标签名称',
                hintText: '输入后添加',
                errorText: _error,
                suffixIcon: IconButton(
                  key: const Key('thread-management-tag-add'),
                  tooltip: '添加标签',
                  onPressed: _tags.length < 5 ? _add : null,
                  icon: const WenyouIcon(WenyouIconIds.actionAdd),
                ),
              ),
            ),
            SizedBox(height: tokens.space8),
            Text(
              '已选 ${_tags.length}/5',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            SizedBox(height: tokens.space8),
            if (_tags.isNotEmpty)
              Wrap(
                spacing: tokens.space8,
                runSpacing: tokens.space8,
                children: [
                  for (final tag in _tags)
                    InputChip(
                      label: Text(tag),
                      onDeleted: () => setState(() => _tags.remove(tag)),
                      deleteIcon: const WenyouIcon(
                        WenyouIconIds.actionClose,
                        size: 16,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const Key('thread-management-tag-done'),
          onPressed: () => Navigator.pop<List<String>>(
            context,
            List<String>.unmodifiable(_tags),
          ),
          child: const Text('完成'),
        ),
      ],
    );
  }

  void _add() {
    final value = _controller.text.trim();
    final pattern = RegExp(r'^[A-Za-z0-9_\u4e00-\u9fff#]+$');
    final error = value.isEmpty
        ? '请输入标签名称'
        : value.length > 20
        ? '标签名称不能超过 20 个字符'
        : !pattern.hasMatch(value)
        ? '只能使用中英文、数字、下划线和 #'
        : _tags.contains(value)
        ? '这个标签已经添加'
        : _tags.length >= 5
        ? '最多添加 5 个标签'
        : null;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _tags.add(value);
      _controller.clear();
      _error = null;
    });
  }
}

class _ManagementFatalState extends StatelessWidget {
  const _ManagementFatalState({
    required this.failureMessage,
    required this.requestId,
    required this.onRetry,
  });

  final String? failureMessage;
  final String? requestId;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.actionAccount,
          title: '主题管理信息加载失败',
          message: failureMessage ?? '请检查网络或账号权限后重试。',
          detail: requestId == null ? null : '问题编号：$requestId',
          action: OutlinedButton.icon(
            key: const Key('thread-management-load-retry'),
            onPressed: onRetry,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            label: const Text('重新加载'),
          ),
        ),
      ),
    );
  }
}
