import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/internal_location.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_password_field.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/auth/application/login_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({
    this.returnTo,
    this.passwordResetSucceeded = false,
    super.key,
  });

  final String? returnTo;
  final bool passwordResetSucceeded;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final succeeded = await ref
        .read(loginControllerProvider.notifier)
        .submit(
          account: _accountController.text,
          password: _passwordController.text,
        );
    if (succeeded && mounted) {
      context.go(sanitizeReturnLocation(widget.returnTo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final state = ref.watch(loginControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final invalidationMessage = _invalidationMessage(session.reason);
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: WenyouPageBody(
        maxWidth: 480,
        child: WenyouPanel(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WenyouSectionHeader(title: '欢迎回到温油站'),
                if (invalidationMessage != null) ...[
                  SizedBox(height: tokens.space20),
                  WenyouStatusBanner(
                    message: invalidationMessage,
                    tone: WenyouStatusTone.accent,
                    action: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        key: const Key('continue-as-guest'),
                        onPressed: () async {
                          await ref
                              .read(sessionControllerProvider.notifier)
                              .logoutLocally();
                          if (context.mounted) {
                            context.go(AppRouteLocations.home);
                          }
                        },
                        child: const Text('以游客身份继续'),
                      ),
                    ),
                  ),
                ],
                if (widget.passwordResetSucceeded) ...[
                  SizedBox(height: tokens.space20),
                  const WenyouStatusBanner(
                    key: Key('login-password-reset-success'),
                    message: '密码已重置，所有旧登录终端均已退出。请使用新密码重新登录。',
                    tone: WenyouStatusTone.accent,
                  ),
                ],
                SizedBox(height: tokens.space24),
                TextFormField(
                  key: const Key('login-account'),
                  controller: _accountController,
                  enabled: !state.isSubmitting,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  decoration: const InputDecoration(
                    labelText: '邮箱或用户名',
                    prefixIcon: WenyouIcon(WenyouIconIds.identityMember),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? '请输入邮箱或用户名'
                      : null,
                ),
                SizedBox(height: tokens.space16),
                WenyouPasswordField(
                  textFieldKey: const Key('login-password'),
                  controller: _passwordController,
                  enabled: !state.isSubmitting,
                  autofillHints: const [AutofillHints.password],
                  label: '密码',
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: state.isSubmitting
                      ? null
                      : (_) => _submit(),
                  validator: (value) =>
                      value == null || value.isEmpty ? '请输入密码' : null,
                ),
                if (state.failure != null) ...[
                  SizedBox(height: tokens.space16),
                  WenyouFailureBanner(failure: state.failure!),
                ],
                SizedBox(height: tokens.space24),
                WenyouAsyncPrimaryButton(
                  key: const Key('login-submit'),
                  label: '登录并继续',
                  loadingLabel: '正在登录',
                  isLoading: state.isSubmitting,
                  onPressed: _submit,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    key: const Key('login-forgot-password'),
                    onPressed: state.isSubmitting
                        ? null
                        : () => context.pushNamed(
                            'forgot-password',
                            queryParameters: widget.returnTo == null
                                ? const {}
                                : {'returnTo': widget.returnTo!},
                          ),
                    child: const Text('忘记密码？'),
                  ),
                ),
                SizedBox(height: tokens.space8),
                TextButton(
                  key: const Key('login-register'),
                  onPressed: state.isSubmitting
                      ? null
                      : () => context.push(
                          AppRouteLocations.register(returnTo: widget.returnTo),
                        ),
                  child: const Text('没有账号？注册'),
                ),
                TextButton.icon(
                  key: const Key('login-open-appeals'),
                  onPressed: state.isSubmitting
                      ? null
                      : () => context.push(AppRouteLocations.moderationAppeals),
                  icon: const WenyouIcon(WenyouIconIds.moderationDecision),
                  label: const Text('账号被暂停或封禁？查看决定并申诉'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _invalidationMessage(SessionInvalidationReason? reason) {
  return switch (reason) {
    SessionInvalidationReason.revoked => '当前登录已被撤销，请重新登录。',
    SessionInvalidationReason.compromised => '检测到登录安全风险，请重新登录。',
    SessionInvalidationReason.locked => '账号已被锁定，请联系站点管理员。',
    SessionInvalidationReason.deactivated => '账号已注销，当前会话已退出。',
    SessionInvalidationReason.refreshFailed => '登录已失效，请重新登录。',
    null => null,
  };
}
