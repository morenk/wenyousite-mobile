import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/subthread_management_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';

class SubthreadManagementPage extends ConsumerWidget {
  const SubthreadManagementPage({required this.threadId, super.key});

  final String threadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = subthreadManagementControllerProvider(threadId);
    final state = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('子贴管理'),
        actions: [
          IconButton(
            key: const Key('subthread-management-refresh'),
            tooltip: '刷新子贴',
            onPressed:
                state.phase == SubthreadManagementPhase.loading || state.isBusy
                ? null
                : () => ref.read(provider.notifier).load(),
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
          ),
        ],
      ),
      body: switch (state.phase) {
        SubthreadManagementPhase.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        SubthreadManagementPhase.failed => _SubthreadsFatalState(
          failure: state.failure,
          onRetry: () => ref.read(provider.notifier).load(),
        ),
        SubthreadManagementPhase.ready => _SubthreadsReadyState(
          threadId: threadId,
          state: state,
        ),
      },
    );
  }
}

class _SubthreadsReadyState extends ConsumerWidget {
  const _SubthreadsReadyState({required this.threadId, required this.state});

  final String threadId;
  final SubthreadManagementState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final bootstrap = state.bootstrap!;
    final provider = subthreadManagementControllerProvider(threadId);
    return WenyouPageBody(
      maxWidth: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WenyouPanel(
            child: WenyouSectionHeader(
              title: bootstrap.threadTitle,
              subtitle: '默认子贴固定在第一位；这里维护章节标题、发帖权限和顺序，正文仍从主题详情编辑。',
            ),
          ),
          if (state.failure != null) ...[
            SizedBox(height: tokens.space12),
            WenyouStatusBanner(
              key: const Key('subthread-management-failure'),
              tone: WenyouStatusTone.error,
              message: state.failure!.userMessage,
              detail: state.failure!.requestId == null
                  ? null
                  : '请求 ID：${state.failure!.requestId}',
              action: TextButton(
                key: const Key('subthread-management-dismiss-failure'),
                onPressed: state.isBusy
                    ? null
                    : () => ref.read(provider.notifier).clearFailure(),
                child: const Text('知道了'),
              ),
            ),
          ],
          SizedBox(height: tokens.space12),
          FilledButton.icon(
            key: const Key('subthread-management-create'),
            onPressed: state.isBusy ? null : () => _create(context, ref),
            icon: state.pendingAction == SubthreadManagementAction.creating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const WenyouIcon(WenyouIconIds.actionAdd),
            label: const Text('添加子贴'),
          ),
          SizedBox(height: tokens.space16),
          if (bootstrap.items.isEmpty)
            const WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.contentList,
                title: '还没有子贴',
                message: '添加第一条子贴后，它会自动成为固定的默认子贴。',
              ),
            )
          else
            for (var index = 0; index < bootstrap.items.length; index++) ...[
              _SubthreadCard(
                threadId: threadId,
                item: bootstrap.items[index],
                index: index,
                itemCount: bootstrap.items.length,
                state: state,
              ),
              if (index < bootstrap.items.length - 1)
                SizedBox(height: tokens.space12),
            ],
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final provider = subthreadManagementControllerProvider(threadId);
    final succeeded = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SubthreadFormDialog(
        mode: _SubthreadFormMode.create,
        onSubmit: (draft) async {
          final succeeded = await ref.read(provider.notifier).create(draft);
          return succeeded ? null : ref.read(provider).failure;
        },
      ),
    );
    if (succeeded == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('子贴已创建。')));
    }
  }
}

class _SubthreadCard extends ConsumerWidget {
  const _SubthreadCard({
    required this.threadId,
    required this.item,
    required this.index,
    required this.itemCount,
    required this.state,
  });

  final String threadId;
  final SubthreadManagementItem item;
  final int index;
  final int itemCount;
  final SubthreadManagementState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final provider = subthreadManagementControllerProvider(threadId);
    final pending = state.pendingItemId == item.id;
    return WenyouPanel(
      padding: EdgeInsets.all(tokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(tokens.radius12),
                ),
                child: Text('${index + 1}'),
              ),
              SizedBox(width: tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: tokens.space4),
                    Text(
                      '${item.postingPolicy.label} · ${item.postCount} 条内容',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                    ),
                  ],
                ),
              ),
              if (pending)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
          SizedBox(height: tokens.space12),
          if (item.isDefault)
            Row(
              children: [
                WenyouIcon(
                  WenyouIconIds.statusPinned,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: tokens.space8),
                Expanded(
                  child: Text(
                    '默认子贴固定置顶；标题随主题信息维护，正文从主题详情编辑。',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                  ),
                ),
              ],
            )
          else
            Wrap(
              spacing: tokens.space8,
              runSpacing: tokens.space8,
              children: [
                OutlinedButton.icon(
                  key: ValueKey('subthread-edit-${item.id}'),
                  onPressed: state.isBusy ? null : () => _edit(context, ref),
                  icon: const WenyouIcon(WenyouIconIds.actionEdit),
                  label: const Text('编辑'),
                ),
                IconButton.outlined(
                  key: ValueKey('subthread-up-${item.id}'),
                  tooltip: '上移 ${item.title}',
                  onPressed: state.isBusy || index <= 1
                      ? null
                      : () => ref.read(provider.notifier).move(item.id, -1),
                  icon: const WenyouIcon(WenyouIconIds.navigationUp),
                ),
                IconButton.outlined(
                  key: ValueKey('subthread-down-${item.id}'),
                  tooltip: '下移 ${item.title}',
                  onPressed: state.isBusy || index >= itemCount - 1
                      ? null
                      : () => ref.read(provider.notifier).move(item.id, 1),
                  icon: const WenyouIcon(WenyouIconIds.navigationDown),
                ),
                IconButton.outlined(
                  key: ValueKey('subthread-delete-${item.id}'),
                  tooltip: '删除 ${item.title}',
                  color: Theme.of(context).colorScheme.error,
                  onPressed: state.isBusy ? null : () => _delete(context, ref),
                  icon: const WenyouIcon(WenyouIconIds.actionDelete),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final provider = subthreadManagementControllerProvider(threadId);
    final latest = await ref.read(provider.notifier).prepareEdit(item);
    if (latest == null || !context.mounted) return;
    final succeeded = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SubthreadFormDialog(
        mode: _SubthreadFormMode.edit,
        initial: latest,
        onSubmit: (draft) async {
          final succeeded = await ref
              .read(provider.notifier)
              .update(latest, draft);
          return succeeded ? null : ref.read(provider).failure;
        },
      ),
    );
    if (succeeded == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('子贴已更新。')));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认删除这个子贴？'),
        content: Text('“${item.title}”及其正文、楼层和回复会一起删除，移动端无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: ValueKey('subthread-delete-confirm-${item.id}'),
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
    if (confirmed != true || !context.mounted) return;
    final succeeded = await ref
        .read(subthreadManagementControllerProvider(threadId).notifier)
        .remove(item);
    if (succeeded && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('子贴已删除。')));
    }
  }
}

enum _SubthreadFormMode { create, edit }

class _SubthreadFormDialog extends StatefulWidget {
  const _SubthreadFormDialog({
    required this.mode,
    required this.onSubmit,
    this.initial,
  });

  final _SubthreadFormMode mode;
  final SubthreadManagementItem? initial;
  final Future<ApiFailure?> Function(SubthreadManagementDraft draft) onSubmit;

  @override
  State<_SubthreadFormDialog> createState() => _SubthreadFormDialogState();
}

class _SubthreadFormDialogState extends State<_SubthreadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late SubthreadPostingPolicy _policy;
  bool _isSubmitting = false;
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title ?? '');
    _policy =
        widget.initial?.postingPolicy ?? SubthreadPostingPolicy.participants;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requiresReopen = _failure?.businessCode == 40002;
    return AlertDialog(
      title: Text(widget.mode == _SubthreadFormMode.create ? '添加子贴' : '编辑子贴'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('subthread-form-title'),
                  controller: _titleController,
                  enabled: !_isSubmitting,
                  autofocus: true,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: '子贴标题',
                    hintText: '例如：设定区 / 剧情区',
                  ),
                  validator: (value) {
                    final title = value?.trim() ?? '';
                    if (title.isEmpty) return '请输入子贴标题';
                    if (title.length > 100) return '标题不能超过 100 个字符';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<SubthreadPostingPolicy>(
                  key: const Key('subthread-form-policy'),
                  initialValue: _policy,
                  decoration: const InputDecoration(labelText: '发帖权限'),
                  items: SubthreadPostingPolicy.values
                      .map(
                        (policy) => DropdownMenuItem(
                          value: policy,
                          child: Text(policy.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: _isSubmitting
                      ? null
                      : (policy) {
                          if (policy != null) setState(() => _policy = policy);
                        },
                ),
                const SizedBox(height: 8),
                Text(
                  _policy.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.wenyouTokens.mutedText,
                  ),
                ),
                if (_failure != null) ...[
                  const SizedBox(height: 12),
                  WenyouStatusBanner(
                    key: const Key('subthread-form-failure'),
                    tone: WenyouStatusTone.error,
                    message: _failure!.userMessage,
                    detail: _failure!.requestId == null
                        ? null
                        : '请求 ID：${_failure!.requestId}',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const Key('subthread-form-submit'),
          onPressed: _isSubmitting
              ? null
              : requiresReopen
              ? () => Navigator.pop(context, false)
              : _submit,
          child: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  requiresReopen
                      ? '返回最新目录'
                      : widget.mode == _SubthreadFormMode.create
                      ? '添加'
                      : '保存',
                ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _failure = null;
    });
    final failure = await widget.onSubmit(
      SubthreadManagementDraft(
        title: _titleController.text,
        postingPolicy: _policy,
      ),
    );
    if (!mounted) return;
    if (failure == null) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _isSubmitting = false;
      _failure = failure;
    });
  }
}

class _SubthreadsFatalState extends StatelessWidget {
  const _SubthreadsFatalState({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      maxWidth: 520,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.contentList,
          title: '子贴管理暂时不可用',
          message: failure?.userMessage ?? '请检查网络后重试。',
          action: FilledButton.icon(
            key: const Key('subthread-management-retry'),
            onPressed: onRetry,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            label: const Text('重新加载'),
          ),
        ),
      ),
    );
  }
}
