import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_navigation.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';

class _Reading extends ReadingQuickScrollController {
  _Reading()
    : super(scrollController: ScrollController(), onUserNavigation: () {});

  ReadingBookmark? bookmark;

  @override
  ReadingBookmark? captureBookmark() => bookmark;

  @override
  void dispose() {
    final controller = scrollController;
    super.dispose();
    controller.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('返回保留原 ID、条目内位置和原筛选作用域', () async {
    final reading = _Reading()
      ..bookmark = const ReadingBookmark(
        id: 'old',
        number: 42,
        offset: 137,
        scope: 'old-scope',
      );
    final requests = <({int? number, String? id, String scope})>[];
    var scope = 'old-scope';
    final navigation = DiscussionNavigation<String>(
      reading: reading,
      currentScope: () => scope,
      locate: ({number, postId, required scope, required active}) async {
        requests.add((number: number, id: postId, scope: scope));
        return (id: postId ?? 'new', clearedAuthor: false);
      },
    );
    addTearDown(reading.dispose);
    addTearDown(navigation.dispose);

    await navigation.jump(5000, () => true);
    expect(navigation.targetId, 'new');
    expect(navigation.targetOffset, isNull);
    expect(navigation.canReturn, isTrue);
    scope = 'new-scope';
    await navigation.returnToPrevious();
    expect(requests.last, (number: null, id: 'old', scope: 'old-scope'));
    expect(navigation.targetId, 'old');
    expect(navigation.targetOffset, 137);
    expect(navigation.canReturn, isFalse);
  });

  test('切换作用域或关闭后的旧跳转不覆盖新位置', () async {
    final reading = _Reading();
    final pending = Completer<DiscussionLocatedTarget?>();
    bool Function()? requestActive;
    final navigation = DiscussionNavigation<String>(
      reading: reading,
      currentScope: () => 'scope',
      locate: ({number, postId, required scope, required active}) {
        requestActive = active;
        return pending.future;
      },
    );
    addTearDown(reading.dispose);
    addTearDown(navigation.dispose);
    final jump = navigation.jump(5000, () => true);
    navigation.clear();
    expect(requestActive!(), isFalse);
    pending.complete((id: 'late', clearedAuthor: false));
    await jump;
    expect(navigation.targetId, isNull);
    expect(navigation.revision, 0);
  });

  test('旧返回请求在新跳转后失败不会清掉新书签或抛出旧错误', () async {
    final reading = _Reading()
      ..bookmark = const ReadingBookmark(
        id: 'old',
        number: 1,
        offset: 100,
        scope: 'scope',
      );
    final pending = Completer<DiscussionLocatedTarget?>();
    final navigation = DiscussionNavigation<String>(
      reading: reading,
      currentScope: () => 'scope',
      locate: ({number, postId, required scope, required active}) async {
        if (postId != null) return pending.future;
        return (id: '$number', clearedAuthor: false);
      },
    );
    addTearDown(navigation.dispose);
    addTearDown(reading.dispose);
    await navigation.jump(500, () => true);
    final returning = navigation.returnToPrevious();
    reading.bookmark = const ReadingBookmark(
      id: '500',
      number: 500,
      offset: 60,
      scope: 'scope',
    );
    await navigation.jump(800, () => true);
    pending.completeError(StateError('deleted'));
    await returning;
    expect(navigation.targetId, '800');
    expect(navigation.canReturn, isTrue);
  });

  test('返回请求失败不丢弃当前目标和可重试的原位置', () async {
    final reading = _Reading()
      ..bookmark = const ReadingBookmark(
        id: 'old',
        number: 42,
        offset: 137,
        scope: 'scope',
      );
    final navigation = DiscussionNavigation<String>(
      reading: reading,
      currentScope: () => 'scope',
      locate: ({number, postId, required scope, required active}) async {
        if (postId != null) throw StateError('offline');
        return (id: 'new', clearedAuthor: false);
      },
    );
    addTearDown(reading.dispose);
    addTearDown(navigation.dispose);
    await navigation.jump(5000, () => true);
    await expectLater(navigation.returnToPrevious(), throwsStateError);
    expect(navigation.targetId, 'new');
    expect(navigation.canReturn, isTrue);
  });
}
