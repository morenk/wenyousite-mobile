import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';

import '../../support/foundation_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  for (final width in [360.0, 400.0]) {
    testWidgets('长短回复混排后定位第九条短回复，宽度 $width', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      const fixturePath = String.fromEnvironment('REPLIES_REPRO_FILE');
      final fixture = fixturePath.isEmpty
          ? null
          : jsonDecode(File(fixturePath).readAsStringSync())
                as Map<String, Object?>;
      final source = fixture?['replies'] as List<Object?>?;
      final replies = [
        for (var index = 0; index < 18; index++)
          postRepliesPageTestReply(
            'reply-$index',
            source == null
                ? ([4, 6, 7, 17].contains(index)
                      ? List.filled(
                          42,
                          '这是一段较长的讨论正文，用于保持真实场景的段落高度。',
                        ).join('\n\n')
                      : '第 $index 条短回复。')
                : (source[index] as Map<String, Object?>)['content']! as String,
            postRepliesPageTestOtherAuthor,
          ),
      ];
      final rootContent = fixture == null
          ? '原楼层简短正文'
          : (fixture['root']! as Map<String, Object?>)['content']! as String;
      final container = await postRepliesPageTestPostContainer(
        PostRepliesPageTestFakePostRepository(
          initialReplies: replies,
          onFetchPost: (id) async => id == 'root'
              ? postRepliesPageTestRootWithContent(rootContent)
              : replies.singleWhere((reply) => reply.id == id),
        ),
      );
      addTearDown(container.dispose);
      final offsets = <double>[];
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: NotificationListener<ScrollNotification>(
              onNotification: (event) {
                if (event is ScrollUpdateNotification && event.depth == 0) {
                  offsets.add(event.metrics.pixels);
                }
                return false;
              },
              child: const PostRepliesPage(
                threadId: 'thread',
                rootPostId: 'root',
                focusedReplyId: 'reply-8',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final target = find.byKey(const ValueKey('target-frame-reply-8'));
      final viewport = tester.getRect(
        find.byKey(const Key('post-replies-list')),
      );
      expect(target, findsOneWidget, reason: '滚动轨迹：$offsets');
      expect(
        tester.getRect(target).top,
        closeTo(viewport.top, 1),
        reason: '滚动轨迹：$offsets',
      );
      final located = offsets.last;
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(offsets.last, closeTo(located, 1));
      expect(tester.getRect(target).top, closeTo(viewport.top, 1));
    });
  }
}
