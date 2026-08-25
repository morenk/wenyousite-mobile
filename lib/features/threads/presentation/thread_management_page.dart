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
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_body_editor.dart';
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
  final _bodyEditorController = ThreadManagementBodyEditorController();
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
  }

  @override
  void dispose() {
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
            if (_section == ThreadManagementSection.settings &&
                state.phase == ThreadManagementPhase.ready)
              IconButton(
                key: const Key('thread-management-save'),
                tooltip: state.isSaving ? '正在保存' : '保存修改',
                onPressed: state.isBusy ? null : _save,
                icon: state.isSaving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const WenyouIcon(WenyouIconIds.actionSave),
              ),
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
              enabled: !state.isBusy,
            ),
            Expanded(
              child: switch (state.phase) {
                ThreadManagementPhase.loading => const Center(
                  child: CircularProgressIndicator(),
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
    final locked = state.isBusy;
    return WenyouPageBody(
      maxWidth: 640,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WenyouSectionHeader(title: '主题设置'),
            SizedBox(height: tokens.space16),
            TextFormField(
              key: const Key('thread-management-title'),
              controller: _titleController,
              enabled: !locked,
              maxLength: 100,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '标题',
                hintText: '一句话说明这个主题',
              ),
              validator: (value) {
                final title = value?.trim() ?? '';
                if (title.isEmpty) return '请输入主题标题';
                if (title.length > 100) return '标题不能超过 100 个字符';
                return null;
              },
            ),
            SizedBox(height: tokens.space12),
            DropdownButtonFormField<String>(
              key: ValueKey('thread-management-category-${thread.version}'),
              initialValue: _categorySlug,
              decoration: const InputDecoration(labelText: '分区'),
              hint: const Text('请选择分区'),
              items: bootstrap.categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.slug,
                      child: Text(
                        category.isSelectable
                            ? category.name
                            : '${category.name}（已停用）',
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: locked
                  ? null
                  : (value) => setState(() => _categorySlug = value),
              validator: (value) => value == null ? '请选择主题分区' : null,
            ),
            SizedBox(height: tokens.space12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<ThreadManagementStatus>(
                    key: ValueKey('thread-management-status-${thread.version}'),
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: '主题状态'),
                    items: ThreadManagementStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: locked
                        ? null
                        : (value) {
                            if (value != null) setState(() => _status = value);
                          },
                  ),
                ),
                SizedBox(width: tokens.space12),
                Expanded(
                  child: KeyedSubtree(
                    key: const Key('thread-management-visibility'),
                    child: DropdownButtonFormField<ThreadManagementVisibility>(
                      key: ValueKey(
                        'thread-management-visibility-${thread.version}',
                      ),
                      initialValue: _visibility,
                      decoration: const InputDecoration(labelText: '可见范围'),
                      items: ThreadManagementVisibility.values
                          .map(
                            (visibility) => DropdownMenuItem(
                              value: visibility,
                              child: Text(visibility.label),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: locked || !thread.isOwner
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _visibility = value);
                              }
                            },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.space8),
            Text(
              thread.isOwner ? _visibility.description : '仅楼主可修改可见范围。',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
            ),
            SizedBox(height: tokens.space20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '主题标签 ${_tagNames.length}/5',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  key: const Key('thread-management-edit-tags'),
                  onPressed: locked ? null : _editTags,
                  icon: const WenyouIcon(WenyouIconIds.contentTag),
                  label: const Text('编辑'),
                ),
              ],
            ),
            if (_tagNames.isNotEmpty)
              Wrap(
                spacing: tokens.space8,
                runSpacing: tokens.space8,
                children: [
                  for (final tag in _tagNames)
                    InputChip(
                      label: Text(tag),
                      onDeleted: locked
                          ? null
                          : () => setState(
                              () => _tagNames = List.unmodifiable(
                                _tagNames.where((value) => value != tag),
                              ),
                            ),
                      deleteIcon: const WenyouIcon(
                        WenyouIconIds.actionClose,
                        size: 16,
                      ),
                    ),
                ],
              ),
            SizedBox(height: tokens.space20),
            Text('主正文', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: tokens.space8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.panel,
                border: Border.all(color: tokens.border),
                borderRadius: BorderRadius.circular(tokens.radius12),
              ),
              child: SizedBox(
                height: 440,
                child: ThreadManagementBodyEditor(
                  key: ValueKey(
                    'thread-management-body-${thread.bodyVersion ?? 0}',
                  ),
                  threadId: widget.threadId,
                  initialMarkdown: _body,
                  onChanged: (value) => _body = value,
                  controller: _bodyEditorController,
                  enabled: !locked,
                  label: '主题主正文编辑器',
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
                action: state.conflict == null
                    ? null
                    : TextButton(
                        key: const Key('thread-management-resolve-conflict'),
                        onPressed: locked ? null : _resolveConflict,
                        child: const Text('处理冲突'),
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
                      onPressed: locked ? null : _confirmDelete,
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

  void _bindSnapshot(ThreadManagementSnapshot snapshot, {bool force = false}) {
    final signature = [
      snapshot.version,
      snapshot.defaultSubthreadVersion,
      snapshot.bodyVersion,
      snapshot.body,
      snapshot.tagNames.join('\u0000'),
    ].join(':');
    if (!force && _boundSignature == signature) return;
    _boundSignature = signature;
    _titleController.text = snapshot.title;
    _categorySlug = snapshot.categorySlug;
    _status = snapshot.status;
    _visibility = snapshot.visibility;
    _body = snapshot.body;
    _tagNames = List.unmodifiable(snapshot.tagNames);
  }

  Future<bool> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    if (!await _bodyEditorController.flush()) return false;
    if (!mounted) return false;
    FocusScope.of(context).unfocus();
    final succeeded = await ref
        .read(threadManagementControllerProvider(widget.threadId).notifier)
        .save(_draft);
    if (!succeeded || !mounted) return false;
    _changed = true;
    showWenyouSnackBar(context, '主题设置已保存。');
    return true;
  }

  Future<void> _switchSection(
    ThreadManagementSection next,
    ThreadManagementState state,
  ) async {
    if (next == _section || state.isBusy) return;
    if (_section == ThreadManagementSection.settings && _isDirty(state)) {
      final choice = await _confirmUnsaved('切换管理分区');
      if (!mounted || choice == null || choice == _UnsavedChoice.keepEditing) {
        return;
      }
      if (choice == _UnsavedChoice.save && !await _save()) return;
      if (choice == _UnsavedChoice.discard) {
        _bindSnapshot(state.bootstrap!.thread, force: true);
      }
    }
    setState(() {
      _section = next;
      if (next != ThreadManagementSection.settings) _changed = true;
    });
  }

  Future<void> _handlePopAttempt(ThreadManagementState state) async {
    if (state.isBusy || _bodyEditorController.closeToolbarTray()) return;
    if (_section == ThreadManagementSection.settings && _isDirty(state)) {
      final choice = await _confirmUnsaved('离开主题管理');
      if (!mounted || choice == null || choice == _UnsavedChoice.keepEditing) {
        return;
      }
      if (choice == _UnsavedChoice.save && !await _save()) return;
    }
    await _popWithResult(_changed ? true : null);
  }

  Future<_UnsavedChoice?> _confirmUnsaved(String action) {
    return showDialog<_UnsavedChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('还有未保存的修改'),
        content: Text('$action前，可以先保存主题设置，也可以放弃本次修改。'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _UnsavedChoice.keepEditing),
            child: const Text('继续编辑'),
          ),
          TextButton(
            key: const Key('thread-management-discard-confirm'),
            onPressed: () =>
                Navigator.pop(dialogContext, _UnsavedChoice.discard),
            child: const Text('放弃修改'),
          ),
          FilledButton(
            key: const Key('thread-management-save-before-leave'),
            onPressed: () => Navigator.pop(dialogContext, _UnsavedChoice.save),
            child: const Text('保存后继续'),
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
    if (result != null && mounted) setState(() => _tagNames = result);
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
      setState(() {});
      return;
    }
    final succeeded = await notifier.overwriteConflict();
    if (succeeded && mounted) {
      _changed = true;
      showWenyouSnackBar(context, '已用当前内容更新主题。');
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

enum _UnsavedChoice { keepEditing, discard, save }

enum _ConflictChoice { useLatest, overwrite }

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
          onPressed: () => Navigator.pop(context, List.unmodifiable(_tags)),
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
