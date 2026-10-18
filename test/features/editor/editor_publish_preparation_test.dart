import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_publish_preparation.dart';

void main() {
  test('附件失败使generation变化时仍展示失败，绝不提交', () async {
    var generation = 0;
    var revealed = 0;
    var finished = 0;
    await withPreparedEditorPublish(
      waitForReady: () async {
        generation++;
        return false;
      },
      generation: () => generation,
      isIntentCurrent: (_) => false,
      isActive: () => true,
      flush: () async => throw StateError('失败附件不能编码'),
      onNotReady: () async {
        revealed++;
      },
      submit: () async => fail('失败附件不能提交'),
      finishWaiting: () => finished++,
    );
    expect(revealed, 1);
    expect(finished, 1);
  });

  test('附件等待后捕获的意图失效不编码或提交', () async {
    final upload = Completer<bool>();
    var generation = 0;
    var flushed = 0;
    var submitted = 0;
    var finished = 0;
    final task = withPreparedEditorPublish(
      waitForReady: () {
        generation++;
        return upload.future;
      },
      generation: () => generation,
      isIntentCurrent: (intent) => intent == generation,
      isActive: () => true,
      flush: () async {
        flushed++;
        return true;
      },
      onNotReady: () async {},
      submit: () async {
        submitted++;
      },
      finishWaiting: () => finished++,
    );
    generation++;
    upload.complete(true);
    await task;
    expect(flushed, 0);
    expect(submitted, 0);
    expect(finished, 1);
  });

  test('编码期间取消、切号或关闭不提交，异常也结束等待', () async {
    for (final condition in ['intent', 'scope', 'error']) {
      final encoding = Completer<bool>();
      var active = true;
      var current = true;
      var submitted = 0;
      var finished = 0;
      final task = withPreparedEditorPublish(
        waitForReady: () async => true,
        generation: () => 1,
        isIntentCurrent: (_) => current,
        isActive: () => active,
        flush: () => encoding.future,
        onNotReady: () async {},
        submit: () async {
          submitted++;
        },
        finishWaiting: () => finished++,
      );
      await Future<void>.delayed(Duration.zero);
      if (condition == 'intent') current = false;
      if (condition == 'scope') active = false;
      if (condition == 'error') {
        final expectation = expectLater(task, throwsStateError);
        encoding.completeError(StateError('编码异常'));
        await expectation;
      } else {
        encoding.complete(true);
        await task;
      }
      expect(submitted, 0);
      expect(finished, 1);
    }
  });
}
