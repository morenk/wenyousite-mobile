import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/internal_location.dart';

void main() {
  test('登录回跳只接受非认证的仓库内绝对路径', () {
    expect(sanitizeReturnLocation('/compose/thread'), '/compose/thread');
    expect(sanitizeReturnLocation('/me?tab=sessions'), '/me?tab=sessions');
    expect(sanitizeReturnLocation(null), '/home');
    expect(sanitizeReturnLocation('https://example.com'), '/home');
    expect(sanitizeReturnLocation('//example.com'), '/home');
    expect(sanitizeReturnLocation('/auth/login'), '/home');
  });
}
