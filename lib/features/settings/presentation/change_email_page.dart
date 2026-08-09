import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/settings/application/credential_security_controllers.dart';
import 'package:wenyousite_mobile/features/settings/domain/credential_security_models.dart';
import 'package:wenyousite_mobile/features/settings/presentation/security_password_field.dart';

class ChangeEmailPage extends ConsumerStatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  ConsumerState<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends ConsumerState<ChangeEmailPage> {
  final _requestFormKey = GlobalKey<FormState>();
  final _verifyFormKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final state = ref.read(emailChangeControllerProvider);
    if (state.step == EmailChangeStep.requestCode &&
        !(_requestFormKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    await ref
        .read(emailChangeControllerProvider.notifier)
        .requestCode(
          newEmail: _emailController.text,
          oldPassword: _oldPasswordController.text,
        );
  }

  Future<void> _verifyCode() async {
    if (!(_verifyFormKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final router = GoRouter.of(context);
    final succeeded = await ref
        .read(emailChangeControllerProvider.notifier)
        .verifyCode(_codeController.text);
    if (!succeeded) return;
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('邮箱已更换，请重新登录。')));
    }
    // 清会话会触发全局路由守卫，页面可能已被卸载；使用提前捕获的路由
    // 覆盖守卫的原页面回跳，避免重新登录后再次进入凭据表单。
    router.goNamed('login', queryParameters: const {'returnTo': '/me'});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emailChangeControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('更换邮箱')),
      body: WenyouPageBody(
        maxWidth: 520,
        child: WenyouPanel(
          child: state.step == EmailChangeStep.requestCode
              ? _buildRequestStep(context, state)
              : _buildVerifyStep(context, state),
        ),
      ),
    );
  }

  Widget _buildRequestStep(BuildContext context, EmailChangeState state) {
    final tokens = context.wenyouTokens;
    final buttonLabel = state.resendSecondsRemaining > 0
        ? '${state.resendSecondsRemaining} 秒后重试'
        : '发送验证码';
    return Form(
      key: _requestFormKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WenyouSectionHeader(
              title: '验证新邮箱',
              subtitle: '先用当前密码确认身份，再向新邮箱发送 6 位验证码。',
            ),
            SizedBox(height: tokens.space24),
            SecurityPasswordField(
              textFieldKey: const Key('change-email-password'),
              controller: _oldPasswordController,
              label: '当前密码',
              enabled: !state.isBusy,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.next,
              validator: _validateCurrentPassword,
            ),
            SizedBox(height: tokens.space16),
            TextFormField(
              key: const Key('change-email-address'),
              controller: _emailController,
              enabled: !state.isBusy,
              autofillHints: const [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: state.isBusy ? null : (_) => _requestCode(),
              validator: _validateEmail,
              decoration: const InputDecoration(
                labelText: '新邮箱',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            if (state.failure != null) ...[
              SizedBox(height: tokens.space16),
              _FailureBanner(state: state),
            ],
            SizedBox(height: tokens.space24),
            WenyouAsyncPrimaryButton(
              key: const Key('change-email-request-code'),
              label: buttonLabel,
              loadingLabel: '正在发送验证码',
              icon: Icons.outgoing_mail,
              isLoading: state.isRequestingCode,
              onPressed: state.isBusy || state.resendSecondsRemaining > 0
                  ? null
                  : _requestCode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyStep(BuildContext context, EmailChangeState state) {
    final tokens = context.wenyouTokens;
    final canResend = !state.isBusy && state.resendSecondsRemaining == 0;
    return Form(
      key: _verifyFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WenyouSectionHeader(
            title: '查收新邮箱验证码',
            subtitle: '验证码已发送至 ${state.email}。确认后所有终端都会退出。',
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const Key('change-email-edit-address'),
              onPressed: state.isBusy
                  ? null
                  : () {
                      ref
                          .read(emailChangeControllerProvider.notifier)
                          .editEmail();
                      _codeController.clear();
                    },
              child: const Text('更换新邮箱'),
            ),
          ),
          SizedBox(height: tokens.space8),
          TextFormField(
            key: const Key('change-email-code'),
            controller: _codeController,
            enabled: !state.isBusy,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            maxLength: 6,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: state.isBusy ? null : (_) => _verifyCode(),
            validator: (value) => value?.length == 6 ? null : '请输入 6 位数字验证码',
            decoration: const InputDecoration(
              labelText: '6 位验证码',
              counterText: '',
              prefixIcon: Icon(Icons.verified_outlined),
            ),
          ),
          if (state.failure != null) ...[
            SizedBox(height: tokens.space16),
            _FailureBanner(state: state),
          ],
          SizedBox(height: tokens.space16),
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
                key: const Key('change-email-resend-code'),
                onPressed: canResend ? _requestCode : null,
                child: Text(state.isRequestingCode ? '发送中' : '重新发送'),
              ),
            ],
          ),
          SizedBox(height: tokens.space8),
          WenyouAsyncPrimaryButton(
            key: const Key('change-email-verify'),
            label: '确认更换邮箱',
            loadingLabel: '正在更换邮箱',
            icon: Icons.mark_email_read_outlined,
            isLoading: state.isVerifying,
            onPressed: state.isBusy ? null : _verifyCode,
          ),
        ],
      ),
    );
  }
}

class _FailureBanner extends ConsumerWidget {
  const _FailureBanner({required this.state});

  final EmailChangeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WenyouStatusBanner(
      tone: WenyouStatusTone.error,
      message: state.failure!.userMessage,
      detail: state.failure!.requestId == null
          ? null
          : '请求 ID：${state.failure!.requestId}',
      action: TextButton(
        key: const Key('change-email-error-dismiss'),
        onPressed: ref
            .read(emailChangeControllerProvider.notifier)
            .clearFailure,
        child: const Text('知道了'),
      ),
    );
  }
}

String? _validateCurrentPassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return '请输入当前密码';
  if (password.length > 100) return '密码不能超过 100 位';
  return null;
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return '请输入新邮箱';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return '请输入有效的邮箱地址';
  }
  return null;
}
