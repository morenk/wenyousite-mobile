import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_text_elements.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/domain/mention_models.dart';

void main() {
  final longName = List.filled(24, '🐦').join();
  final source = '[@$longName](/users/user-one)';

  test('24 emoji RP昵称能作为结构化提及完整往返', () {
    final document = MarkdownDeltaCodec.decode(source);
    expect(
      document.delta.toJson().any(
        (op) =>
            op['insert'] is Map &&
            (op['insert'] as Map).containsKey(MarkdownDeltaCodec.mentionEmbed),
      ),
      isTrue,
    );
    expect(MarkdownDeltaCodec.encode(document.delta), source);
    expect(
      detectActiveMentionQuery('@$longName', longName.length + 1)?.query,
      longName,
    );
  });

  test('搜索摘要只按账号和原标签投影，普通文字保持原样', () {
    const source = '[@白鸦](/users/one) [@白鸦](/users/two) [@夜渡](/users/one) 普通白鸦';
    expect(
      MarkdownContent.toPlainTextPreview(
        source,
        mentionLabels: const {'one\u0000白鸦': '小明', 'one\u0000夜渡': '小明'},
      ),
      '@小明 @白鸦 @小明 普通白鸦',
    );
  });

  testWidgets('长昵称在关闭投影后显示账号，切换映射不复用旧渲染', (tester) async {
    Uri? opened;
    Future<void> pump(Map<String, String> labels) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouMarkdown(
            data: source,
            mentionLabels: labels,
            onInternalLink: (uri) => opened = uri,
          ),
        ),
      ),
    );
    await pump({});
    expect(find.byType(WenyouMentionLink), findsOneWidget);
    expect(find.text('@$longName'), findsOneWidget);
    await pump({'user-one\u0000$longName': '站内账号'});
    expect(find.text('@站内账号'), findsOneWidget);
    expect(find.text('@$longName'), findsNothing);
    await tester.tap(find.text('@站内账号'));
    expect(opened?.path, '/users/user-one');
  });
}
