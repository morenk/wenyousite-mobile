import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/wenyou_app.dart';

void main() {
  testWidgets('输入框长按编辑菜单使用中文', (tester) async {
    final controller = TextEditingController(text: '可编辑文字');
    addTearDown(controller.dispose);
    late MaterialLocalizations labels;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN')],
        localizationsDelegates: wenyouLocalizationsDelegates,
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
    expect(
      wenyouLocalizationsDelegates,
      contains(FlutterQuillLocalizations.delegate),
    );
    expect(
      FlutterQuillLocalizations.of(
        tester.element(find.byKey(const Key('localization-text-field'))),
      ),
      isNotNull,
    );
  });

  testWidgets('编辑器长按已有链接可打开中文操作菜单', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final controller = QuillController(
      document: Document.fromDelta(
        Delta()
          ..insert('已有链接', {'link': 'https://example.com'})
          ..insert('\n'),
      ),
      selection: const TextSelection.collapsed(offset: 0),
    );
    final focusNode = FocusNode();
    final scrollController = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN')],
        localizationsDelegates: wenyouLocalizationsDelegates,
        home: Scaffold(
          body: SizedBox(
            height: 80,
            child: QuillEditor(
              key: const Key('localized-link-editor'),
              controller: controller,
              focusNode: focusNode,
              scrollController: scrollController,
              config: const QuillEditorConfig(scrollable: false),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final editor = find.byKey(const Key('localized-link-editor'));
    await tester.longPressAt(tester.getTopLeft(editor) + const Offset(24, 14));
    await tester.pumpAndSettle();

    expect(find.text('打开'), findsOneWidget);
    expect(find.text('复制'), findsOneWidget);
    expect(find.text('移除'), findsOneWidget);
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });
}
