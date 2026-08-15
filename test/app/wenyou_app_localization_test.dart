import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('输入框长按编辑菜单使用中文', (tester) async {
    final controller = TextEditingController(text: '可编辑文字');
    addTearDown(controller.dispose);
    late MaterialLocalizations labels;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: Builder(
            builder: (context) {
              labels = MaterialLocalizations.of(context);
              return TextField(
                key: const Key('localization-text-field'),
                controller: controller,
              );
            },
          ),
        ),
      ),
    );
    expect(labels.cutButtonLabel, '剪切');
    expect(labels.copyButtonLabel, '复制');
    expect(labels.pasteButtonLabel, '粘贴');
    expect(labels.selectAllButtonLabel, '全选');
  });
}
