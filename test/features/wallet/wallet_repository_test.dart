import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

const _requestId = '123e4567-e89b-42d3-a456-426614174000';

void main() {
  setUpAll(() => registerFallbackValue(_FakeTipRequestDto()));

  test('钱包、签到与流水完整映射精确整数字符串和分页契约', () async {
    final api = _MockWalletApi();
    when(() => api.economyGetWallet()).thenAnswer(
      (_) async => _response(
        '/api/v1/wallet',
        EconomyGetWallet200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.update(
              (wallet) => wallet
                ..balance = '9007199254740993'
                ..receivedTipTotal = '120'
                ..receivedTipCount = 4,
            ),
        ),
      ),
    );
    when(() => api.economyCheckIn()).thenAnswer(
      (_) async => _response(
        '/api/v1/wallet/check-in',
        EconomyCheckIn200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.update(
              (checkIn) => checkIn
                ..claimedNow = true
                ..date = '2026-08-10'
                ..rewardAmount = DailyCheckInResponseDtoRewardAmountEnum.n3
                ..experienceAwarded = 2
                ..balance = '9007199254740996'
                ..progression.update(
                  (progression) => progression
                    ..level = 4
                    ..experience = 32
                    ..currentLevelExperience = 12
                    ..nextLevelExperience = 50,
                ),
            ),
        ),
      ),
    );
    when(
      () => api.economyTransactions(cursor: 'cursor-1', limit: 7),
    ).thenAnswer(
      (_) async => _response(
        '/api/v1/wallet/transactions',
        EconomyTransactions200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..meta.update(
              (meta) => meta
                ..cursor = 'cursor-2'
                ..hasMore = true,
            )
            ..data.addAll([_dailyTransaction(), _tipTransaction()]),
        ),
      ),
    );
    final repository = ApiWalletRepository(api);

    final wallet = await repository.fetchWallet();
    final checkIn = await repository.checkIn();
    final transactions = await repository.fetchTransactions(
      cursor: 'cursor-1',
      limit: 7,
    );

    expect(wallet.balance, '9007199254740993');
    expect(wallet.receivedTipCount, 4);
    expect(checkIn.rewardAmount, '3');
    expect(checkIn.progression.nextLevelExperience, 50);
    expect(transactions.cursor, 'cursor-2');
    expect(transactions.hasMore, isTrue);
    expect(transactions.items.first.type, WalletTransactionType.dailyCheckIn);
    expect(
      transactions.items.last.direction,
      WalletTransactionDirection.expense,
    );
    expect(transactions.items.last.target.type, WalletTargetType.thread);
    expect(transactions.items.last.counterparty?.username, '作者');
  });

  test('三类加油调用正确 operationId 并透传稳定幂等载荷', () async {
    final api = _MockWalletApi();
    final payloads = <TipRequestDto>[];
    when(
      () => api.economyTipThread(
        id: 'thread-1',
        tipRequestDto: any(named: 'tipRequestDto'),
      ),
    ).thenAnswer((invocation) async {
      payloads.add(invocation.namedArguments[#tipRequestDto]! as TipRequestDto);
      return _tipResponse<EconomyTipThread201Response>(
        '/api/v1/threads/thread-1/tips',
        EconomyTipThread201Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace(_tipDto(threadTotal: '18')),
        ),
      );
    });
    when(
      () => api.economyTipUser(
        id: 'user-1',
        tipRequestDto: any(named: 'tipRequestDto'),
      ),
    ).thenAnswer((invocation) async {
      payloads.add(invocation.namedArguments[#tipRequestDto]! as TipRequestDto);
      return _tipResponse<EconomyTipUser201Response>(
        '/api/v1/users/user-1/tips',
        EconomyTipUser201Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace(_tipDto()),
        ),
      );
    });
    when(
      () => api.economyTipMoment(
        id: 'moment-1',
        tipRequestDto: any(named: 'tipRequestDto'),
      ),
    ).thenAnswer((invocation) async {
      payloads.add(invocation.namedArguments[#tipRequestDto]! as TipRequestDto);
      return _tipResponse<EconomyTipMoment201Response>(
        '/api/v1/moments/moment-1/tips',
        EconomyTipMoment201Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace(_tipDto(momentTotal: '14')),
        ),
      );
    });
    final repository = ApiWalletRepository(api);

    final thread = await repository.tip(
      const TipTarget.thread(id: 'thread-1', recipientUserId: 'owner-1'),
      amount: '10',
      clientRequestId: _requestId,
    );
    final user = await repository.tip(
      const TipTarget.user(id: 'user-1'),
      amount: '10',
      clientRequestId: _requestId,
    );
    final moment = await repository.tip(
      const TipTarget.moment(id: 'moment-1', recipientUserId: 'author-1'),
      amount: '10',
      clientRequestId: _requestId,
    );

    expect(thread.threadTipTotal, '18');
    expect(user.recipientTipTotal, '90');
    expect(moment.momentTipTotal, '14');
    expect(payloads.map((item) => item.amount), everyElement('10'));
    expect(
      payloads.map((item) => item.clientRequestId),
      everyElement(_requestId),
    );
  });

  test('金额小数、超出 bigint 上限和缺失加油响应均 fail-closed', () async {
    final api = _MockWalletApi();
    final repository = ApiWalletRepository(api);

    await expectLater(
      repository.tip(
        const TipTarget.user(id: 'user-1'),
        amount: '2.5',
        clientRequestId: _requestId,
      ),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(
      repository.tip(
        const TipTarget.user(id: 'user-1'),
        amount: '9223372036854775808',
        clientRequestId: _requestId,
      ),
      throwsA(isA<ApiFailure>()),
    );

    when(
      () => api.economyTipUser(
        id: 'user-1',
        tipRequestDto: any(named: 'tipRequestDto'),
      ),
    ).thenAnswer(
      (_) async => Response<EconomyTipUser201Response>(
        requestOptions: RequestOptions(path: '/api/v1/users/user-1/tips'),
      ),
    );
    await expectLater(
      repository.tip(
        const TipTarget.user(id: 'user-1'),
        amount: '2',
        clientRequestId: _requestId,
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('原请求重试'),
        ),
      ),
    );
  });
}

class _MockWalletApi extends Mock implements WalletApi {}

class _FakeTipRequestDto extends Fake implements TipRequestDto {}

Response<T> _response<T>(String path, T data) {
  return Response<T>(
    requestOptions: RequestOptions(path: path),
    data: data,
  );
}

Response<T> _tipResponse<T>(String path, T data) => _response(path, data);

WalletTransactionResponseDto _dailyTransaction() {
  return WalletTransactionResponseDto(
    (builder) => builder
      ..id = 'transaction-daily'
      ..type = WalletTransactionResponseDtoTypeEnum.DAILY_CHECK_IN
      ..direction = WalletTransactionResponseDtoDirectionEnum.INCOME
      ..amount = '3'
      ..grossAmount = '3'
      ..recipientAmount = '3'
      ..platformAmount = '0'
      ..balanceAfter = '13'
      ..target.update(
        (target) => target
          ..type = WalletTransactionTargetResponseDtoTypeEnum.NONE
          ..id = null
          ..title = null,
      )
      ..createdAt = DateTime.utc(2026, 8, 10, 1, 2),
  );
}

WalletTransactionResponseDto _tipTransaction() {
  return WalletTransactionResponseDto(
    (builder) => builder
      ..id = 'transaction-tip'
      ..type = WalletTransactionResponseDtoTypeEnum.TIP
      ..direction = WalletTransactionResponseDtoDirectionEnum.EXPENSE
      ..amount = '10'
      ..grossAmount = '10'
      ..recipientAmount = '8'
      ..platformAmount = '2'
      ..balanceAfter = '3'
      ..counterparty.update(
        (author) => author
          ..id = 'owner-1'
          ..username = '作者'
          ..avatar = 'file:///private/avatar.jpg'
          ..level = 2,
      )
      ..target.update(
        (target) => target
          ..type = WalletTransactionTargetResponseDtoTypeEnum.THREAD
          ..id = 'thread-1'
          ..title = '测试主题帖',
      )
      ..createdAt = DateTime.utc(2026, 8, 10, 2, 3),
  );
}

TipResponseDto _tipDto({String? threadTotal, String? momentTotal}) {
  return TipResponseDto(
    (builder) => builder
      ..transactionId = 'transaction-tip'
      ..grossAmount = '10'
      ..recipientAmount = '8'
      ..platformAmount = '2'
      ..balance = '20'
      ..threadTipTotal = threadTotal
      ..momentTipTotal = momentTotal
      ..recipientTipTotal = '90'
      ..recipientTipCount = 6,
  );
}
