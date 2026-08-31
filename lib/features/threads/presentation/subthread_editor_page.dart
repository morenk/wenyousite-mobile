import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/subthread_management_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';

class SubthreadEditorPage extends ConsumerStatefulWidget {
  const SubthreadEditorPage({
    required this.threadId,
    this.subthreadId,
    super.key,
  });

  final String threadId;
  final String? subthreadId;

  bool get creating => subthreadId == null;

  @override
  ConsumerState<SubthreadEditorPage> createState() =>
      _SubthreadEditorPageState();
}

class _SubthreadEditorPageState extends ConsumerState<SubthreadEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  SubthreadPostingPolicy _policy = SubthreadPostingPolicy.participants;
  SubthreadManagementItem? _baseline;
  bool _initialized = false;
  bool _preparing = false;
  bool _allowPop = false;
  ApiFailure? _localFailure;
  ApiFailure? _indeterminateFailure;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = subthreadManagementControllerProvider(widget.threadId);
    final state = ref.watch(provider);
    _schedulePreparation(state);
    final locked = state.isBusy || _preparing;
    return PopScope<Object?>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_requestClose(locked));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.creating ? '添加子贴' : '编辑子贴'),
          actions: [
            IconButton(
              key: const Key('subthread-editor-save'),
              tooltip: locked ? '正在保存' : '保存子贴',
              onPressed: !_initialized || locked ? null : _save,
              icon:
                  state.pendingAction == SubthreadManagementAction.creating ||
                      state.pendingAction == SubthreadManagementAction.updating
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const WenyouIcon(WenyouIconIds.actionSave),
            ),
          ],
        ),
        body: !_initialized
            ? _buildLoading(state)
            : WenyouPageBody(
                maxWidth: 640,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [_buildMetadata(locked), _buildFeedback(state)],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLoading(SubthreadManagementState state) {
    if (state.phase == SubthreadManagementPhase.failed) {
      return WenyouPageBody(
        child: WenyouEmptyState(
          icon: WenyouIconIds.contentList,
          title: '子贴加载失败',
          message: state.failure?.userMessage ?? '请检查网络后重试。',
          action: FilledButton.icon(
            onPressed: () => ref
                .read(
                  subthreadManagementControllerProvider(
                    widget.threadId,
                  ).notifier,
                )
                .load(),
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            label: const Text('重新加载'),
          ),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildMetadata(bool locked) {
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const Key('subthread-form-title'),
          controller: _titleController,
          enabled: !locked,
          autofocus: widget.creating,
          maxLength: 100,
          textInputAction: TextInputAction.next,
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
        SizedBox(height: tokens.space8),
        WenyouDropdownFormField<SubthreadPostingPolicy>(
          key: const Key('subthread-form-policy'),
          initialValue: _policy,
          decoration: const InputDecoration(labelText: '发帖权限'),
          items: SubthreadPostingPolicy.values
              .map(
                (policy) =>
                    DropdownMenuItem(value: policy, child: Text(policy.label)),
              )
              .toList(growable: false),
          onChanged: locked
              ? null
              : (policy) {
                  if (policy != null) setState(() => _policy = policy);
                },
        ),
        SizedBox(height: tokens.space4),
        Text(
          _policy.description,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
        ),
      ],
    );
  }

  Widget _buildFeedback(SubthreadManagementState state) {
    final failure = _localFailure ?? state.failure;
    if (failure == null && _indeterminateFailure == null) {
      return const SizedBox.shrink();
    }
    final tokens = context.wenyouTokens;
    return Padding(
      padding: EdgeInsets.only(top: tokens.space12),
      child: _indeterminateFailure != null
          ? WenyouWriteOutcomeBanner(
              key: const Key('subthread-form-indeterminate'),
              status: WriteOutcomeStatus.indeterminate,
              confirmingMessage: '正在确认子贴状态…',
              indeterminateMessage: '现在无法继续保存。请先刷新子贴查看是否已生效；应用不会自动重复提交。',
              failure: _indeterminateFailure,
            )
          : WenyouStatusBanner(
              key: const Key('subthread-form-failure'),
              tone: WenyouStatusTone.error,
              message: failure!.userMessage,
              detail: wenyouFailureDetail(failure, treatAsWrite: true),
            ),
    );
  }

  void _schedulePreparation(SubthreadManagementState state) {
    if (_initialized ||
        _preparing ||
        state.phase != SubthreadManagementPhase.ready ||
        state.bootstrap == null) {
      return;
    }
    if (widget.creating) {
      _initialized = true;
      return;
    }
    _preparing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final current = state.bootstrap!.items
          .where((item) => item.id == widget.subthreadId && !item.isDefault)
          .firstOrNull;
      if (current == null) {
        if (mounted) {
          setState(() {
            _preparing = false;
            _localFailure = const ApiFailure(userMessage: '这个子贴已经不存在或不能单独编辑。');
          });
        }
        return;
      }
      final latest = await ref
          .read(subthreadManagementControllerProvider(widget.threadId).notifier)
          .prepareEdit(current);
      if (!mounted) return;
      if (latest == null) {
        setState(() => _preparing = false);
        return;
      }
      setState(() {
        _baseline = latest;
        _titleController.text = latest.title;
        _policy = latest.postingPolicy;
        _preparing = false;
        _initialized = true;
      });
    });
  }

  SubthreadManagementDraft get _draft => SubthreadManagementDraft(
    title: _titleController.text,
    postingPolicy: _policy,
  );

  bool get _dirty {
    final baseline = _baseline;
    if (widget.creating) {
      return _titleController.text.trim().isNotEmpty ||
          _policy != SubthreadPostingPolicy.participants;
    }
    return baseline != null && _draft.differsFrom(baseline);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = subthreadManagementControllerProvider(widget.threadId);
    final state = ref.read(provider);
    final bootstrap = state.bootstrap;
    if (bootstrap == null) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _localFailure = null;
      _indeterminateFailure = null;
    });
    final notifier = ref.read(provider.notifier);
    final result = widget.creating
        ? await notifier.create(_draft)
        : await notifier.update(_baseline!, _draft);
    if (!mounted) return;
    switch (result) {
      case MutationSubmitCompleted<SubthreadManagementItem>():
        _allowPop = true;
        setState(() {});
        await WidgetsBinding.instance.endOfFrame;
        if (mounted) context.pop(true);
      case MutationSubmitFailed<SubthreadManagementItem>(:final failure):
        setState(() => _localFailure = failure);
      case MutationSubmitIndeterminate<SubthreadManagementItem>(:final failure):
        setState(() => _indeterminateFailure = failure);
    }
  }

  Future<void> _requestClose(bool locked) async {
    if (locked) return;
    if (!_dirty) {
      await _pop();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('放弃未保存的修改？'),
        content: const Text('标题或发帖权限尚未保存，离开后会丢失。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('继续编辑'),
          ),
          FilledButton(
            key: const Key('subthread-editor-discard'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('放弃修改'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) await _pop();
  }

  Future<void> _pop() async {
    _allowPop = true;
    setState(() {});
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) context.pop();
  }
}
