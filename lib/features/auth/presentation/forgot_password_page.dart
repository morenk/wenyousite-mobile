import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/auth/application/password_recovery_controller.dart';
import 'package:wenyousite_mobile/features/auth/presentation/reset_password_page.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({this.returnTo, super.key});

  final String? returnTo;

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _providerSeed = PasswordRecoverySeed();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final succeeded = await ref
        .read(passwordRecoveryControllerProvider(_providerSeed).notifier)
        .requestCode(_emailController.text);
    if (!succeeded || !mounted) return;
    final normalizedEmail = _emailController.text.trim().toLowerCase();
    context.pushReplacementNamed(
      'reset-password',
      queryParameters: widget.returnTo == null
          ? const {}
          : {'returnTo': widget.returnTo!},
      extra: PasswordResetRouteData(
        initialEmail: normalizedEmail,
        codeRecentlySent: true,
        codeDeliveryUncertain: ref
            .read(passwordRecoveryControllerProvider(_providerSeed))
            .codeDeliveryUncertain,
        codeDeliveryRequestId: ref
            .read(passwordRecoveryControllerProvider(_providerSeed))
            .codeDeliveryRequestId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final state = ref.watch(passwordRecoveryControllerProvider(_providerSeed));
    return Scaffold(
      appBar: AppBar(title: const Text('找回密码')),
      body: WenyouPageBody(
        maxWidth: 480,
        child: WenyouPanel(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WenyouSectionHeader(
                  title: '通过注册邮箱找回',
                  subtitle: '为保护账号，页面不会显示邮箱是否已注册。',
                ),
                SizedBox(height: tokens.space24),
                TextFormField(
                  key: const Key('forgot-password-email'),
                  controller: _emailController,
                  enabled: !state.isBusy,
                  autofillHints: const [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: state.isBusy ? null : (_) => _requestCode(),
                  decoration: const InputDecoration(
                    labelText: '注册邮箱',
                    prefixIcon: WenyouIcon(WenyouIconIds.actionMention),
                  ),
                  validator: _validateEmail,
                ),
                if (state.failure != null) ...[
                  SizedBox(height: tokens.space16),
                  WenyouFailureBanner(
                    failure: state.failure!,
                    action: TextButton(
                      onPressed: ref
                          .read(
                            passwordRecoveryControllerProvider(
                              _providerSeed,
                            ).notifier,
                          )
                          .clearFailure,
                      child: const Text('知道了'),
                    ),
                  ),
                ],
                SizedBox(height: tokens.space24),
                WenyouAsyncPrimaryButton(
                  key: const Key('forgot-password-submit'),
                  label: state.resendSecondsRemaining > 0
                      ? '${state.resendSecondsRemaining} 秒后重试'
                      : '发送重置验证码',
                  loadingLabel: '正在发送验证码',
                  icon: WenyouIconIds.actionSend,
                  isLoading: state.isRequestingCode,
                  onPressed: state.isBusy || state.resendSecondsRemaining > 0
                      ? null
                      : _requestCode,
                ),
                SizedBox(height: tokens.space8),
                TextButton(
                  key: const Key('forgot-password-login'),
                  onPressed: state.isBusy ? null : _goToLogin,
                  child: const Text('想起密码了？返回登录'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToLogin() {
    context.goNamed(
      'login',
      queryParameters: widget.returnTo == null
          ? const {}
          : {'returnTo': widget.returnTo!},
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return '请输入注册邮箱';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return '请输入有效的邮箱地址';
  }
  return null;
}
