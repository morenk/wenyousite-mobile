import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_repository_ports.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_failure_messages.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

export 'package:wenyousite_mobile/features/wallet/application/wallet_repository_ports.dart'
    show WalletRepository, walletRepositoryProvider;

class ApiWalletRepository implements WalletRepository {
  ApiWalletRepository(this._api);

  final WalletApi _api;

  @override
  Future<WalletSummary> fetchWallet() async {
    try {
      final dto = (await _api.economyGetWallet()).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '温油钱包加载失败，请稍后重试。');
      }
      return WalletSummary(
        balance: _amount(dto.balance, '钱包余额'),
        receivedTipTotal: _amount(dto.receivedTipTotal, '累计收到加油'),
        receivedTipCount: _nonNegativeInteger(dto.receivedTipCount, '收到加油次数'),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: walletFailureMessages);
    }
  }

  @override
  Future<DailyCheckInResult> checkIn() async {
    try {
      final dto = (await _api.economyCheckIn()).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '签到失败，请稍后重试。');
      }
      final reward = switch (dto.rewardAmount) {
        DailyCheckInResponseDtoRewardAmountEnum.n1 => '1',
        DailyCheckInResponseDtoRewardAmountEnum.n2 => '2',
        DailyCheckInResponseDtoRewardAmountEnum.n3 => '3',
        _ => throw const ApiFailure(userMessage: '签到奖励数值无效，请重新加载。'),
      };
      final date = dto.date.trim();
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
        throw const ApiFailure(userMessage: '签到日期无效，请重新加载。');
      }
      return DailyCheckInResult(
        claimedNow: dto.claimedNow,
        date: date,
        rewardAmount: reward,
        experienceAwarded: _nonNegativeInteger(dto.experienceAwarded, '签到经验'),
        balance: _amount(dto.balance, '签到后余额'),
        progression: WalletProgression(
          level: _nonNegativeInteger(dto.progression.level, '等级'),
          experience: _nonNegativeInteger(dto.progression.experience, '经验'),
          currentLevelExperience: _nonNegativeInteger(
            dto.progression.currentLevelExperience,
            '当前等级经验',
          ),
          nextLevelExperience: dto.progression.nextLevelExperience == null
              ? null
              : _nonNegativeInteger(
                  dto.progression.nextLevelExperience!,
                  '下一级经验',
                ),
        ),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: walletFailureMessages);
    }
  }

  @override
  Future<CursorPage<WalletTransaction>> fetchTransactions({
    String? cursor,
    int limit = 20,
  }) async {
    if (limit < 1 || limit > 50) {
      throw const ApiFailure(userMessage: '温油流水暂时无法加载。');
    }
    try {
      final envelope = (await _api.economyTransactions(
        cursor: _optionalText(cursor),
        limit: limit,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '温油流水加载失败，请稍后重试。');
      }
      final items = envelope.data.map(_transaction).toList(growable: false);
      final ids = <String>{};
      if (items.any((item) => !ids.add(item.id))) {
        throw const ApiFailure(userMessage: '温油流水暂时无法显示，请重新加载。');
      }
      final nextCursor = envelope.meta.cursor?.trim();
      if (envelope.meta.hasMore && (nextCursor == null || nextCursor.isEmpty)) {
        throw const ApiFailure(userMessage: '更多温油流水加载失败，请重新加载。');
      }
      return CursorPage(
        items: List.unmodifiable(items),
        cursor: envelope.meta.hasMore ? nextCursor : null,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: walletFailureMessages);
    }
  }

  @override
  Future<TipResult> tip(
    TipTarget target, {
    required String amount,
    required String clientRequestId,
  }) async {
    final targetId = _requiredText(target.id, '加油目标 ID');
    final normalizedAmount = _normalizeTip(amount);
    final requestId = _requiredText(clientRequestId, '加油信息');
    final request = TipRequestDto(
      (builder) => builder
        ..amount = normalizedAmount
        ..clientRequestId = requestId,
    );
    try {
      final TipResponseDto? dto = switch (target.type) {
        TipTargetType.thread => (await _api.economyTipThread(
          id: targetId,
          extra: ApiRequestPolicy.idempotentCreate.extra,
          tipRequestDto: request,
        )).data?.data,
        TipTargetType.user => (await _api.economyTipUser(
          id: targetId,
          extra: ApiRequestPolicy.idempotentCreate.extra,
          tipRequestDto: request,
        )).data?.data,
        TipTargetType.moment => (await _api.economyTipMoment(
          id: targetId,
          extra: ApiRequestPolicy.idempotentCreate.extra,
          tipRequestDto: request,
        )).data?.data,
      };
      if (dto == null) {
        throw const ApiFailure(userMessage: '加油失败，请重试。');
      }
      return TipResult(
        transactionId: _requiredText(dto.transactionId, '加油流水 ID'),
        grossAmount: _amount(dto.grossAmount, '投入金额'),
        recipientAmount: _amount(dto.recipientAmount, '到账金额'),
        platformAmount: _amount(dto.platformAmount, '平台金额'),
        balance: _amount(dto.balance, '付款后余额'),
        threadTipTotal: dto.threadTipTotal == null
            ? null
            : _amount(dto.threadTipTotal!, '主题累计加油'),
        momentTipTotal: dto.momentTipTotal == null
            ? null
            : _amount(dto.momentTipTotal!, '动态累计加油'),
        recipientTipTotal: _amount(dto.recipientTipTotal, '用户累计收到加油'),
        recipientTipCount: _nonNegativeInteger(
          dto.recipientTipCount,
          '用户收到加油次数',
        ),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: walletFailureMessages);
    }
  }

  WalletTransaction _transaction(WalletTransactionResponseDto dto) {
    final type = switch (dto.type) {
      WalletTransactionResponseDtoTypeEnum.DAILY_CHECK_IN =>
        WalletTransactionType.dailyCheckIn,
      WalletTransactionResponseDtoTypeEnum.TIP => WalletTransactionType.tip,
      _ => throw const ApiFailure(userMessage: '这类温油流水暂时无法显示。'),
    };
    final direction = switch (dto.direction) {
      WalletTransactionResponseDtoDirectionEnum.INCOME =>
        WalletTransactionDirection.income,
      WalletTransactionResponseDtoDirectionEnum.EXPENSE =>
        WalletTransactionDirection.expense,
      _ => throw const ApiFailure(userMessage: '温油流水方向无效，请重新加载。'),
    };
    return WalletTransaction(
      id: _requiredText(dto.id, '流水 ID'),
      type: type,
      direction: direction,
      amount: _amount(dto.amount, '本次收支'),
      grossAmount: _amount(dto.grossAmount, '流水投入金额'),
      recipientAmount: _amount(dto.recipientAmount, '流水到账金额'),
      platformAmount: _amount(dto.platformAmount, '流水平台金额'),
      balanceAfter: _amount(dto.balanceAfter, '流水后余额'),
      counterparty: dto.counterparty == null
          ? null
          : WalletCounterparty(
              id: _requiredText(dto.counterparty!.id, '对方用户 ID'),
              username: _requiredText(dto.counterparty!.username, '对方用户名'),
              avatarUrl: _safeHttpUrl(dto.counterparty!.avatar),
              level: _nonNegativeInteger(dto.counterparty!.level, '对方等级'),
            ),
      target: _target(dto.target),
      createdAt: dto.createdAt,
    );
  }

  WalletTransactionTarget _target(WalletTransactionTargetResponseDto dto) {
    final type = switch (dto.type) {
      WalletTransactionTargetResponseDtoTypeEnum.THREAD =>
        WalletTargetType.thread,
      WalletTransactionTargetResponseDtoTypeEnum.USER => WalletTargetType.user,
      WalletTransactionTargetResponseDtoTypeEnum.MOMENT =>
        WalletTargetType.moment,
      WalletTransactionTargetResponseDtoTypeEnum.NONE => WalletTargetType.none,
      _ => throw const ApiFailure(userMessage: '这类温油目标暂时无法打开。'),
    };
    final id = _optionalText(dto.id);
    if (type != WalletTargetType.none && id == null) {
      throw const ApiFailure(userMessage: '温油流水加载失败，请重试。');
    }
    return WalletTransactionTarget(
      type: type,
      id: id,
      title: _optionalText(dto.title),
    );
  }

  String _amount(String value, String field) {
    try {
      return WenyouAmount.requireNonNegative(value, field);
    } on WenyouAmountValidationException catch (failure) {
      throw ApiFailure(userMessage: failure.userMessage, cause: failure);
    }
  }

  String _normalizeTip(String value) {
    try {
      return WenyouAmount.normalizeTip(value);
    } on WenyouAmountValidationException catch (failure) {
      throw ApiFailure(userMessage: failure.userMessage, cause: failure);
    }
  }

  int _nonNegativeInteger(num value, String field) {
    if (!value.isFinite || value < 0 || value != value.truncateToDouble()) {
      throw ApiFailure(userMessage: '$field无效，请重新加载。');
    }
    return value.toInt();
  }

  String _requiredText(String value, String field) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ApiFailure(userMessage: '$field缺失，请重新加载。');
    }
    return normalized;
  }

  String? _optionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String? _safeHttpUrl(String? value) {
    final normalized = _optionalText(value);
    if (normalized == null) return null;
    final uri = Uri.tryParse(normalized);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return normalized;
  }
}

final apiWalletRepositoryProvider = Provider<WalletRepository>((ref) {
  return ApiWalletRepository(ref.watch(wenyouApiProvider).getWalletApi());
});
