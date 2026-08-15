import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/auth/application/password_recovery_controller.dart';

class PasswordResetRouteData {
  const PasswordResetRouteData({
    required this.initialEmail,
    this.codeRecentlySent = false,
  });

  final String initialEmail;
  final bool codeRecentlySent;
}

class PasswordResetLoginNotice {
  const PasswordResetLoginNotice();
}

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({
    this.returnTo,
    this.initialEmail,
    this.codeRecentlySent = false,
    super.key,
  });

  final String? returnTo;
  final String? initialEmail;
  final bool codeRecentlySent;

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
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final initialEmail = widget.initialEmail?.trim().toLowerCase();
    _emailController.text = initialEmail ?? '';
    _providerSeed = PasswordRecoverySeed(
      initialEmail: initialEmail,
      codeRecentlySent:
          widget.codeRecentlySent && (initialEmail?.isNotEmpty ?? false),
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
    if (!(_emailFieldKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref
        .read(passwordRecoveryControllerProvider(_providerSeed).notifier)
        .requestCode(_emailController.text);
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
                    subtitle: '输入邮箱、邮件中的 6 位验证码和新密码。成功后该账号的所有终端都会退出。',
                  ),
                  if (requestedEmail != null && requestedEmail.isNotEmpty) ...[
                    SizedBox(height: tokens.space20),
                    WenyouStatusBanner(
                      key: const Key('reset-password-code-sent'),
                      tone: WenyouStatusTone.accent,
                      message: '如果该邮箱已注册，验证码会发送到 $requestedEmail。',
                      detail: '请检查收件箱和垃圾邮件；验证码只用于本次密码重置。',
                    ),
                  ],
                  SizedBox(height: tokens.space24),
                  TextFormField(
                    key: _emailFieldKey,
                    controller: _emailController,
                    enabled: !state.isBusy,
                    autofillHints: const [AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: '注册邮箱',
                      prefixIcon: WenyouIcon(WenyouIconIds.actionMention),
                    ),
                    validator: _validateEmail,
                  ),
                  SizedBox(height: tokens.space12),
                  OutlinedButton.icon(
                    key: const Key('reset-password-request-code'),
                    onPressed: state.isBusy || state.resendSecondsRemaining > 0
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
                  SizedBox(height: tokens.space20),
                  TextFormField(
                    key: const Key('reset-password-code'),
                    controller: _codeController,
                    enabled: !state.isBusy,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    maxLength: 6,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value?.length == 6 ? null : '请输入 6 位数字验证码',
                    decoration: const InputDecoration(
                      labelText: '6 位验证码',
                      counterText: '',
                      prefixIcon: WenyouIcon(WenyouIconIds.statusVerified),
                    ),
                  ),
                  SizedBox(height: tokens.space16),
                  TextFormField(
                    key: const Key('reset-password-new'),
                    controller: _newPasswordController,
                    enabled: !state.isBusy,
                    autofillHints: const [AutofillHints.newPassword],
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    validator: _validateNewPassword,
                    decoration: InputDecoration(
                      labelText: '新密码',
                      helperText: '8–100 位，至少包含一个字母和一个数字',
                      prefixIcon: const WenyouIcon(WenyouIconIds.actionLock),
                      suffixIcon: IconButton(
                        onPressed: state.isBusy
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
                  ),
                  SizedBox(height: tokens.space16),
                  TextFormField(
                    key: const Key('reset-password-confirm'),
                    controller: _confirmPasswordController,
                    enabled: !state.isBusy,
                    autofillHints: const [AutofillHints.newPassword],
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: state.isBusy
                        ? null
                        : (_) => _resetPassword(),
                    validator: (value) => value == _newPasswordController.text
                        ? null
                        : '两次输入的新密码不一致',
                    decoration: const InputDecoration(
                      labelText: '确认新密码',
                      prefixIcon: WenyouIcon(WenyouIconIds.actionResetPassword),
                    ),
                  ),
                  if (state.failure != null) ...[
                    SizedBox(height: tokens.space16),
                    WenyouStatusBanner(
                      tone: WenyouStatusTone.error,
                      message: state.failure!.userMessage,
                      detail: state.failure!.requestId == null
                          ? null
                          : '请求 ID：${state.failure!.requestId}',
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

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return '请输入注册邮箱';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return '请输入有效的邮箱地址';
  }
  return null;
}

String? _validateNewPassword(String? value) {
  final password = value ?? '';
  if (password.length < 8 || password.length > 100) {
    return '密码需要 8–100 位';
  }
  if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
      !RegExp(r'[0-9]').hasMatch(password)) {
    return '密码必须同时包含字母和数字';
  }
  return null;
}
