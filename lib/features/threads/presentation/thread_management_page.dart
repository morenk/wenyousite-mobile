import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_management_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_invitation_controls.dart';

class ThreadManagementPage extends ConsumerStatefulWidget {
  const ThreadManagementPage({required this.threadId, super.key});

  final String threadId;

  @override
  ConsumerState<ThreadManagementPage> createState() =>
      _ThreadManagementPageState();
}

class _ThreadManagementPageState extends ConsumerState<ThreadManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _categorySlug;
  ThreadManagementStatus _status = ThreadManagementStatus.recruiting;
  ThreadManagementVisibility _visibility = ThreadManagementVisibility.public;
  int? _boundVersion;
  bool _allowPop = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = threadManagementControllerProvider(widget.threadId);
    final state = ref.watch(provider);
    final bootstrap = state.bootstrap;
    if (state.phase == ThreadManagementPhase.ready && bootstrap != null) {
      _bindSnapshot(bootstrap.thread);
    }
    return PopScope(
      canPop: _allowPop || state.phase != ThreadManagementPhase.ready,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handlePopAttempt(state);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('管理主题')),
        body: switch (state.phase) {
          ThreadManagementPhase.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          ThreadManagementPhase.failed => _ManagementFatalState(
            failureMessage: state.failure?.userMessage,
            requestId: state.failure?.requestId,
            onRetry: () => ref.read(provider.notifier).load(),
          ),
          ThreadManagementPhase.ready => _buildReady(
            state,
            bootstrap!,
            provider,
          ),
        },
      ),
    );
  }

  Widget _buildReady(
    ThreadManagementState state,
    ThreadManagementBootstrap bootstrap,
    AutoDisposeStateNotifierProvider<
      ThreadManagementController,
      ThreadManagementState
    >
    provider,
  ) {
    final tokens = context.wenyouTokens;
    final thread = bootstrap.thread;
    final locked = state.isBusy;
    final failure = state.failure;
    return WenyouPageBody(
      maxWidth: 560,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WenyouPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WenyouSectionHeader(
                    title: '主题信息',
                    subtitle: '这些信息会立即同步到 Web 与移动端。标签、子贴和正文在各自入口维护。',
                  ),
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
                  KeyedSubtree(
                    key: const Key('thread-management-category'),
                    child: DropdownButtonFormField<String>(
                      key: ValueKey('category-${thread.version}'),
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
                  ),
                  SizedBox(height: tokens.space12),
                  KeyedSubtree(
                    key: const Key('thread-management-status'),
                    child: DropdownButtonFormField<ThreadManagementStatus>(
                      key: ValueKey('status-${thread.version}'),
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
                              if (value != null) {
                                setState(() => _status = value);
                              }
                            },
                    ),
                  ),
                  SizedBox(height: tokens.space12),
                  KeyedSubtree(
                    key: const Key('thread-management-visibility'),
                    child: DropdownButtonFormField<ThreadManagementVisibility>(
                      key: ValueKey('visibility-${thread.version}'),
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
                  SizedBox(height: tokens.space8),
                  Text(
                    thread.isOwner
                        ? _visibility.description
                        : '协作者可以维护标题、分区和状态；可见范围仅楼主可修改。',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.space12),
            OutlinedButton.icon(
              key: const Key('thread-management-open-tags'),
              onPressed: locked
                  ? null
                  : () => context.push(
                      AppRouteLocations.threadTagManagement(widget.threadId),
                    ),
              icon: const WenyouIcon(WenyouIconIds.contentTag),
              label: const Text('管理主题标签'),
            ),
            SizedBox(height: tokens.space12),
            OutlinedButton.icon(
              key: const Key('thread-management-open-subthreads'),
              onPressed: locked
                  ? null
                  : () => context.push(
                      AppRouteLocations.subthreadManagement(widget.threadId),
                    ),
              icon: const WenyouIcon(WenyouIconIds.contentList),
              label: const Text('管理子贴与发帖权限'),
            ),
            SizedBox(height: tokens.space12),
            OutlinedButton.icon(
              key: const Key('thread-management-open-members'),
              onPressed: locked
                  ? null
                  : () => context.push(
                      AppRouteLocations.threadMemberManagement(widget.threadId),
                    ),
              icon: const WenyouIcon(WenyouIconIds.identityMembers),
              label: const Text('管理成员与玩家身份'),
            ),
            if (thread.isOwner &&
                thread.published &&
                thread.visibility == ThreadManagementVisibility.private) ...[
              SizedBox(height: tokens.space12),
              ThreadInviteLinkPanel(threadId: thread.id, enabled: !locked),
            ],
            if (failure != null) ...[
              SizedBox(height: tokens.space12),
              WenyouStatusBanner(
                key: const Key('thread-management-failure'),
                tone: WenyouStatusTone.error,
                message: failure.userMessage,
                detail: failure.requestId == null
                    ? null
                    : '请求 ID：${failure.requestId}',
                action: state.conflict != null
                    ? TextButton(
                        key: const Key('thread-management-resolve-conflict'),
                        onPressed: locked ? null : _resolveConflict,
                        child: const Text('处理冲突'),
                      )
                    : failure.businessCode == 40107
                    ? TextButton(
                        key: const Key('thread-management-verify-email'),
                        onPressed: locked ? null : _openEmailVerification,
                        child: const Text('先验证邮箱'),
                      )
                    : null,
              ),
            ],
            SizedBox(height: tokens.space16),
            WenyouAsyncPrimaryButton(
              key: const Key('thread-management-save'),
              label: '保存修改',
              loadingLabel: '正在保存修改',
              icon: WenyouIconIds.actionSave,
              isLoading: state.isSaving,
              onPressed: locked ? null : _save,
            ),
            if (thread.isOwner) ...[
              SizedBox(height: tokens.space24),
              WenyouPanel(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WenyouSectionHeader(
                      title: '删除主题',
                      subtitle: thread.published
                          ? '删除后主题会从公开列表和访问入口消失，现有链接也将失效。'
                          : '未发布草稿会连同子贴与内容永久删除，无法恢复。',
                    ),
                    SizedBox(height: tokens.space16),
                    OutlinedButton.icon(
                      key: const Key('thread-management-delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        minimumSize: Size.fromHeight(tokens.minimumTouchTarget),
                      ),
                      onPressed: locked ? null : _confirmDelete,
                      icon: state.isDeleting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const WenyouIcon(WenyouIconIds.actionDelete),
                      label: Text(state.isDeleting ? '正在删除' : '删除这个主题'),
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
  );

  void _bindSnapshot(ThreadManagementSnapshot snapshot) {
    if (_boundVersion == snapshot.version) return;
    _boundVersion = snapshot.version;
    _titleController.text = snapshot.title;
    _categorySlug = snapshot.categorySlug;
    _status = snapshot.status;
    _visibility = snapshot.visibility;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final succeeded = await ref
        .read(threadManagementControllerProvider(widget.threadId).notifier)
        .save(_draft);
    if (!succeeded || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('主题信息已更新。')));
    await _popWithResult(true);
  }

  Future<void> _resolveConflict() async {
    final state = ref.read(threadManagementControllerProvider(widget.threadId));
    final conflict = state.conflict;
    if (conflict == null) return;
    final choice = await showDialog<_ConflictChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('主题信息已经变化'),
        content: const Text('其他位置先保存了这个主题。你可以采用云端最新版，或明确用当前表单覆盖最新版。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            key: const Key('thread-management-use-latest'),
            onPressed: () =>
                Navigator.pop(dialogContext, _ConflictChoice.useLatest),
            child: const Text('采用云端最新版'),
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
    final notifier = ref.read(
      threadManagementControllerProvider(widget.threadId).notifier,
    );
    if (choice == _ConflictChoice.useLatest) {
      notifier.adoptLatest();
      return;
    }
    final succeeded = await notifier.overwriteConflict();
    if (!succeeded || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已用当前内容更新主题。')));
    await _popWithResult(true);
  }

  Future<void> _confirmDelete() async {
    final state = ref.read(threadManagementControllerProvider(widget.threadId));
    final thread = state.bootstrap?.thread;
    if (thread == null || !thread.isOwner) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('确认删除这个主题？'),
          content: Text(
            thread.published
                ? '删除后主题会立即不可见，不能从移动端恢复。确定继续吗？'
                : '未发布草稿及其全部内容会永久删除，无法恢复。确定继续吗？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消'),
            ),
            FilledButton(
              key: const Key('thread-management-delete-confirm'),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('确认删除'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final succeeded = await ref
        .read(threadManagementControllerProvider(widget.threadId).notifier)
        .remove();
    if (!succeeded) return;
    messenger.showSnackBar(const SnackBar(content: Text('主题已删除。')));
    _allowPop = true;
    router.go(AppRouteLocations.home);
  }

  Future<void> _confirmDiscardChanges() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('放弃未保存的修改？'),
        content: const Text('当前表单还没有保存，离开后这些修改会丢失。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('继续编辑'),
          ),
          FilledButton(
            key: const Key('thread-management-discard-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('放弃修改'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _popWithResult(null);
  }

  Future<void> _handlePopAttempt(ThreadManagementState state) async {
    if (state.isBusy) return;
    final thread = state.bootstrap?.thread;
    if (thread == null || !_draft.differsFrom(thread)) {
      await _popWithResult(null);
      return;
    }
    await _confirmDiscardChanges();
  }

  Future<void> _popWithResult(Object? result) async {
    _allowPop = true;
    setState(() {});
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) context.pop(result);
  }

  Future<void> _openEmailVerification() async {
    final returnTo = '/threads/${widget.threadId}/manage';
    final verified = await context.push<bool>(
      Uri(
        path: '/me/security/verify-email',
        queryParameters: {'returnTo': returnTo},
      ).toString(),
    );
    if (verified == true && mounted) {
      ref
          .read(threadManagementControllerProvider(widget.threadId).notifier)
          .clearFailure();
    }
  }
}

enum _ConflictChoice { useLatest, overwrite }

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
          title: '主题管理信息没有加载完成',
          message: failureMessage ?? '请检查网络或账号权限后重试。',
          detail: requestId == null ? null : '请求 ID：$requestId',
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
