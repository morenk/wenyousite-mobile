import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_write_guard.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

void main() {
  const rp = '[@白鸦](/users/account?rpIdentityId=caaaaaaaaaaaaaaaaaaaaaaaa)';
  const account = '[@账号](/users/account?identityMode=ACCOUNT)';
  test('旧服务拦截粘贴或恢复的明确目标，新服务保留完整源', () {
    for (final source in [rp, account]) {
      expect(
        () => requireMentionWriteSupport(source, supported: false),
        throwsA(isA<ApiFailure>().having((e) => e.businessCode, '业务码', 40014)),
      );
      expect(
        () => requireMentionWriteSupport(source, supported: true),
        returnsNormally,
      );
    }
  });
  test('旧账号节点和代码示例不误拦截', () {
    for (final source in [
      '正文',
      '[@账号](/users/account)',
      '`$rp`',
      '```\n$rp\n```',
      '\\$rp',
    ]) {
      expect(
        () => requireMentionWriteSupport(source, supported: false),
        returnsNormally,
      );
    }
  });
}
