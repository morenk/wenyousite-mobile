import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_comment_navigation.dart';

void main() {
  final journeys = _journeys();

  test('momentCommentNavigation 三条成功黄金旅程直接注入并定位目标', () {
    for (final journey in journeys.where(
      (item) => item.containsKey('contextResponse'),
    )) {
      final journeyId = journey['id']! as String;
      final response = journey['contextResponse']! as Map<String, Object?>;
      final expected = journey['expected']! as Map<String, Object?>;
      final rootId = response['rootId']! as String;
      final targetId = response['targetId']! as String;
      final parentId = response['targetParentCommentId'] as String?;
      final target = _comment(id: targetId, parentId: parentId);
      final context = MomentCommentContext(
        root: _root(
          id: rootId,
          deleted: response['rootDeleted']! as bool,
          replyCount: response['replyCount']! as int,
          replies: parentId == null ? const [] : [target],
        ),
        target: target,
      );

      final projection = projectMomentCommentNavigation(
        comments: const [],
        replyPages: const {},
        order: MomentCommentOrder.newest,
        context: context,
      );

      expect(projection.comments.single.id, rootId, reason: journeyId);
      expect(projection.targetId, expected['focusId'], reason: journeyId);
      expect(
        projection.comments.single.deleted,
        expected['preserveRootTombstone'] == true,
        reason: journeyId,
      );
      expect(
        projection.comments.single.replies.any((item) => item.id == targetId),
        expected['injectTargetReply'] == true,
        reason: journeyId,
      );
      expect(expected['scanPagination'], isFalse, reason: journeyId);
    }
  });

  testWidgets('momentCommentNavigation 两条失败黄金旅程区分重试入口', (tester) async {
    for (final journey in journeys.where(
      (item) => item.containsKey('httpStatus'),
    )) {
      final journeyId = journey['id']! as String;
      var retries = 0;
      final status = journey['httpStatus']! as int;
      final expected = journey['expected']! as Map<String, Object?>;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MomentCommentTargetStatus(
              value: AsyncValue.error(
                ApiFailure(userMessage: '定位失败', httpStatus: status),
                StackTrace.empty,
              ),
              onRetry: () => retries += 1,
            ),
          ),
        ),
      );
      await tester.pump();

      final retry = find.byKey(const Key('moment-comment-target-retry'));
      if (expected['retryContext'] == true) {
        expect(retry, findsOneWidget, reason: journeyId);
        await tester.tap(retry);
        expect(retries, 1, reason: journeyId);
      } else {
        expect(find.text('目标评论已不可见'), findsOneWidget);
        expect(retry, findsNothing, reason: journeyId);
      }
    }
  });

  test('目标段覆盖重复回复，同时保留普通评论分页投影', () {
    final stale = _comment(id: 'reply-1', parentId: 'root-1', content: '旧内容');
    final target = _comment(id: 'reply-1', parentId: 'root-1', content: '目标内容');
    final projection = projectMomentCommentNavigation(
      comments: [
        _root(id: 'root-1', replyCount: 4, replies: [stale]),
      ],
      replyPages: const {},
      order: MomentCommentOrder.newest,
      context: MomentCommentContext(
        root: _root(id: 'root-1', replyCount: 4, replies: [target]),
        target: target,
      ),
    );

    expect(projection.comments.single.replies, hasLength(1));
    expect(projection.comments.single.replies.single.content, '目标内容');
    expect(projection.comments.single.replyCount, 4);
  });
}

List<Map<String, Object?>> _journeys() {
  final json =
      jsonDecode(
            File('contracts/mobile-v1-golden-fixtures.json').readAsStringSync(),
          )
          as Map<String, Object?>;
  return (json['momentCommentNavigation']! as List<Object?>)
      .cast<Map<String, Object?>>();
}

const _author = MomentAuthor(id: 'user-1', username: '测试用户', level: 1);

MomentComment _comment({
  required String id,
  String? parentId,
  String content = '目标评论',
}) {
  return MomentComment(
    id: id,
    momentId: 'moment-1',
    author: _author,
    content: content,
    parentCommentId: parentId,
    deleted: false,
    canDelete: false,
    createdAt: DateTime.utc(2026, 8, 25, 12),
  );
}

MomentRootComment _root({
  required String id,
  required int replyCount,
  bool deleted = false,
  List<MomentComment> replies = const [],
}) {
  return MomentRootComment(
    id: id,
    momentId: 'moment-1',
    author: _author,
    content: deleted ? null : '主评论',
    deleted: deleted,
    canDelete: false,
    createdAt: DateTime.utc(2026, 8, 25, 11),
    replyCount: replyCount,
    replies: replies,
  );
}
