import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_controllers.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

void main() {
  test('钱包余额与流水独立失败，重试和分页保留已加载结果', () async {
    final repository = _ControllerWalletRepository(failSummaryOnce: true);
    final controller = WalletController(repository, autoStart: false);
    addTearDown(controller.dispose);

    await controller.loadInitial();
    expect(controller.state.summary, isNull);
    expect(controller.state.summaryFailure, isNotNull);
    expect(controller.state.transactions.single.id, 'transaction-1');
    expect(controller.state.hasMore, isTrue);

    await controller.retrySummary();
    expect(controller.state.summary?.balance, '20');

    await controller.loadMore();
    expect(controller.state.transactions.map((item) => item.id), [
      'transaction-1',
      'transaction-2',
    ]);
    expect(controller.state.hasMore, isFalse);
  });

  test('流水失效 cursor 自动回到第一页而不是保留错误位置', () async {
    final repository = _ControllerWalletRepository(invalidCursorOnce: true);
    final controller = WalletController(repository, autoStart: false);
    addTearDown(controller.dispose);

    await controller.loadInitial();
    await controller.loadMore();

    expect(repository.firstPageCalls, 2);
    expect(controller.state.transactions.single.id, 'transaction-1');
    expect(controller.state.loadMoreFailure, isNull);
  });

  test('加油失败按相同金额复用 UUID，改金额和成功后生成新 UUID', () async {
    final repository = _TipWalletRepository();
    final uuid = _MockUuid();
    final requestIds = [
      '11111111-1111-4111-8111-111111111111',
      '22222222-2222-4222-8222-222222222222',
      '33333333-3333-4333-8333-333333333333',
    ];
    when(() => uuid.v4()).thenAnswer((_) => requestIds.removeAt(0));
    final controller = TipController(
      repository,
      const TipTarget.user(id: 'recipient-1'),
      uuid,
    );
    addTearDown(controller.dispose);

    expect(await controller.submit('10'), isNull);
    expect(await controller.submit('10'), isNotNull);
    repository.failNext = true;
    expect(await controller.submit('11'), isNull);
    expect(await controller.submit('12'), isNotNull);

    expect(repository.requests, [
      ('10', '11111111-1111-4111-8111-111111111111'),
      ('10', '11111111-1111-4111-8111-111111111111'),
      ('11', '22222222-2222-4222-8222-222222222222'),
      ('12', '33333333-3333-4333-8333-333333333333'),
    ]);
  });

  test('金额格式化不转浮点且拒绝前导零、小数和 bigint 溢出', () {
    expect(WenyouAmount.format('9007199254740993'), '9,007,199,254,740,993');
    expect(WenyouAmount.normalizeTip(' 2 '), '2');
    for (final invalid in ['02', '2.5', '1', '9223372036854775808']) {
      expect(
        () => WenyouAmount.normalizeTip(invalid),
        throwsA(isA<ApiFailure>()),
      );
    }
  });

  test('幂等键复用冲突会废弃旧 UUID 后再发起同金额请求', () async {
    final repository = _TipWalletRepository()
      ..nextFailure = const ApiFailure(
        userMessage: '幂等冲突',
        businessCode: 40912,
      );
    final uuid = _MockUuid();
    final requestIds = [
      '11111111-1111-4111-8111-111111111111',
      '22222222-2222-4222-8222-222222222222',
    ];
    when(() => uuid.v4()).thenAnswer((_) => requestIds.removeAt(0));
    final controller = TipController(
      repository,
      const TipTarget.user(id: 'recipient-1'),
      uuid,
    );
    addTearDown(controller.dispose);

    expect(await controller.submit('10'), isNull);
    expect(await controller.submit('10'), isNotNull);
    expect(repository.requests, [
      ('10', '11111111-1111-4111-8111-111111111111'),
      ('10', '22222222-2222-4222-8222-222222222222'),
    ]);
  });
}

class _MockUuid extends Mock implements Uuid {}

class _ControllerWalletRepository extends Fake implements WalletRepository {
  _ControllerWalletRepository({
    this.failSummaryOnce = false,
    this.invalidCursorOnce = false,
  });

  final bool failSummaryOnce;
  final bool invalidCursorOnce;
  var summaryCalls = 0;
  var firstPageCalls = 0;
  var cursorCalls = 0;

  @override
  Future<WalletSummary> fetchWallet() async {
    summaryCalls += 1;
    if (failSummaryOnce && summaryCalls == 1) {
      throw const ApiFailure(userMessage: '余额失败');
    }
    return const WalletSummary(
      balance: '20',
      receivedTipTotal: '10',
      receivedTipCount: 2,
    );
  }

  @override
  Future<CursorPage<WalletTransaction>> fetchTransactions({
    String? cursor,
    int limit = 20,
  }) async {
    if (cursor == null) {
      firstPageCalls += 1;
      return CursorPage(
        items: [_transaction('transaction-1')],
        cursor: 'cursor-1',
        hasMore: true,
      );
    }
    cursorCalls += 1;
    if (invalidCursorOnce && cursorCalls == 1) {
      throw const ApiFailure(userMessage: '失效', businessCode: 40007);
    }
    return CursorPage(
      items: [_transaction('transaction-2')],
      cursor: null,
      hasMore: false,
    );
  }
}

class _TipWalletRepository extends Fake implements WalletRepository {
  final requests = <(String, String)>[];
  var failNext = true;
  ApiFailure? nextFailure;

  @override
  Future<TipResult> tip(
    TipTarget target, {
    required String amount,
    required String clientRequestId,
  }) async {
    requests.add((amount, clientRequestId));
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      failNext = false;
      throw failure;
    }
    if (failNext) {
      failNext = false;
      throw const ApiFailure(userMessage: '网络暂时不可用');
    }
    return const TipResult(
      transactionId: 'transaction-tip',
      grossAmount: '10',
      recipientAmount: '8',
      platformAmount: '2',
      balance: '12',
      recipientTipTotal: '18',
      recipientTipCount: 2,
    );
  }
}

WalletTransaction _transaction(String id) {
  return WalletTransaction(
    id: id,
    type: WalletTransactionType.tip,
    direction: WalletTransactionDirection.expense,
    amount: '10',
    grossAmount: '10',
    recipientAmount: '8',
    platformAmount: '2',
    balanceAfter: '10',
    target: const WalletTransactionTarget(type: WalletTargetType.user),
    createdAt: DateTime.utc(2026, 8, 10),
  );
}
