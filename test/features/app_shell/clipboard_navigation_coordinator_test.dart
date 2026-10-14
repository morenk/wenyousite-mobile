import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/app_shell/application/clipboard_navigation_coordinator.dart';
import 'package:wenyousite_mobile/features/app_shell/application/clipboard_navigation_ports.dart';

import 'clipboard_navigation_test_support.dart';

const _link = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';

void main() {
  test('迟到的旧存储读取不能覆盖复制收据，重建后仍读取最新复制', () async {
    final gateway = FakeNavigationClipboard();
    final store = FakeNavigationStore()
      ..pendingRead = Completer<HandledClipboardNavigation?>();
    final coordinator = ClipboardNavigationCoordinator(gateway, store);
    final load = coordinator.ready();
    await coordinator.copyLink(_link);
    store.pendingRead!.complete(null);
    await load;
    expect(coordinator.handled?.changeToken, 'android:copy:1');
    expect(coordinator.handled?.fingerprint, hasLength(64));
    expect(coordinator.handled?.fingerprint, isNot(contains('AbCd')));
    store.pendingRead = null;
    final restarted = ClipboardNavigationCoordinator(gateway, store);
    await restarted.ready();
    expect(restarted.handled?.changeToken, 'android:copy:1');
  });

  test('复制失败不登记，后续成功复制仍可执行', () async {
    final gateway = FakeNavigationClipboard()..failWrite = true;
    final store = FakeNavigationStore();
    final coordinator = ClipboardNavigationCoordinator(gateway, store);
    await expectLater(coordinator.copyLink(_link), throwsStateError);
    expect(coordinator.handled, isNull);
    expect(store.writes, isEmpty);
    gateway.failWrite = false;
    await coordinator.copyLink(_link);
    expect(coordinator.handled?.changeToken, 'android:copy:2');
  });

  test('落盘失败不使复制失败，内存去重保留且后续更新可落盘', () async {
    final gateway = FakeNavigationClipboard();
    final store = FakeNavigationStore()..failWrite = true;
    final coordinator = ClipboardNavigationCoordinator(gateway, store);
    await coordinator.copyLink(_link);
    expect(coordinator.handled?.changeToken, 'android:copy:1');
    store.failWrite = false;
    await coordinator.copyLink(_link);
    expect(store.value?.changeToken, 'android:copy:2');
  });

  test('旧弹窗选择不能覆盖后来复制，持久化始终串行', () async {
    final gateway = FakeNavigationClipboard();
    final store = FakeNavigationStore()..pendingWrite = Completer<void>();
    final coordinator = ClipboardNavigationCoordinator(gateway, store);
    await coordinator.ready();
    final oldRevision = coordinator.revision;
    final old = coordinator.rememberIfCurrent(
      const ClipboardNavigationSnapshot(text: _link, changeToken: 'old'),
      expectedRevision: oldRevision,
    );
    final copy = coordinator.copyLink(_link);
    await Future<void>.delayed(Duration.zero);
    expect(coordinator.handled?.changeToken, 'android:copy:1');
    expect(store.writes, hasLength(1));
    await coordinator.rememberIfCurrent(
      const ClipboardNavigationSnapshot(text: _link, changeToken: 'old'),
      expectedRevision: oldRevision,
    );
    expect(coordinator.handled?.changeToken, 'android:copy:1');
    store.pendingWrite!.complete();
    await Future.wait([old, copy]);
    expect(store.writes.map((v) => v.changeToken), ['old', 'android:copy:1']);
    expect(store.value?.changeToken, 'android:copy:1');
  });
}
