import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/settings/application/credential_security_controllers.dart';
import 'package:wenyousite_mobile/features/settings/presentation/security_password_field.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final router = GoRouter.of(context);
    final succeeded = await ref
        .read(passwordChangeControllerProvider.notifier)
        .submit(
          oldPassword: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
        );
    if (!succeeded) return;
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('密码已修改，请重新登录。')));
    }
    // 清会话会触发全局路由守卫，页面可能已被卸载；使用提前捕获的路由
    // 覆盖守卫的原页面回跳，避免重新登录后再次进入凭据表单。
    router.goNamed('login', queryParameters: const {'returnTo': '/me'});
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final state = ref.watch(passwordChangeControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('修改密码')),
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
                    title: '设置新密码',
                    subtitle: '修改成功后，当前账号在所有 Web 和移动终端都会退出。',
                  ),
                  SizedBox(height: tokens.space24),
                  SecurityPasswordField(
                    textFieldKey: const Key('change-password-old'),
                    controller: _oldPasswordController,
                    label: '当前密码',
                    enabled: !state.isSubmitting,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.next,
                    validator: _validateCurrentPassword,
                  ),
                  SizedBox(height: tokens.space16),
                  SecurityPasswordField(
                    textFieldKey: const Key('change-password-new'),
                    controller: _newPasswordController,
                    label: '新密码',
                    helperText: '8–100 位，至少包含一个字母和一个数字',
                    enabled: !state.isSubmitting,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final message = _validateNewPassword(value);
                      if (message != null) return message;
                      return value == _oldPasswordController.text
                          ? '新密码不能与当前密码相同'
                          : null;
                    },
                  ),
                  SizedBox(height: tokens.space16),
                  SecurityPasswordField(
                    textFieldKey: const Key('change-password-confirm'),
                    controller: _confirmPasswordController,
                    label: '确认新密码',
                    enabled: !state.isSubmitting,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: state.isSubmitting
                        ? null
                        : (_) => _submit(),
                    validator: (value) => value == _newPasswordController.text
                        ? null
                        : '两次输入的新密码不一致',
                  ),
                  if (state.failure != null) ...[
                    SizedBox(height: tokens.space16),
                    WenyouStatusBanner(
                      tone: WenyouStatusTone.error,
                      message: state.failure!.userMessage,
                      detail: state.failure!.requestId == null
                          ? null
                          : '请求 ID：${state.failure!.requestId}',
                    ),
                  ],
                  SizedBox(height: tokens.space24),
                  WenyouAsyncPrimaryButton(
                    key: const Key('change-password-submit'),
                    label: '保存新密码',
                    loadingLabel: '正在修改密码',
                    icon: WenyouIconIds.securityPassword,
                    isLoading: state.isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
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
