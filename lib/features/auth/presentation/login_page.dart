import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/internal_location.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/auth/application/login_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({this.returnTo, super.key});

  final String? returnTo;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
    final state = ref.watch(loginControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final invalidationMessage = _invalidationMessage(session.reason);
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '欢迎回到温油站',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '使用邮箱或用户名登录。登录后会继续刚才的操作。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (invalidationMessage != null) ...[
                      const SizedBox(height: 20),
                      Semantics(
                        liveRegion: true,
                        child: Card(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(invalidationMessage),
                                const SizedBox(height: 8),
                                TextButton(
                                  key: const Key('continue-as-guest'),
                                  onPressed: () async {
                                    await ref
                                        .read(
                                          sessionControllerProvider.notifier,
                                        )
                                        .logoutLocally();
                                    if (context.mounted) context.go('/home');
                                  },
                                  child: const Text('以游客身份继续'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
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
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? '请输入邮箱或用户名'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('login-password'),
                      controller: _passwordController,
                      enabled: !state.isSubmitting,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: '密码',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                          tooltip: _obscurePassword ? '显示密码' : '隐藏密码',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: state.isSubmitting
                          ? null
                          : (_) => _submit(),
                      validator: (value) =>
                          value == null || value.isEmpty ? '请输入密码' : null,
                    ),
                    if (state.failure != null) ...[
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(state.failure!.userMessage),
                                if (state.failure!.requestId != null) ...[
                                  const SizedBox(height: 6),
                                  SelectableText(
                                    '请求 ID：${state.failure!.requestId}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('login-submit'),
                      onPressed: state.isSubmitting ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: state.isSubmitting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('登录并继续'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      key: const Key('login-register'),
                      onPressed: state.isSubmitting
                          ? null
                          : () => context.push(
                              Uri(
                                path: '/auth/register',
                                queryParameters: widget.returnTo == null
                                    ? null
                                    : {'returnTo': widget.returnTo!},
                              ).toString(),
                            ),
                      child: const Text('没有账号？注册'),
                    ),
                  ],
                ),
              ),
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
