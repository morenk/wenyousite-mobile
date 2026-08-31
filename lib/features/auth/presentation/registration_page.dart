import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/internal_location.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/credential_input_policy.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_password_field.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_verification_code_field.dart';
import 'package:wenyousite_mobile/features/auth/application/registration_controller.dart';
import 'package:wenyousite_mobile/features/auth/presentation/auth_brand_header.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({this.returnTo, super.key});

  final String? returnTo;

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _emailFormKey = GlobalKey<FormState>();
  final _detailsFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref
        .read(registrationControllerProvider.notifier)
        .requestCode(_emailController.text);
  }

  Future<void> _complete() async {
    if (!(_detailsFormKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final succeeded = await ref
        .read(registrationControllerProvider.notifier)
        .complete(
          code: _codeController.text,
          username: _usernameController.text,
          password: _passwordController.text,
        );
    if (succeeded && mounted) {
      context.go(sanitizeReturnLocation(widget.returnTo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: WenyouPageBody(
        maxWidth: 480,
        child: WenyouPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthBrandHeader(),
              SizedBox(height: context.wenyouTokens.space24),
              state.step == RegistrationStep.email
                  ? _buildEmailStep(context, state)
                  : _buildVerifyStep(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(BuildContext context, RegistrationState state) {
    final tokens = context.wenyouTokens;
    final buttonLabel = state.resendSecondsRemaining > 0
        ? '${state.resendSecondsRemaining} 秒后重试'
        : '发送验证码';
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WenyouSectionHeader(title: '创建温油站账号'),
          SizedBox(height: tokens.space24),
          TextFormField(
            key: const Key('register-email'),
            controller: _emailController,
            enabled: !state.isBusy,
            autofillHints: const [AutofillHints.email],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: state.isBusy ? null : (_) => _requestCode(),
            decoration: const InputDecoration(
              labelText: '邮箱',
              prefixIcon: WenyouIcon(WenyouIconIds.statusMail),
            ),
            validator: CredentialInputPolicy.validateEmail,
          ),
          if (state.failure != null) ...[
            SizedBox(height: tokens.space16),
            WenyouFailureBanner(failure: state.failure!),
          ],
          SizedBox(height: tokens.space24),
          WenyouAsyncPrimaryButton(
            key: const Key('register-request-code'),
            label: buttonLabel,
            loadingLabel: '正在发送验证码',
            isLoading: state.status == RegistrationStatus.requestingCode,
            onPressed: state.isBusy || state.resendSecondsRemaining > 0
                ? null
                : _requestCode,
          ),
          SizedBox(height: tokens.space8),
          TextButton(
            onPressed: state.isBusy
                ? null
                : () => context.go(
                    AppRouteLocations.login(returnTo: widget.returnTo),
                  ),
            child: const Text('已有账号？返回登录'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyStep(BuildContext context, RegistrationState state) {
    final tokens = context.wenyouTokens;
    final expiryMinutes = ((state.codeExpiresInSeconds ?? 900) / 60).ceil();
    return Form(
      key: _detailsFormKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WenyouSectionHeader(
              title: '查收邮箱验证码',
              subtitle: state.codeDeliveryUncertain
                  ? '邮件可能已经发出，请在 ${state.email} 查收并继续输入验证码。'
                  : '验证码已发送至 ${state.email}，有效期约 $expiryMinutes 分钟。',
            ),
            if (state.codeDeliveryUncertain) ...[
              SizedBox(height: tokens.space12),
              WenyouStatusBanner(
                key: const Key('register-code-delivery-uncertain'),
                message: '邮件可能已经发出',
                detail: [
                  '请检查收件箱和垃圾邮件；为避免重复邮件，60 秒内不会自动或手动重发。',
                  ?wenyouFailureDetail(state.failure, treatAsWrite: true),
                ].join('\n'),
              ),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('register-edit-email'),
                onPressed: state.isBusy
                    ? null
                    : () {
                        ref
                            .read(registrationControllerProvider.notifier)
                            .editEmail();
                        _codeController.clear();
                        _passwordController.clear();
                        _confirmPasswordController.clear();
                      },
                child: const Text('修改邮箱'),
              ),
            ),
            SizedBox(height: tokens.space8),
            WenyouVerificationCodeField(
              textFieldKey: const Key('register-code'),
              controller: _codeController,
              enabled: !state.isBusy,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: tokens.space16),
            TextFormField(
              key: const Key('register-username'),
              controller: _usernameController,
              enabled: !state.isBusy,
              autofillHints: const [AutofillHints.newUsername],
              decoration: const InputDecoration(
                labelText: '用户名',
                helperText: '2–24 位字母、数字或中文',
                prefixIcon: WenyouIcon(WenyouIconIds.identityMember),
              ),
              textInputAction: TextInputAction.next,
              validator: _validateUsername,
            ),
            SizedBox(height: tokens.space16),
            WenyouPasswordField(
              textFieldKey: const Key('register-password'),
              controller: _passwordController,
              enabled: !state.isBusy,
              autofillHints: const [AutofillHints.newPassword],
              label: '密码',
              helperText: '8–100 位，至少包含一个字母和一个数字',
              textInputAction: TextInputAction.next,
              validator: CredentialInputPolicy.validateNewPassword,
            ),
            SizedBox(height: tokens.space16),
            WenyouPasswordField(
              textFieldKey: const Key('register-confirm-password'),
              controller: _confirmPasswordController,
              enabled: !state.isBusy,
              label: '确认密码',
              prefixIcon: WenyouIconIds.actionResetPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: state.isBusy ? null : (_) => _complete(),
              validator: (value) =>
                  value == _passwordController.text ? null : '两次输入的密码不一致',
            ),
            if (state.failure != null && !state.codeDeliveryUncertain) ...[
              SizedBox(height: tokens.space16),
              WenyouFailureBanner(failure: state.failure!),
            ],
            SizedBox(height: tokens.space20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.resendSecondsRemaining > 0
                        ? '${state.resendSecondsRemaining} 秒后可重发'
                        : '没有收到验证码？',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton(
                  key: const Key('register-resend-code'),
                  onPressed: state.isBusy || state.resendSecondsRemaining > 0
                      ? null
                      : () => ref
                            .read(registrationControllerProvider.notifier)
                            .resendCode(),
                  child: const Text('重新发送'),
                ),
              ],
            ),
            SizedBox(height: tokens.space8),
            WenyouAsyncPrimaryButton(
              key: const Key('register-complete'),
              label: '完成注册并登录',
              loadingLabel: '正在完成注册',
              isLoading: state.status == RegistrationStatus.completing,
              onPressed: state.isBusy ? null : _complete,
            ),
          ],
        ),
      ),
    );
  }
}

String? _validateUsername(String? value) {
  final username = value?.trim() ?? '';
  if (username.length < 2 || username.length > 24) {
    return '用户名需要 2–24 位';
  }
  if (!RegExp(r'^[A-Za-z0-9\u4E00-\u9FFF]+$').hasMatch(username)) {
    return '用户名只能包含字母、数字或中文';
  }
  return null;
}
