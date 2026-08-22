import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/subthread_management_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_body_editor.dart';

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
  final _bodyController = ThreadManagementBodyEditorController();
  SubthreadPostingPolicy _policy = SubthreadPostingPolicy.participants;
  SubthreadManagementItem? _baseline;
  String _body = '';
  bool _initialized = false;
  bool _preparing = false;
  bool _allowPop = false;
  ApiFailure? _localFailure;
  String? _indeterminateRequestId;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
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
            : SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildMetadata(locked),
                          _buildFeedback(state),
                          Expanded(
                            child: ThreadManagementBodyEditor(
                              key: ValueKey(
                                'subthread-editor-body-${_baseline?.bodyVersion ?? 0}',
                              ),
                              threadId: widget.threadId,
                              initialMarkdown: _body,
                              onChanged: (value) => _body = value,
                              controller: _bodyController,
                              enabled: !locked,
                              autofocus: widget.creating,
                              label: '子贴正文编辑器',
                              placeholder: '输入子贴正文，也可以暂时留空…',
                            ),
                          ),
                        ],
                      ),
                    ),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        wenyouHorizontalPagePadding(context),
        tokens.space12,
        wenyouHorizontalPagePadding(context),
        tokens.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            key: const Key('subthread-form-title'),
            controller: _titleController,
            enabled: !locked,
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
      ),
    );
  }

  Widget _buildFeedback(SubthreadManagementState state) {
    final failure = _localFailure ?? state.failure;
    if (failure == null && _indeterminateRequestId == null) {
      return const SizedBox.shrink();
    }
    final tokens = context.wenyouTokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        wenyouHorizontalPagePadding(context),
        0,
        wenyouHorizontalPagePadding(context),
        tokens.space8,
      ),
      child: _indeterminateRequestId != null
          ? WenyouWriteOutcomeBanner(
              key: const Key('subthread-form-indeterminate'),
              status: WriteOutcomeStatus.indeterminate,
              confirmingMessage: '正在确认子贴状态…',
              indeterminateMessage: '保存结果暂时无法确定；再次保存会先确认原操作，不会重复创建。',
              requestId: _indeterminateRequestId,
            )
          : WenyouStatusBanner(
              key: const Key('subthread-form-failure'),
              tone: WenyouStatusTone.error,
              message: failure!.userMessage,
              detail: failure.requestId == null
                  ? null
                  : '问题编号：${failure.requestId}',
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
        _body = latest.body;
        _preparing = false;
        _initialized = true;
      });
    });
  }

  SubthreadManagementDraft get _draft => SubthreadManagementDraft(
    title: _titleController.text,
    postingPolicy: _policy,
    body: MarkdownContent.normalize(_body),
  );

  bool get _dirty {
    final baseline = _baseline;
    if (widget.creating) {
      return _titleController.text.trim().isNotEmpty ||
          _body.trim().isNotEmpty ||
          _policy != SubthreadPostingPolicy.participants;
    }
    return baseline != null && _draft.differsFrom(baseline);
  }

  String? _validateBody(SubthreadManagementBootstrap bootstrap) {
    final body = MarkdownContent.normalize(_body);
    if (body.length > 10000) return '正文不能超过 10000 个字符。';
    if (MarkdownDiceContract.countMarkdownNodes(body) >
        MarkdownDiceContract.maximumNodesPerPost) {
      return '当前正文最多可插入 20 个骰子，请删除一个后重试。';
    }
    final bodyChanged = _baseline == null || body != _baseline!.body;
    if (body.isEmpty && widget.creating) return null;
    if (bodyChanged &&
        bootstrap.published &&
        !MarkdownContent.hasVisibleNonDiceContent(body)) {
      return '已发布主题的子贴正文需要包含文字，骰子可作为补充。';
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_bodyController.flush()) return;
    final provider = subthreadManagementControllerProvider(widget.threadId);
    final state = ref.read(provider);
    final bootstrap = state.bootstrap;
    if (bootstrap == null) return;
    final bodyError = _validateBody(bootstrap);
    if (bodyError != null) {
      setState(() => _localFailure = ApiFailure(userMessage: bodyError));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _localFailure = null;
      _indeterminateRequestId = null;
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
      case MutationSubmitIndeterminate<SubthreadManagementItem>(
        :final requestId,
      ):
        setState(() => _indeterminateRequestId = requestId ?? '');
    }
  }

  Future<void> _requestClose(bool locked) async {
    if (locked || _bodyController.closeToolbarTray()) return;
    if (!_bodyController.flush()) return;
    if (!_dirty) {
      await _pop();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('放弃未保存的修改？'),
        content: const Text('标题、权限或正文尚未保存，离开后会丢失。'),
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
