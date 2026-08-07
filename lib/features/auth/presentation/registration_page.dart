import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/internal_location.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/auth/application/registration_controller.dart';

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
  bool _obscurePassword = true;

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: state.step == RegistrationStep.email
                  ? _buildEmailStep(context, state)
                  : _buildVerifyStep(context, state),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(BuildContext context, RegistrationState state) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('创建温油站账号', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '先验证邮箱，再设置用户名和密码。验证码不会保存在本机。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
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
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: _validateEmail,
          ),
          if (state.failure != null) ...[
            const SizedBox(height: 16),
            _FailureCard(failure: state.failure!),
          ],
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('register-request-code'),
            onPressed: state.isBusy || state.resendSecondsRemaining > 0
                ? null
                : _requestCode,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: state.status == RegistrationStatus.requestingCode
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      state.resendSecondsRemaining > 0
                          ? '${state.resendSecondsRemaining} 秒后重试'
                          : '发送验证码',
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: state.isBusy
                ? null
                : () => context.go(_authLocation('/auth/login')),
            child: const Text('已有账号？返回登录'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyStep(BuildContext context, RegistrationState state) {
    final expiryMinutes = ((state.codeExpiresInSeconds ?? 900) / 60).ceil();
    return Form(
      key: _detailsFormKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('查收邮箱验证码', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '验证码已发送至 ${state.email}，有效期约 $expiryMinutes 分钟。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('register-code'),
              controller: _codeController,
              enabled: !state.isBusy,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: const InputDecoration(
                labelText: '6 位验证码',
                prefixIcon: Icon(Icons.verified_outlined),
                counterText: '',
              ),
              maxLength: 6,
              textInputAction: TextInputAction.next,
              validator: (value) => value?.length == 6 ? null : '请输入 6 位数字验证码',
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('register-username'),
              controller: _usernameController,
              enabled: !state.isBusy,
              autofillHints: const [AutofillHints.newUsername],
              decoration: const InputDecoration(
                labelText: '用户名',
                helperText: '2–24 位字母、数字或中文',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              textInputAction: TextInputAction.next,
              validator: _validateUsername,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('register-password'),
              controller: _passwordController,
              enabled: !state.isBusy,
              autofillHints: const [AutofillHints.newPassword],
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: '密码',
                helperText: '8–100 位，至少包含一个字母和一个数字',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: state.isBusy
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
              textInputAction: TextInputAction.next,
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('register-confirm-password'),
              controller: _confirmPasswordController,
              enabled: !state.isBusy,
              obscureText: _obscurePassword,
              decoration: const InputDecoration(
                labelText: '确认密码',
                prefixIcon: Icon(Icons.lock_reset_rounded),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: state.isBusy ? null : (_) => _complete(),
              validator: (value) =>
                  value == _passwordController.text ? null : '两次输入的密码不一致',
            ),
            if (state.failure != null) ...[
              const SizedBox(height: 16),
              _FailureCard(failure: state.failure!),
            ],
            const SizedBox(height: 20),
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
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('register-complete'),
              onPressed: state.isBusy ? null : _complete,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: state.status == RegistrationStatus.completing
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('完成注册并登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _authLocation(String path) {
    return Uri(
      path: path,
      queryParameters: widget.returnTo == null
          ? null
          : {'returnTo': widget.returnTo!},
    ).toString();
  }
}

class _FailureCard extends StatelessWidget {
  const _FailureCard({required this.failure});

  final ApiFailure failure;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(failure.userMessage),
              if (failure.requestId != null) ...[
                const SizedBox(height: 6),
                SelectableText(
                  '请求 ID：${failure.requestId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return '请输入邮箱';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return '请输入有效的邮箱地址';
  }
  return null;
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

String? _validatePassword(String? value) {
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
