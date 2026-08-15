import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/moderation/application/moderation_appeal_controller.dart';
import 'package:wenyousite_mobile/features/moderation/domain/moderation_appeal_models.dart';

class ModerationAppealPage extends ConsumerStatefulWidget {
  const ModerationAppealPage({super.key});

  @override
  ConsumerState<ModerationAppealPage> createState() =>
      _ModerationAppealPageState();
}

class _ModerationAppealPageState extends ConsumerState<ModerationAppealPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscurePassword = true;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moderationAppealControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('治理决定与申诉')),
      body: RefreshIndicator(
        onRefresh: state.phase == ModerationAppealPhase.ready
            ? ref.read(moderationAppealControllerProvider.notifier).retry
            : () async {},
        child: WenyouPageBody(
          maxWidth: 680,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WenyouSectionHeader(
                title: '治理决定与申诉',
                subtitle: '可查看近 30 天的本人治理决定；每项生效决定只能提交一次申诉。',
              ),
              SizedBox(height: context.wenyouTokens.space16),
              switch (state.phase) {
                ModerationAppealPhase.credential => _buildCredential(state),
                ModerationAppealPhase.loading => const _LoadingState(),
                ModerationAppealPhase.failed => _FailureState(state: state),
                ModerationAppealPhase.ready => _DecisionList(state: state),
              },
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredential(ModerationAppealState state) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('验证受限账号', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: tokens.space8),
            Text(
              '暂停或封禁账号无法建立普通登录会话。验证账号密码后，会签发一个仅能读取本人决定和提交申诉的 15 分钟凭据。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: tokens.space16),
            TextFormField(
              key: const Key('appeal-account'),
              controller: _accountController,
              enabled: !state.isIssuingCredential,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              decoration: const InputDecoration(
                labelText: '邮箱或用户名',
                prefixIcon: WenyouIcon(WenyouIconIds.identityMember),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? '请输入邮箱或用户名' : null,
            ),
            SizedBox(height: tokens.space16),
            TextFormField(
              key: const Key('appeal-password'),
              controller: _passwordController,
              enabled: !state.isIssuingCredential,
              autofillHints: const [AutofillHints.password],
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: state.isIssuingCredential
                  ? null
                  : (_) => _issueCredential(),
              decoration: InputDecoration(
                labelText: '密码',
                prefixIcon: const WenyouIcon(WenyouIconIds.actionLock),
                suffixIcon: IconButton(
                  onPressed: state.isIssuingCredential
                      ? null
                      : () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  tooltip: _obscurePassword ? '显示密码' : '隐藏密码',
                  icon: WenyouIcon(
                    _obscurePassword
                        ? WenyouIconIds.actionShow
                        : WenyouIconIds.actionHide,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return '请输入密码';
                if (value.length < 8) return '密码至少 8 个字符';
                return null;
              },
            ),
            if (state.failure != null) ...[
              SizedBox(height: tokens.space16),
              WenyouStatusBanner(
                key: const Key('appeal-credential-failure'),
                tone: WenyouStatusTone.error,
                message: state.failure!.userMessage,
                detail: state.failure!.requestId == null
                    ? null
                    : '请求 ID：${state.failure!.requestId}',
              ),
            ],
            SizedBox(height: tokens.space20),
            WenyouAsyncPrimaryButton(
              key: const Key('appeal-credential-submit'),
              label: '进入申诉通道',
              loadingLabel: '正在验证',
              isLoading: state.isIssuingCredential,
              onPressed: _issueCredential,
            ),
            SizedBox(height: tokens.space12),
            Text(
              '专用凭据只保存在当前页面内存中，离开页面即清除；不会替换或恢复普通登录状态。',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _issueCredential() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final succeeded = await ref
        .read(moderationAppealControllerProvider.notifier)
        .issueCredential(
          account: _accountController.text,
          password: _passwordController.text,
        );
    if (succeeded) _passwordController.clear();
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const WenyouPanel(
      child: WenyouEmptyState(
        icon: WenyouIconIds.moderationDecision,
        title: '正在读取治理决定',
        message: '只会显示当前账号近 30 天的公开处置信息。',
        action: CircularProgressIndicator(),
      ),
    );
  }
}

class _FailureState extends ConsumerWidget {
  const _FailureState({required this.state});

  final ModerationAppealState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WenyouPanel(
      child: WenyouEmptyState(
        icon: WenyouIconIds.statusOffline,
        title: '治理决定没有加载完成',
        message: state.failure?.userMessage ?? '请稍后重试。',
        detail: state.failure?.requestId == null
            ? null
            : '请求 ID：${state.failure!.requestId}',
        action: OutlinedButton.icon(
          key: const Key('appeal-retry'),
          onPressed: ref
              .read(moderationAppealControllerProvider.notifier)
              .retry,
          icon: const WenyouIcon(WenyouIconIds.actionRefresh),
          label: const Text('重新加载'),
        ),
      ),
    );
  }
}

class _DecisionList extends ConsumerWidget {
  const _DecisionList({required this.state});

  final ModerationAppealState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    if (state.decisions.isEmpty) {
      return const WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.moderationAppeal,
          title: '近 30 天没有治理决定',
          message: '当前账号没有可展示或可申诉的决定。',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.credentialExpiresAt != null) ...[
          WenyouStatusBanner(
            key: const Key('appeal-credential-expiry'),
            tone: WenyouStatusTone.accent,
            message:
                '申诉通道有效至 ${DateFormat('HH:mm').format(state.credentialExpiresAt!.toLocal())}；离开本页会立即清除凭据。',
          ),
          SizedBox(height: tokens.space12),
        ],
        if (state.failure != null) ...[
          WenyouStatusBanner(
            key: const Key('appeal-action-failure'),
            tone: WenyouStatusTone.error,
            message: state.failure!.userMessage,
            detail: state.failure!.requestId == null
                ? null
                : '请求 ID：${state.failure!.requestId}',
            action: TextButton(
              onPressed: ref
                  .read(moderationAppealControllerProvider.notifier)
                  .clearActionFailure,
              child: const Text('知道了'),
            ),
          ),
          SizedBox(height: tokens.space12),
        ],
        for (var index = 0; index < state.decisions.length; index++) ...[
          if (index > 0) SizedBox(height: tokens.space12),
          _DecisionCard(
            decision: state.decisions[index],
            submitting: state.submittingDecisionId == state.decisions[index].id,
          ),
        ],
      ],
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.decision, required this.submitting});

  final ModerationDecision decision;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: tokens.space8,
            runSpacing: tokens.space4,
            children: [
              _StatusBadge(
                label: decision.active ? '生效中' : '已撤销',
                active: decision.active,
              ),
              Text(
                decision.actionLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                DateFormat(
                  'yyyy-MM-dd HH:mm',
                ).format(decision.createdAt.toLocal()),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: tokens.space12),
          Text(decision.publicExplanation),
          SizedBox(height: tokens.space8),
          Text(
            '规则 ${decision.policyCode} · ${decision.targetTypeLabel} ${decision.targetId}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (decision.appeal case final appeal?) ...[
            SizedBox(height: tokens.space16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.softPanel,
                borderRadius: BorderRadius.circular(tokens.radius12),
              ),
              child: Padding(
                padding: EdgeInsets.all(tokens.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: tokens.space8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '已提交申诉',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        _StatusBadge(
                          label: appeal.statusLabel,
                          active:
                              appeal.status == ModerationAppealStatus.pending,
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.space8),
                    Text(appeal.statement),
                    if (appeal.handledNote != null) ...[
                      SizedBox(height: tokens.space12),
                      Divider(height: 1, color: tokens.border),
                      SizedBox(height: tokens.space12),
                      Text('站务复核：${appeal.handledNote}'),
                    ],
                  ],
                ),
              ),
            ),
          ] else if (decision.active) ...[
            SizedBox(height: tokens.space16),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                key: Key('appeal-open-${decision.id}'),
                onPressed: submitting
                    ? null
                    : () => _openAppealSheet(context, decision),
                icon: submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const WenyouIcon(WenyouIconIds.contentReview),
                label: Text(submitting ? '正在提交' : '提交申诉'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openAppealSheet(
    BuildContext context,
    ModerationDecision decision,
  ) async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _AppealSheet(decision: decision),
    );
    if (submitted == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('申诉已提交。')));
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? tokens.accentedBackground : tokens.softPanel,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: active ? tokens.brand : tokens.mutedText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AppealSheet extends ConsumerStatefulWidget {
  const _AppealSheet({required this.decision});

  final ModerationDecision decision;

  @override
  ConsumerState<_AppealSheet> createState() => _AppealSheetState();
}

class _AppealSheetState extends ConsumerState<_AppealSheet> {
  final _formKey = GlobalKey<FormState>();
  final _statementController = TextEditingController();

  @override
  void dispose() {
    _statementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final state = ref.watch(moderationAppealControllerProvider);
    final submitting = state.submittingDecisionId == widget.decision.id;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.space16,
        0,
        tokens.space16,
        MediaQuery.viewInsetsOf(context).bottom + tokens.space16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('提交申诉', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: tokens.space4),
            Text(
              '说明你认为“${widget.decision.actionLabel}”需要复核的事实和理由。每项决定只能申诉一次。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: tokens.space16),
            TextFormField(
              key: const Key('appeal-statement'),
              controller: _statementController,
              enabled: !submitting,
              autofocus: true,
              minLines: 4,
              maxLines: 8,
              maxLength: 2000,
              decoration: const InputDecoration(
                labelText: '申诉说明',
                hintText: '请写明需要复核的事实和理由',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                final length = value?.trim().length ?? 0;
                if (length < 10) return '请至少写 10 个字';
                if (length > 2000) return '申诉说明最多 2000 个字';
                return null;
              },
            ),
            SizedBox(height: tokens.space12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: submitting ? null : () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                SizedBox(width: tokens.space8),
                FilledButton(
                  key: const Key('appeal-submit'),
                  onPressed: submitting ? null : _submit,
                  child: submitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('提交申诉'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final succeeded = await ref
        .read(moderationAppealControllerProvider.notifier)
        .submit(
          decisionId: widget.decision.id,
          statement: _statementController.text.trim(),
        );
    if (succeeded && mounted) Navigator.pop(context, true);
  }
}
