abstract final class CredentialInputPolicy {
  static String? validateEmail(String? value, {String emptyMessage = '请输入邮箱'}) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return emptyMessage;
    if (email.runes.length > 254) return '邮箱不能超过 254 个字符';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  static String? validateNewPassword(String? value) {
    final password = value ?? '';
    if (password.runes.length < 8 || password.runes.length > 100) {
      return '密码需要 8–100 位';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password)) {
      return '密码必须同时包含字母和数字';
    }
    return null;
  }

  static String? validateCurrentPassword(
    String? value, {
    int minimumLength = 1,
    int? maximumLength = 100,
    String emptyMessage = '请输入当前密码',
  }) {
    final password = value ?? '';
    if (password.isEmpty) return emptyMessage;
    if (password.runes.length < minimumLength) return '密码至少 $minimumLength 个字符';
    if (maximumLength != null && password.runes.length > maximumLength) {
      return '密码不能超过 $maximumLength 位';
    }
    return null;
  }
}
