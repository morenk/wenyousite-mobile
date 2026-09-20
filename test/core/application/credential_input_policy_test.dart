import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/credential_input_policy.dart';

void main() {
  test('密码8到100限制使用码点且不改变密码内容', () {
    expect(
      CredentialInputPolicy.validateNewPassword('a1${'😀' * 3}'),
      isNotNull,
    );
    expect(CredentialInputPolicy.validateNewPassword('a1${'😀' * 6}'), isNull);
    expect(CredentialInputPolicy.validateNewPassword('a1${'😀' * 98}'), isNull);
    expect(
      CredentialInputPolicy.validateNewPassword('a1${'😀' * 99}'),
      isNotNull,
    );
    expect(
      CredentialInputPolicy.validateCurrentPassword('a1${'😀' * 98}'),
      isNull,
    );
    expect(CredentialInputPolicy.validateCurrentPassword('旧密码'), isNull);
    expect(CredentialInputPolicy.validateNewPassword(' a1😀😀😀😀 '), isNull);
  });
  test('邮箱超过254字符在提交前拦截', () {
    expect(
      CredentialInputPolicy.validateEmail('${'a' * 244}@example.cn'),
      isNotNull,
    );
    expect(CredentialInputPolicy.validateEmail('member@example.cn'), isNull);
  });
}
