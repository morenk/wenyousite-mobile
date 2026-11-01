import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_widgets.dart';
import 'package:wenyousite_mobile/features/media/reading_gallery.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_comment_body.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_page.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_reading_body.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_sections.dart';

import '../support/deterministic_test_fonts.dart';
import '../support/moment_test_draft_store.dart';
import '../support/reading_text_style_test_support.dart';
import 'moments/moment_pages_test_support.dart';
import 'posts/post_replies_page_test_support.dart';
import 'threads/thread_detail_page_test_support.dart';

const _portal = '[入口](/threads/cmsewdo0h000x7qv6aa77ll1v)';
const _styled =
    '<span data-wenyou-font-v1="wenkai">[字体链接](https://example.com)</span>\n\n'
    '`普通代码` <span data-wenyou-color-v1="#D14343">`着色代码`</span>\n\n'
    '## 标题甲\n<br />\n## 标题乙';

Widget _thread(String source, {bool post = false}) => ThreadSubthreadBody(
  threadDetailPageTestDetail,
  ThreadSubthreadModel(
    id: 'subthread-1',
    title: '主线',
    sortOrder: 1,
    postCount: 1,
    postingPolicyLabel: '参与者发言',
    body: ThreadBodyModel(markdown: source, postId: post ? 'body-post' : null),
  ),
  onEdit: (_) {},
);

Widget _post(String source) => PostReadingBody(
  post: postRepliesPageTestRootWithContent(source),
  galleryTarget: const ReadingGalleryTarget(
    scope: ReadingGalleryScope.subthread,
    scopeId: 'subthread-1',
  ),
  enableTextFonts: true,
);

void main() {
  setUpAll(loadDeterministicTestFonts);
  final readers = <String, Widget Function(String)>{
    '主题正文': (text) => _thread(text),
    '有楼层标识的子贴正文': (text) => _thread(text, post: true),
    '楼层及独立讨论正文': _post,
    '动态详情正文': (text) => SizedBox(
      height: 1000,
      child: ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(
            MomentPagesTestPageRepository(
              detail: MomentDetail(
                card: momentPagesTestCard(),
                content: text,
                images: const [],
                version: 1,
                canEdit: false,
                canDelete: false,
              ),
            ),
          ),
          momentDraftStoreProvider.overrideWithValue(MemoryMomentDraftStore()),
        ],
        child: const MomentDetailPage(momentId: 'moment-1'),
      ),
    ),
    '动态评论': (text) => MomentCommentBody(
      comment: MomentComment(
        id: 'comment',
        momentId: 'moment',
        author: const MomentAuthor(id: 'author', username: '作者', level: 1),
        deleted: false,
        canDelete: false,
        createdAt: DateTime(2026),
        content: text,
      ),
      busy: false,
    ),
    '私聊收到的消息': (text) => DirectMessageBubble(
      message: DirectMessage(
        id: 'message',
        conversationId: 'conversation',
        senderId: 'sender',
        recipientId: 'recipient',
        createdAt: DateTime(2026),
        content: text,
      ),
      mine: false,
      canRecall: false,
      onRecall: () {},
    ),
    '私聊发出的消息': (text) => DirectMessageBubble(
      message: DirectMessage(
        id: 'message',
        conversationId: 'conversation',
        senderId: 'sender',
        recipientId: 'recipient',
        createdAt: DateTime(2026),
        content: text,
      ),
      mine: true,
      canRecall: false,
      onRecall: () {},
    ),
  };
  for (final entry in readers.entries) {
    for (final dark in [false, true]) {
      testWidgets('${entry.key}在窄屏大字号只缩放一次 dark=$dark', (tester) async {
        final semantics = tester.ensureSemantics();
        double? original;
        for (final scale in [1.0, 1.5, 2.0]) {
          await pump(
            tester,
            [entry.value('前文 $_portal 后文')],
            scale: scale,
            dark: dark,
          );
          final label = tester.renderObject<RenderParagraph>(
            find.byWidgetPredicate(
              (w) => w is RichText && w.text.toPlainText() == '入口',
            ),
          );
          final rect = label
              .getBoxesForSelection(
                const TextSelection(baseOffset: 0, extentOffset: 1),
              )
              .single
              .toRect();
          final height =
              label.localToGlobal(rect.bottomRight).dy -
              label.localToGlobal(rect.topLeft).dy;
          original ??= height;
          expect(height, closeTo(original * scale, 1));
          expect(find.bySemanticsLabel(RegExp('站内传送门：入口')), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        semantics.dispose();
      });
    }
  }
  for (final entry in readers.entries.take(3)) {
    testWidgets('${entry.key}使用阅读字号后仍保留链接、代码和独立空段样式', (tester) async {
      await pump(tester, [entry.value(_styled)], scale: 2);
      final markdown = tester.widget<WenyouMarkdown>(
        find.byType(WenyouMarkdown),
      );
      final context = tester.element(find.byType(WenyouMarkdown));
      expect(leafStyle(tester, '字体链接').fontWeight, FontWeight.w600);
      expect(leafStyle(tester, '字体链接').decoration, TextDecoration.underline);
      expect(
        leafStyle(tester, '着色代码').fontSize,
        leafStyle(tester, '普通代码').fontSize,
      );
      expect(
        leafStyle(tester, '着色代码').height,
        leafStyle(tester, '普通代码').height,
      );
      expect(
        tester
            .getSize(
              find.byKey(const ValueKey('wenyou-markdown-empty-paragraph-0')),
            )
            .height,
        closeTo(
          MediaQuery.textScalerOf(context).scale(markdown.bodyFontSize) *
              markdown.bodyHeight,
          .01,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
