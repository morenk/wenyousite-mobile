import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/credential_input_policy.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_password_field.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_verification_code_field.dart';
import 'package:wenyousite_mobile/features/settings/application/credential_security_controllers.dart';

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
      showWenyouSnackBar(
        context,
        '邮箱已更换，请重新登录。',
        pacing: WenyouSnackBarPacing.extended,
      );
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
            const WenyouSectionHeader(title: '验证新邮箱'),
            SizedBox(height: tokens.space24),
            WenyouPasswordField(
              textFieldKey: const Key('change-email-password'),
              controller: _oldPasswordController,
              label: '当前密码',
              enabled: !state.isBusy,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.next,
              validator: CredentialInputPolicy.validateCurrentPassword,
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
              validator: (value) => CredentialInputPolicy.validateEmail(
                value,
                emptyMessage: '请输入新邮箱',
              ),
              decoration: const InputDecoration(
                labelText: '新邮箱',
                prefixIcon: WenyouIcon(WenyouIconIds.statusMail),
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
              icon: WenyouIconIds.actionSend,
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
            subtitle: state.codeDeliveryUncertain
                ? '邮件可能已经发出，请在 ${state.email} 查收并继续输入验证码。'
                : '验证码已发送至 ${state.email}。确认后所有终端都会退出。',
          ),
          if (state.codeDeliveryUncertain) ...[
            SizedBox(height: tokens.space12),
            WenyouStatusBanner(
              key: const Key('change-email-code-delivery-uncertain'),
              message: '邮件可能已经发出',
              detail: state.failure?.requestId == null
                  ? '请保留当前验证码输入；为避免重复邮件，60 秒内不会重发。'
                  : '请保留当前输入；问题编号：${state.failure!.requestId}',
            ),
          ],
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
          WenyouVerificationCodeField(
            textFieldKey: const Key('change-email-code'),
            controller: _codeController,
            enabled: !state.isBusy,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: state.isBusy ? null : (_) => _verifyCode(),
          ),
          if (state.failure != null && !state.codeDeliveryUncertain) ...[
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
            icon: WenyouIconIds.actionMarkRead,
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
    return WenyouFailureBanner(
      failure: state.failure!,
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
