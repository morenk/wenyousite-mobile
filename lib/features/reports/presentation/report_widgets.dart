import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/reports/application/report_controller.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';

enum _ReportDialogOutcome { verifyEmail }

class WenyouReportButton extends ConsumerWidget {
  const WenyouReportButton({
    required this.target,
    required this.targetLabel,
    required this.returnTo,
    this.iconOnly = false,
    super.key,
  });

  final ReportTarget target;
  final String targetLabel;
  final String returnTo;
  final bool iconOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (iconOnly) {
      return IconButton(
        tooltip: '举报',
        onPressed: () => _open(context, ref),
        icon: const WenyouIcon(WenyouIconIds.actionReport),
      );
    }
    return TextButton.icon(
      onPressed: () => _open(context, ref),
      icon: const WenyouIcon(WenyouIconIds.actionReport),
      label: const Text('举报'),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    await showWenyouReportFlow(
      context: context,
      ref: ref,
      target: target,
      targetLabel: targetLabel,
      returnTo: returnTo,
    );
  }
}

Future<void> showWenyouReportFlow({
  required BuildContext context,
  required WidgetRef ref,
  required ReportTarget target,
  required String targetLabel,
  required String returnTo,
}) async {
  if (!ref.read(sessionControllerProvider).isAuthenticated) {
    await context.pushNamed<Object?>(
      'login',
      queryParameters: {'returnTo': returnTo},
    );
    return;
  }
  final outcome = await showDialog<Object?>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        _ReportDialog(target: target, targetLabel: targetLabel),
  );
  if (!context.mounted) return;
  if (outcome == _ReportDialogOutcome.verifyEmail) {
    final verified = await context.push<bool>(
      Uri(
        path: '/me/security/verify-email',
        queryParameters: {'returnTo': returnTo},
      ).toString(),
    );
    if (verified == true && context.mounted) {
      await showWenyouReportFlow(
        context: context,
        ref: ref,
        target: target,
        targetLabel: targetLabel,
        returnTo: returnTo,
      );
    }
    return;
  }
  if (outcome is! ReportResult) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('举报已提交，管理员会根据站点规范进行审核。')));
}

class _ReportDialog extends ConsumerStatefulWidget {
  const _ReportDialog({required this.target, required this.targetLabel});

  final ReportTarget target;
  final String targetLabel;

  @override
  ConsumerState<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<_ReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  ReportReason _reason = ReportReason.spam;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final provider = reportControllerProvider(widget.target);
    final state = ref.watch(provider);
    return AlertDialog(
      title: Text('举报${widget.targetLabel}'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '提交后会保存当前目标快照并进入人工审核。管理员可看到你的举报账号；举报不会立即删除内容。',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                ),
                SizedBox(height: tokens.space16),
                DropdownButtonFormField<ReportReason>(
                  key: const Key('report-reason'),
                  initialValue: _reason,
                  decoration: const InputDecoration(labelText: '举报原因'),
                  items: [
                    for (final reason in ReportReason.values)
                      DropdownMenuItem(
                        value: reason,
                        child: Text(reason.label),
                      ),
                  ],
                  onChanged: state.isSubmitting
                      ? null
                      : (value) {
                          if (value != null) setState(() => _reason = value);
                        },
                ),
                SizedBox(height: tokens.space12),
                TextFormField(
                  key: const Key('report-details'),
                  controller: _detailsController,
                  enabled: !state.isSubmitting,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    labelText: _reason.requiresDetails
                        ? '补充说明（必填）'
                        : '补充说明（选填）',
                    hintText: '请描述具体问题，不要填写密码、验证码等敏感信息',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (_reason.requiresDetails &&
                        (value == null || value.trim().isEmpty)) {
                      return '选择其他原因时，请填写补充说明';
                    }
                    return null;
                  },
                ),
                if (state.failure != null) ...[
                  SizedBox(height: tokens.space12),
                  WenyouStatusBanner(
                    tone: WenyouStatusTone.error,
                    message: state.failure!.userMessage,
                    detail: state.failure!.requestId == null
                        ? null
                        : '请求 ID：${state.failure!.requestId}',
                    action: state.failure!.businessCode == 40107
                        ? TextButton(
                            key: const Key('report-verify-email'),
                            onPressed: () => Navigator.pop(
                              context,
                              _ReportDialogOutcome.verifyEmail,
                            ),
                            child: const Text('先验证邮箱'),
                          )
                        : null,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: state.isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const Key('report-submit'),
          onPressed: state.isSubmitting ? null : _submit,
          child: state.isSubmitting
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('提交举报'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final result = await ref
        .read(reportControllerProvider(widget.target).notifier)
        .submit(_reason, _detailsController.text);
    if (result != null && mounted) Navigator.pop(context, result);
  }
}
