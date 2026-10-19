import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/text_tool.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/toolbox_location_policy.dart';

void main() {
  test('正式环境固定 HTTPS 来源和四个公开工具', () {
    final policy = ToolboxLocationPolicy();
    for (final tool in TextTool.values) {
      expect(
        policy.location(tool, dark: true).toString(),
        'https://wenyou.site/tools/embed/${tool.id}?theme=dark',
      );
      expect(
        policy.allows(policy.location(tool, dark: false).toString()),
        true,
      );
    }
    expect(policy.allows('https://wenyou.site/tools/embed'), true);
  });

  test('阻止站外、认证、任意路径、参数与文件 scheme 导航', () {
    final policy = ToolboxLocationPolicy();
    for (final url in [
      'https://wenyou.site.evil.test/tools/embed/vertical',
      'https://evil.test/tools/embed/vertical',
      'https://wenyou.site/auth/login',
      'https://wenyou.site/tools/vertical',
      'https://wenyou.site/tools/embed/unknown',
      'https://wenyou.site/tools/embed/vertical/extra',
      'https://wenyou.site/tools/embed/vertical?text=secret',
      'https://wenyou.site/tools/embed/vertical?theme=dark&theme=light',
      'https://wenyou.site/tools/embed/vertical?theme=system',
      'https://wenyou.site/tools/embed/vertical#secret',
      'https://user@wenyou.site/tools/embed/vertical',
      'http://wenyou.site/tools/embed/vertical',
      'file:///tools/embed/vertical',
      'javascript:alert(1)',
      'intent://toolbox',
      'data:text/html,hello',
      'about:blank',
    ]) {
      expect(policy.allows(url), false, reason: url);
    }
  });
}
