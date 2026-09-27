import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_controllers.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_repository_ports.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

void main() {
  test('并发自动和手动检查复用请求，已消费日期不接受重复领取提示', () async {
    final response = Completer<DailyCheckInResult>();
    final repository = _Repository(() => response.future);
    final controller = DailyCheckInController(repository);
    addTearDown(controller.dispose);
    final first = controller.checkIn('2026-09-20');
    final second = controller.checkIn('2026-09-20');
    expect(identical(first, second), isTrue);
    expect(repository.calls, 1);
    response.complete(_result('2026-09-20'));
    await Future.wait([first, second]);
    expect(controller.state.pendingReceipt?.date, '2026-09-20');
    controller.acknowledgeReceipt('2026-09-20');
    controller.acknowledgeReceipt('2026-09-20');
    await controller.checkIn('2026-09-20');
    expect(controller.state.pendingReceipt, isNull);
    expect(controller.state.result?.rewardAmount, '3');
  });

  test('旧日期的迟到确认不会消费次日回执，次日仍能提示一次', () async {
    var date = '2026-09-20';
    final repository = _Repository(() async => _result(date));
    final controller = DailyCheckInController(repository);
    addTearDown(controller.dispose);
    await controller.checkIn(date);
    controller.acknowledgeReceipt(date);
    date = '2026-09-21';
    await controller.checkIn(date);
    controller.acknowledgeReceipt('2026-09-20');
    expect(controller.state.pendingReceipt?.date, date);
    controller.acknowledgeReceipt(date);
    await controller.checkIn(date);
    expect(controller.state.pendingReceipt, isNull);
  });

  test('退出后迟到的可见回调安全忽略，同日新账号独立确认', () async {
    final repository = _Repository(() async => _result('2026-09-20'));
    final old = DailyCheckInController(repository);
    await old.checkIn('2026-09-20');
    old.dispose();
    final current = DailyCheckInController(repository);
    addTearDown(current.dispose);
    await current.checkIn('2026-09-20');
    expect(() => old.acknowledgeReceipt('2026-09-20'), returnsNormally);
    expect(current.state.pendingReceipt, isNotNull);
    current.acknowledgeReceipt('2026-09-20');
    expect(current.state.pendingReceipt, isNull);
  });

  test('进程重建后已领取结果不补播历史奖励', () async {
    final repository = _Repository(
      () async => _result('2026-09-20', claimedNow: false),
    );
    final controller = DailyCheckInController(repository);
    addTearDown(controller.dispose);
    await controller.checkIn('2026-09-20');
    expect(controller.state.phase, DailyCheckInPhase.completed);
    expect(controller.state.result?.date, '2026-09-20');
    expect(controller.state.pendingReceipt, isNull);
  });
}

class _Repository extends Fake implements WalletRepository {
  _Repository(this.handler);
  final Future<DailyCheckInResult> Function() handler;
  var calls = 0;

  @override
  Future<DailyCheckInResult> checkIn() {
    calls++;
    return handler();
  }
}

DailyCheckInResult _result(String date, {bool claimedNow = true}) =>
    DailyCheckInResult(
      date: date,
      claimedNow: claimedNow,
      rewardAmount: '3',
      experienceAwarded: 0,
      balance: '13',
      progression: const WalletProgression(
        level: 1,
        experience: 0,
        currentLevelExperience: 0,
        nextLevelExperience: 10,
      ),
    );
