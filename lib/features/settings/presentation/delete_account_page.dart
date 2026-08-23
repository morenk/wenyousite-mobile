import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/settings/application/account_deletion_controller.dart';

class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  static const confirmationPhrase = '注销账号';

  final _formKey = GlobalKey<FormState>();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _requestDeletion() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('最后确认注销账号'),
          content: const Text('注销立即生效且无法恢复。所有登录终端都会失效，确定永久注销吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消'),
            ),
            FilledButton(
              key: const Key('delete-account-confirm'),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('永久注销'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    await _deleteRemotely();
  }

  Future<void> _deleteRemotely() async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final succeeded = await ref
        .read(accountDeletionControllerProvider.notifier)
        .submit();
    if (!succeeded) return;
    messenger.showWenyouSnackBar('账号已注销。');
    router.go(AppRouteLocations.home);
  }

  Future<void> _retryLocalCleanup() async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final succeeded = await ref
        .read(accountDeletionControllerProvider.notifier)
        .retryLocalCleanup();
    if (!succeeded) return;
    messenger.showWenyouSnackBar('这台设备的登录信息已清除。');
    router.go(AppRouteLocations.home);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(accountDeletionControllerProvider);
    final locked = state.isSubmitting || state.remoteDeletionConfirmed;
    return Scaffold(
      appBar: AppBar(title: const Text('注销账号')),
      body: WenyouPageBody(
        maxWidth: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WenyouPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WenyouSectionHeader(title: '这是不可恢复的操作'),
                  SizedBox(height: tokens.space16),
                  const _DeletionConsequence(
                    icon: WenyouIconIds.actionDevices,
                    text: '当前账号会在所有设备上退出。',
                  ),
                  SizedBox(height: tokens.space12),
                  const _DeletionConsequence(
                    icon: WenyouIconIds.statusUserUnavailable,
                    text: '用户名、邮箱和头像会从公开身份移除，账号无法恢复。',
                  ),
                  SizedBox(height: tokens.space12),
                  const _DeletionConsequence(
                    icon: WenyouIconIds.contentThread,
                    text: '为维持讨论结构，已发布内容仍会保留，但作者统一显示为“已注销用户”。',
                  ),
                  SizedBox(height: tokens.space12),
                  const _DeletionConsequence(
                    icon: WenyouIconIds.contentDraft,
                    text: '这台设备上的未发布草稿不会上传或自动删除，注销后也无法再以此账号恢复。',
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.space12),
            WenyouPanel(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WenyouSectionHeader(title: '输入确认文字'),
                    SizedBox(height: tokens.space16),
                    TextFormField(
                      key: const Key('delete-account-phrase'),
                      controller: _confirmationController,
                      enabled: !locked,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: '确认文字',
                        hintText: confirmationPhrase,
                        prefixIcon: WenyouIcon(WenyouIconIds.statusWarning),
                      ),
                      onChanged: (_) => ref
                          .read(accountDeletionControllerProvider.notifier)
                          .clearFailure(),
                      onFieldSubmitted: locked
                          ? null
                          : (_) => _requestDeletion(),
                      validator: (value) =>
                          value == confirmationPhrase ? null : '请输入完整的“注销账号”',
                    ),
                    if (state.failure != null) ...[
                      SizedBox(height: tokens.space16),
                      WenyouFailureBanner(
                        key: const Key('delete-account-failure'),
                        failure: state.failure!,
                        action: state.remoteDeletionConfirmed
                            ? TextButton(
                                key: const Key(
                                  'delete-account-retry-local-cleanup',
                                ),
                                onPressed: state.isSubmitting
                                    ? null
                                    : _retryLocalCleanup,
                                child: const Text('重试清除这台设备的登录'),
                              )
                            : null,
                      ),
                    ],
                    SizedBox(height: tokens.space24),
                    FilledButton.icon(
                      key: const Key('delete-account-submit'),
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.error,
                        foregroundColor: scheme.onError,
                      ),
                      onPressed: locked ? null : _requestDeletion,
                      icon: state.isSubmitting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const WenyouIcon(WenyouIconIds.actionDelete),
                      label: Text(state.isSubmitting ? '正在注销' : '继续注销账号'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeletionConsequence extends StatelessWidget {
  const _DeletionConsequence({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WenyouIcon(icon, size: 20, color: Theme.of(context).colorScheme.error),
        SizedBox(width: tokens.space8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
