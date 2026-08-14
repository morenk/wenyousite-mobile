import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

abstract interface class WalletRepository {
  Future<WalletSummary> fetchWallet();

  Future<DailyCheckInResult> checkIn();

  Future<CursorPage<WalletTransaction>> fetchTransactions({
    String? cursor,
    int limit = 20,
  });

  Future<TipResult> tip(
    TipTarget target, {
    required String amount,
    required String clientRequestId,
  });
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return const _UnboundWalletRepository();
});

class _UnboundWalletRepository implements WalletRepository {
  const _UnboundWalletRepository();

  @override
  Future<DailyCheckInResult> checkIn() {
    return Future.error(_unboundError());
  }

  @override
  Future<CursorPage<WalletTransaction>> fetchTransactions({
    String? cursor,
    int limit = 20,
  }) {
    return Future.error(_unboundError());
  }

  @override
  Future<WalletSummary> fetchWallet() {
    return Future.error(_unboundError());
  }

  @override
  Future<TipResult> tip(
    TipTarget target, {
    required String amount,
    required String clientRequestId,
  }) {
    return Future.error(_unboundError());
  }
}

StateError _unboundError() => StateError('钱包仓储尚未在应用组合根绑定。');
