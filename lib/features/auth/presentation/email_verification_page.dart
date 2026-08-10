import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/internal_location.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/auth/application/email_verification_controller.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({this.returnTo, super.key});

  final String? returnTo;

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final succeeded = await ref
        .read(emailVerificationControllerProvider.notifier)
        .verifyCode(_codeController.text);
    if (!succeeded || !mounted) return;
    _codeController.clear();
    ref.invalidate(meProfileControllerProvider);
  }

  void _finish() {
    if (context.canPop()) {
      context.pop(true);
      return;
    }
    context.go(sanitizeReturnLocation(widget.returnTo ?? AppRouteLocations.me));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emailVerificationControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('验证邮箱')),
      body: switch (state.phase) {
        EmailVerificationPhase.loading => const _VerificationLoading(),
        EmailVerificationPhase.failed => _VerificationLoadFailure(
          message: state.failure?.userMessage ?? '请稍后重试。',
          requestId: state.failure?.requestId,
          onRetry: ref.read(emailVerificationControllerProvider.notifier).load,
        ),
        EmailVerificationPhase.ready =>
          state.account!.isVerified
              ? _VerifiedContent(
                  message: state.successMessage,
                  onFinish: _finish,
                )
              : _VerificationForm(
                  state: state,
                  formKey: _formKey,
                  codeController: _codeController,
                  onVerify: _verify,
                  onResend: ref
                      .read(emailVerificationControllerProvider.notifier)
                      .requestCode,
                  onEdit: ref
                      .read(emailVerificationControllerProvider.notifier)
                      .clearFeedback,
                ),
      },
    );
  }
}

class _VerificationLoading extends StatelessWidget {
  const _VerificationLoading();

  @override
  Widget build(BuildContext context) {
    return const WenyouPageBody(
      maxWidth: 480,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: Icons.mark_email_unread_outlined,
          title: '正在确认邮箱状态',
          message: '请稍候…',
          action: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _VerificationLoadFailure extends StatelessWidget {
  const _VerificationLoadFailure({
    required this.message,
    required this.requestId,
    required this.onRetry,
  });

  final String message;
  final String? requestId;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      maxWidth: 480,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: Icons.cloud_off_outlined,
          title: '邮箱状态没有加载完成',
          message: message,
          detail: requestId == null ? null : '请求 ID：$requestId',
          action: OutlinedButton.icon(
            key: const Key('verify-email-load-retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重新确认状态'),
          ),
        ),
      ),
    );
  }
}

class _VerificationForm extends StatelessWidget {
  const _VerificationForm({
    required this.state,
    required this.formKey,
    required this.codeController,
    required this.onVerify,
    required this.onResend,
    required this.onEdit,
  });

  final EmailVerificationState state;
  final GlobalKey<FormState> formKey;
  final TextEditingController codeController;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final account = state.account!;
    return WenyouPageBody(
      maxWidth: 480,
      child: WenyouPanel(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WenyouSectionHeader(
                title: '验证当前邮箱',
                subtitle:
                    '验证码将发送到 ${_maskEmail(account.email)}。完成后无需重新登录，即可继续发布和互动。',
              ),
              SizedBox(height: tokens.space24),
              TextFormField(
                key: const Key('verify-email-code'),
                controller: codeController,
                enabled: !state.isBusy,
                autofillHints: const [AutofillHints.oneTimeCode],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => onEdit(),
                onFieldSubmitted: state.isBusy ? null : (_) => onVerify(),
                decoration: const InputDecoration(
                  labelText: '6 位验证码',
                  prefixIcon: Icon(Icons.password_rounded),
                ),
                validator: _validateCode,
              ),
              if (state.failure != null) ...[
                SizedBox(height: tokens.space12),
                WenyouStatusBanner(
                  tone: WenyouStatusTone.error,
                  message: state.failure!.userMessage,
                  detail: state.failure!.requestId == null
                      ? null
                      : '请求 ID：${state.failure!.requestId}',
                  action: TextButton(
                    onPressed: onEdit,
                    child: const Text('知道了'),
                  ),
                ),
              ],
              if (state.successMessage != null) ...[
                SizedBox(height: tokens.space12),
                WenyouStatusBanner(
                  key: const Key('verify-email-code-sent'),
                  tone: WenyouStatusTone.accent,
                  message: state.successMessage!,
                ),
              ],
              SizedBox(height: tokens.space24),
              WenyouAsyncPrimaryButton(
                key: const Key('verify-email-submit'),
                label: '确认验证',
                loadingLabel: '正在确认',
                icon: Icons.verified_outlined,
                isLoading: state.isVerifying,
                onPressed: state.isBusy ? null : onVerify,
              ),
              SizedBox(height: tokens.space8),
              OutlinedButton.icon(
                key: const Key('verify-email-resend'),
                onPressed: state.isBusy || state.resendSecondsRemaining > 0
                    ? null
                    : onResend,
                icon: const Icon(Icons.outgoing_mail),
                label: Text(
                  state.resendSecondsRemaining > 0
                      ? '${state.resendSecondsRemaining} 秒后可重发'
                      : '发送验证码',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifiedContent extends StatelessWidget {
  const _VerifiedContent({required this.message, required this.onFinish});

  final String? message;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      maxWidth: 480,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: Icons.verified_rounded,
          title: '邮箱已验证',
          message: message ?? '当前邮箱已经完成验证，可以继续使用完整功能。',
          action: FilledButton.icon(
            key: const Key('verify-email-finish'),
            onPressed: onFinish,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('继续之前的操作'),
          ),
        ),
      ),
    );
  }
}

String? _validateCode(String? value) {
  if (!RegExp(r'^\d{6}$').hasMatch(value?.trim() ?? '')) {
    return '请输入 6 位数字验证码';
  }
  return null;
}

String _maskEmail(String email) {
  final separator = email.indexOf('@');
  if (separator <= 0 || separator == email.length - 1) return email;
  return '${email[0]}***${email.substring(separator)}';
}
