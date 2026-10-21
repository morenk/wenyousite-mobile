import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/production_overrides.dart';
import 'package:wenyousite_mobile/core/application/atomic_editor_clipboard.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_atomic_text_editor.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_atomic_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';

class _Gateway implements EditorClipboardGateway {
  const _Gateway(this.snapshot);
  final EditorClipboardSnapshot snapshot;
  @override
  Future<EditorClipboardSnapshot> read() async => snapshot;
  @override
  Future<void> write({required String text, required String marker}) async {}
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const source =
      '<span data-wenyou-font-v1="wenkai" data-wenyou-color-v1="#D14343">**文字**</span> [传送门](/threads/aaaaaaaaaaaaaaaaaaaaaaaa)';
  test('应用入口装配结构化剪贴板，跨模块只依赖协作接口', () async {
    var called = false;
    final container = ProviderContainer(
      overrides: [
        ...productionProviderOverrides(),
        editorAtomicClipboardReaderProvider.overrideWithValue((text) async {
          called = text == '正文';
          return null;
        }),
      ],
    );
    addTearDown(container.dispose);
    await container.read(atomicEditorClipboardReaderProvider)('正文');
    expect(called, isTrue);
  });
  for (final scope in ['account', 'other-account']) {
    for (final version in [1, 2]) {
      test('主题→动态/评论/私聊：去字体v$version但保留受信传送门，scope=$scope', () async {
        final store = WenyouEditorClipboardStore();
        final delta = MarkdownDeltaCodec.decode(
          version == 1
              ? source
              : source.replaceFirst(
                  'data-wenyou-font-v1="wenkai"',
                  'data-wenyou-font-v2="tfv_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"',
                ),
        ).delta;
        final fallback = WenyouEditorClipboardStore.visibleText(delta);
        store.capture(
          delta: delta,
          plainTextFallback: fallback,
          operation: WenyouEditorClipboardOperation.copy,
          marker: 'marker',
          scope: 'account',
        );
        binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async =>
              call.method == 'Clipboard.getData' ? {'text': fallback} : null,
        );
        addTearDown(
          () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        final controller = WenyouAtomicTextController(
          initialMarkdown: '',
          maximumMarkdownLength: 1000,
          readStructuredClipboard: (text) => readAtomicEditorClipboard(
            text,
            scope: scope,
            store: store,
            gateway: _Gateway(
              EditorClipboardSnapshot(text: fallback, marker: 'marker'),
            ),
          ),
        );
        addTearDown(controller.dispose);
        expect(await controller.pasteClipboard(), isTrue);
        await Future<void>.delayed(Duration.zero);
        expect(
          controller.markdown,
          scope == 'account'
              ? '文字 [传送门](/threads/aaaaaaaaaaaaaaaaaaaaaaaa)'
              : fallback,
        );
        expect(
          controller.quillController.document.toDelta().operations.every(
            (o) => o.attributes == null || o.attributes!.isEmpty,
          ),
          isTrue,
        );
        if (scope == 'account') {
          expect(
            controller.quillController.document.toDelta().operations.any(
              (o) =>
                  o.data is Map &&
                  (o.data as Map).containsKey(
                    MarkdownDeltaCodec.internalReferenceEmbed,
                  ),
            ),
            isTrue,
          );
        }
      });
    }
  }
  test('外部HTML、伪造marker或过期载体不能导入结构化内容', () async {
    for (final marker in <String?>[null, 'wrong']) {
      final store = WenyouEditorClipboardStore();
      final delta = MarkdownDeltaCodec.decode(source).delta;
      store.capture(
        delta: delta,
        plainTextFallback: '文字 传送门',
        operation: WenyouEditorClipboardOperation.copy,
        marker: 'valid',
        scope: 'account',
      );
      final result = await readAtomicEditorClipboard(
        '文字 传送门',
        scope: 'account',
        store: store,
        gateway: _Gateway(
          EditorClipboardSnapshot(
            text: '文字 传送门',
            marker: marker,
            html:
                '<div data-wenyou-clipboard="2"><a href="/threads/aaaaaaaaaaaaaaaaaaaaaaaa">传送门</a></div>',
          ),
        ),
      );
      expect(result, isNull);
    }
    final store = WenyouEditorClipboardStore(
      maximumAge: const Duration(seconds: -1),
    );
    store.capture(
      delta: MarkdownDeltaCodec.decode(source).delta,
      plainTextFallback: '文字 传送门',
      operation: WenyouEditorClipboardOperation.copy,
      marker: 'valid',
      scope: 'account',
    );
    expect(
      await readAtomicEditorClipboard(
        '文字 传送门',
        scope: 'account',
        store: store,
        gateway: const _Gateway(
          EditorClipboardSnapshot(text: '文字 传送门', marker: 'valid'),
        ),
      ),
      isNull,
    );
  });
}
