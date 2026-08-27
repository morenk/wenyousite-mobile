import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/credential_input_policy.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_password_field.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_verification_code_field.dart';
import 'package:wenyousite_mobile/features/auth/application/password_recovery_controller.dart';

class PasswordResetRouteData {
  const PasswordResetRouteData({
    required this.initialEmail,
    this.codeRecentlySent = false,
    this.codeDeliveryUncertain = false,
    this.codeDeliveryRequestId,
  });

  final String initialEmail;
  final bool codeRecentlySent;
  final bool codeDeliveryUncertain;
  final String? codeDeliveryRequestId;
}

class PasswordResetLoginNotice {
  const PasswordResetLoginNotice();
}

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({
    this.returnTo,
    this.initialEmail,
    this.codeRecentlySent = false,
    this.codeDeliveryUncertain = false,
    this.codeDeliveryRequestId,
    super.key,
  });

  final String? returnTo;
  final String? initialEmail;
  final bool codeRecentlySent;
  final bool codeDeliveryUncertain;
  final String? codeDeliveryRequestId;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final PasswordRecoverySeed _providerSeed;
  late bool _editingEmail;

  @override
  void initState() {
    super.initState();
    final initialEmail = widget.initialEmail?.trim().toLowerCase();
    _emailController.text = initialEmail ?? '';
    _editingEmail = initialEmail == null || initialEmail.isEmpty;
    _providerSeed = PasswordRecoverySeed(
      initialEmail: initialEmail,
      codeRecentlySent:
          widget.codeRecentlySent && (initialEmail?.isNotEmpty ?? false),
      codeDeliveryUncertain: widget.codeDeliveryUncertain,
      codeDeliveryRequestId: widget.codeDeliveryRequestId,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (_editingEmail && !(_emailFieldKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    final codeMayHaveBeenSent = await ref
        .read(passwordRecoveryControllerProvider(_providerSeed).notifier)
        .requestCode(_emailController.text);
    if (mounted && codeMayHaveBeenSent) {
      setState(() => _editingEmail = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final succeeded = await ref
        .read(passwordRecoveryControllerProvider(_providerSeed).notifier)
        .resetPassword(
          email: _emailController.text,
          code: _codeController.text,
          newPassword: _newPasswordController.text,
        );
    if (!succeeded || !mounted) return;
    TextInput.finishAutofillContext();
    context.goNamed(
      'login',
      queryParameters: {
        if (widget.returnTo != null) 'returnTo': widget.returnTo!,
      },
      extra: const PasswordResetLoginNotice(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final state = ref.watch(passwordRecoveryControllerProvider(_providerSeed));
    final requestedEmail = state.lastRequestedEmail;
    final currentEmail = _emailController.text.trim().toLowerCase();
    final showDeliveryState =
        requestedEmail != null &&
        requestedEmail.isNotEmpty &&
        (!_editingEmail || requestedEmail == currentEmail);
    return Scaffold(
      appBar: AppBar(title: const Text('重置密码')),
      body: WenyouPageBody(
        maxWidth: 520,
        child: WenyouPanel(
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WenyouSectionHeader(
                    title: '设置新的登录密码',
                    subtitle: '重置成功后，账号会在所有设备上退出。',
                  ),
                  if (showDeliveryState) ...[
                    SizedBox(height: tokens.space20),
                    WenyouStatusBanner(
                      key: const Key('reset-password-code-sent'),
                      tone: state.codeDeliveryUncertain
                          ? WenyouStatusTone.neutral
                          : WenyouStatusTone.accent,
                      message: state.codeDeliveryUncertain
                          ? '邮件可能已经发出'
                          : '验证码已发送',
                      detail: state.codeDeliveryUncertain
                          ? state.codeDeliveryRequestId == null
                                ? '请保留当前验证码输入；为避免重复邮件，60 秒内不会重发。'
                                : '请保留当前输入；问题编号：${state.codeDeliveryRequestId}'
                          : '请检查收件箱和垃圾邮件；验证码只用于本次密码重置。',
                    ),
                  ],
                  SizedBox(height: tokens.space24),
                  if (_editingEmail)
                    TextFormField(
                      key: _emailFieldKey,
                      controller: _emailController,
                      enabled: !state.isBusy,
                      autofillHints: const [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: '注册邮箱',
                        prefixIcon: WenyouIcon(WenyouIconIds.statusMail),
                      ),
                      validator: (value) => CredentialInputPolicy.validateEmail(
                        value,
                        emptyMessage: '请输入注册邮箱',
                      ),
                      onChanged: (_) => setState(() {}),
                    )
                  else
                    Row(
                      children: [
                        const WenyouIcon(WenyouIconIds.statusMail),
                        SizedBox(width: tokens.space12),
                        Expanded(
                          child: Text(
                            _maskedEmail(_emailController.text),
                            key: const Key('reset-password-email-summary'),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        TextButton(
                          key: const Key('reset-password-edit-email'),
                          onPressed: state.isBusy
                              ? null
                              : () => setState(() => _editingEmail = true),
                          child: const Text('修改邮箱'),
                        ),
                      ],
                    ),
                  SizedBox(height: tokens.space12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      key: const Key('reset-password-request-code'),
                      onPressed:
                          state.isBusy || state.resendSecondsRemaining > 0
                          ? null
                          : _requestCode,
                      icon: state.isRequestingCode
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const WenyouIcon(WenyouIconIds.actionSend),
                      label: Text(
                        state.isRequestingCode
                            ? '正在发送验证码'
                            : state.resendSecondsRemaining > 0
                            ? '${state.resendSecondsRemaining} 秒后可重发'
                            : '发送或重新发送验证码',
                      ),
                    ),
                  ),
                  SizedBox(height: tokens.space20),
                  WenyouVerificationCodeField(
                    textFieldKey: const Key('reset-password-code'),
                    controller: _codeController,
                    enabled: !state.isBusy,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: tokens.space16),
                  WenyouPasswordField(
                    textFieldKey: const Key('reset-password-new'),
                    controller: _newPasswordController,
                    enabled: !state.isBusy,
                    autofillHints: const [AutofillHints.newPassword],
                    label: '新密码',
                    helperText: '8–100 位，至少包含一个字母和一个数字',
                    textInputAction: TextInputAction.next,
                    validator: CredentialInputPolicy.validateNewPassword,
                  ),
                  SizedBox(height: tokens.space16),
                  WenyouPasswordField(
                    textFieldKey: const Key('reset-password-confirm'),
                    controller: _confirmPasswordController,
                    enabled: !state.isBusy,
                    autofillHints: const [AutofillHints.newPassword],
                    label: '确认新密码',
                    prefixIcon: WenyouIconIds.actionResetPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: state.isBusy
                        ? null
                        : (_) => _resetPassword(),
                    validator: (value) => value == _newPasswordController.text
                        ? null
                        : '两次输入的新密码不一致',
                  ),
                  if (state.failure != null &&
                      !state.codeDeliveryUncertain) ...[
                    SizedBox(height: tokens.space16),
                    WenyouFailureBanner(
                      failure: state.failure!,
                      action: TextButton(
                        key: const Key('reset-password-error-dismiss'),
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
                    key: const Key('reset-password-submit'),
                    label: '重置密码',
                    loadingLabel: '正在重置密码',
                    icon: WenyouIconIds.securityPassword,
                    isLoading: state.isResetting,
                    onPressed: state.isBusy ? null : _resetPassword,
                  ),
                  SizedBox(height: tokens.space8),
                  TextButton(
                    key: const Key('reset-password-login'),
                    onPressed: state.isBusy ? null : _goToLogin,
                    child: const Text('返回登录'),
                  ),
                ],
              ),
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

String _maskedEmail(String email) {
  final separator = email.indexOf('@');
  if (separator <= 0 || separator == email.length - 1) return email;
  final local = email.substring(0, separator);
  final visible = local.substring(0, 1);
  return '$visible***${email.substring(separator)}';
}
