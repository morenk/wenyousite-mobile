import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android 长正文移动光标后把新选区同步给输入法', (tester) async {
    if (!Platform.isAndroid) return;

    binding.testTextInput
      ..register()
      ..reset();
    addTearDown(binding.testTextInput.unregister);

    final markdown = List.generate(
      80,
      (index) => '第 $index 段用于复现长正文粘贴后的光标同步。',
    ).join('\n\n');
    final session = RichEditorSession(
      initialMarkdown: markdown,
      initialSelection: RichEditorSelectionPlacement.end,
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('zh', 'CN'),
        localizationsDelegates:
            FlutterQuillLocalizations.localizationsDelegates,
        home: Scaffold(
          body: QuillEditor(
            controller: session.controller,
            focusNode: session.focusNode,
            scrollController: session.scrollController,
            config: const QuillEditorConfig(),
          ),
        ),
      ),
    );
    session.focusNode.requestFocus();
    await tester.pumpAndSettle();

    expect(binding.testTextInput.hasAnyClients, isTrue);
    final target =
        session.controller.document.toPlainText().indexOf('第 3 段') + 2;
    session.controller.updateSelection(
      TextSelection.collapsed(offset: target),
      ChangeSource.local,
    );
    await tester.pump();

    final remoteValue = TextEditingValue.fromJSON(
      binding.testTextInput.editingState!,
    );
    expect(remoteValue.selection, TextSelection.collapsed(offset: target));

    final expectedText = remoteValue.text.replaceRange(target - 1, target, '');
    binding.testTextInput.updateEditingValue(
      remoteValue.copyWith(
        text: expectedText,
        selection: TextSelection.collapsed(offset: target - 1),
        composing: TextRange.empty,
      ),
    );
    await tester.pump();

    expect(session.controller.document.toPlainText(), expectedText);
    expect(
      session.controller.selection,
      TextSelection.collapsed(offset: target - 1),
    );
  });
}
