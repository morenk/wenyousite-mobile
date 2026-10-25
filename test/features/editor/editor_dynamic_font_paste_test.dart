import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_dynamic_font_paste.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../core/text_fonts/dynamic_font_fixture.dart';
import '../../support/editor_test_paste.dart';
import '../../support/text_color_assertions.dart';

class _Service extends TextFontService {
  _Service() : super(WenyouApi(), observePlatform: false);
  final queried = <String>{};
  @override
  Future<void> checkPasteVersions(Set<String> ids) async => queried.addAll(ids);
}

class _Gateway implements EditorClipboardGateway {
  _Gateway(this.id);
  final String id;
  @override
  Future<EditorClipboardSnapshot> read() async => EditorClipboardSnapshot(
    text: '来源',
    html:
        '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="editor">'
        '<span data-wenyou-font-v2="$id" data-wenyou-color-v1="#D14343"><strong>来源</strong></span></div>',
  );
  @override
  Future<void> write({required String text, required String marker}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final status in ['published', 'disabled', 'withdrawn', 'unknown']) {
    test('动态历史版本$status：新增粘贴权限、原范围保源及保存重开', () async {
      final directory = await Directory.systemTemp.createTemp('font-paste-v2-');
      final service = _Service();
      final runtime = TextFontRuntime(
        cache: TextFontCache(directory),
        download: (_) async => throw StateError('粘贴不得下载字体'),
      );
      service.dynamicRuntime = DynamicFontRuntime(
        runtime: runtime,
        window: service.window,
        elapsed: () => Duration.zero,
        cancel: (_) {},
        read: (_, _, _, {etag}) async => null,
      );
      final font = DynamicFontFixture();
      if (status != 'unknown') {
        service.dynamicRuntime!.catalog.acceptVersion(
          font.dto(
            current: false,
            enabled: status != 'disabled',
            withdrawn: status == 'withdrawn',
          ),
        );
      }
      addTearDown(() async {
        service.dispose();
        runtime.dispose();
        await directory.delete(recursive: true);
      });
      final original = '<span data-wenyou-font-v2="${font.id}">甲乙</span>';
      final session = RichEditorSession(
        initialMarkdown: original,
        onMarkdownChanged: (_) {},
        clipboardStore: WenyouEditorClipboardStore(),
        clipboardGateway: _Gateway(font.id),
        preparePastedFonts: (value) => prepareDynamicFontPaste(value, service),
      );
      addTearDown(session.dispose);
      session.controller.updateSelection(
        const TextSelection.collapsed(offset: 1),
        ChangeSource.local,
      );
      await pasteEditorClipboard(session.controller);
      expect(service.queried, {font.id});
      expect(session.controller.document.toPlainText(), '甲来源乙\n');
      final expected = colorExpectedUnits([
        ('甲', {'font': font.id}),
        (
          '来源',
          {
            if (status == 'published') 'font': font.id,
            'color': '#D14343',
            'bold': true,
          },
        ),
        ('乙', {'font': font.id}),
      ]);
      expect(
        colorDeltaUnits(session.controller.document.toDelta()).take(4),
        expected,
      );
      expect(await session.flush(), isTrue);
      final saved = session.localMarkdown;
      expect(colorReaderUnits(colorReaderNodes(saved)).take(4), expected);
      final reopened = RichEditorSession(
        initialMarkdown: saved,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(
        colorDeltaUnits(reopened.controller.document.toDelta()).take(4),
        expected,
      );
    });
  }
}
