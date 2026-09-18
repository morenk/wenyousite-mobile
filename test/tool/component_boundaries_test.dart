import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/architecture/component_checks.dart';

void main() {
  late Directory root;
  setUp(() => root = Directory.systemTemp.createTempSync('wenyou-components-'));
  tearDown(() => root.deleteSync(recursive: true));

  List<String> check(String source, {String? path}) {
    final file = File(
      '${root.path}/${path ?? 'lib/features/example/presentation/page.dart'}',
    );
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(source);
    final failures = <String>[];
    checkComponentBoundaries([file], failures, root);
    return failures;
  }

  test('拒绝新增原始确认、异步按钮和分页按钮', () {
    expect(
      check('''
class Page {
  build() => Column(children: [
    AlertDialog(title: Text('删除？')),
    FilledButton(child: CircularProgressIndicator()),
    OutlinedButton.icon(label: Text('加载更多')),
  ]);
}
'''),
      hasLength(3),
    );
  });

  test('共享组件及说明文字不误报', () {
    expect(
      check('''
class Page {
  build() => Column(children: [
    WenyouAsyncButton(label: '保存'),
    WenyouLoadMoreControl(hasMore: true),
    Text('AlertDialog()'),
  ]);
}
'''),
      isEmpty,
    );
  });

  test('专用表单例外不能扩散到同文件的新确认方法', () {
    expect(
      check('''
class _ReportDialogState {
  build() => AlertDialog(content: Form());
  delete() => AlertDialog(title: Text('删除？'));
}
''', path: 'lib/features/reports/presentation/report_widgets.dart'),
      hasLength(1),
    );
  });
}
