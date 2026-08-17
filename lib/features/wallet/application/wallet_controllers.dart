import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/models/paging.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_repository_ports.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

const _unset = Object();

class WalletState {
  const WalletState({
    this.summary,
    this.transactions = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingSummary = true,
    this.isLoadingTransactions = true,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.summaryFailure,
    this.transactionsFailure,
    this.loadMoreFailure,
  });

  final WalletSummary? summary;
  final List<WalletTransaction> transactions;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingSummary;
  final bool isLoadingTransactions;
  final bool isRefreshing;
  final bool isLoadingMore;
  final ApiFailure? summaryFailure;
  final ApiFailure? transactionsFailure;
  final ApiFailure? loadMoreFailure;

  WalletState copyWith({
    Object? summary = _unset,
    List<WalletTransaction>? transactions,
    Object? cursor = _unset,
    bool? hasMore,
    bool? isLoadingSummary,
    bool? isLoadingTransactions,
    bool? isRefreshing,
    bool? isLoadingMore,
    Object? summaryFailure = _unset,
    Object? transactionsFailure = _unset,
    Object? loadMoreFailure = _unset,
  }) {
    return WalletState(
      summary: identical(summary, _unset)
          ? this.summary
          : summary as WalletSummary?,
      transactions: transactions ?? this.transactions,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isLoadingSummary: isLoadingSummary ?? this.isLoadingSummary,
      isLoadingTransactions:
          isLoadingTransactions ?? this.isLoadingTransactions,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      summaryFailure: identical(summaryFailure, _unset)
          ? this.summaryFailure
          : summaryFailure as ApiFailure?,
      transactionsFailure: identical(transactionsFailure, _unset)
          ? this.transactionsFailure
          : transactionsFailure as ApiFailure?,
      loadMoreFailure: identical(loadMoreFailure, _unset)
          ? this.loadMoreFailure
          : loadMoreFailure as ApiFailure?,
    );
  }
}

class WalletController extends StateNotifier<WalletState> {
  WalletController(this._repository, {bool autoStart = true})
    : super(const WalletState()) {
    if (autoStart) unawaited(loadInitial());
  }

  final WalletRepository _repository;
  var _epoch = 0;

  Future<void> loadInitial() async {
    final epoch = ++_epoch;
    state = const WalletState();
    await Future.wait([_loadSummary(epoch), _loadFirstTransactions(epoch)]);
  }

  Future<void> refresh() async {
    final epoch = ++_epoch;
    state = state.copyWith(
      isRefreshing: true,
      isLoadingMore: false,
      summaryFailure: null,
      transactionsFailure: null,
      loadMoreFailure: null,
    );
    await Future.wait([_loadSummary(epoch), _loadFirstTransactions(epoch)]);
    if (_isCurrent(epoch)) state = state.copyWith(isRefreshing: false);
  }

  Future<void> retrySummary() => _loadSummary(_epoch);

  Future<void> retryTransactions() => _loadFirstTransactions(_epoch);

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.cursor == null) return;
    final epoch = _epoch;
    state = state.copyWith(isLoadingMore: true, loadMoreFailure: null);
    try {
      final page = await _repository.fetchTransactions(cursor: state.cursor);
      if (!_isCurrent(epoch)) return;
      state = state.copyWith(
        transactions: mergeUniqueBy(
          state.transactions,
          page.items,
          keyOf: (item) => item.id,
        ),
        cursor: page.cursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } on ApiFailure catch (failure) {
      if (!_isCurrent(epoch)) return;
      if (failure.isInvalidCursor) {
        await _loadFirstTransactions(epoch);
        return;
      }
      state = state.copyWith(isLoadingMore: false, loadMoreFailure: failure);
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      state = state.copyWith(
        isLoadingMore: false,
        loadMoreFailure: ApiFailure(
          userMessage: '加载更多温油流水失败，请重试。',
          cause: error,
        ),
      );
    }
  }

  Future<void> _loadSummary(int epoch) async {
    state = state.copyWith(isLoadingSummary: true, summaryFailure: null);
    try {
      final summary = await _repository.fetchWallet();
      if (!_isCurrent(epoch)) return;
      state = state.copyWith(
        summary: summary,
        isLoadingSummary: false,
        summaryFailure: null,
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      state = state.copyWith(
        isLoadingSummary: false,
        summaryFailure: _asFailure(error, '钱包余额加载失败，请重试。'),
      );
    }
  }

  Future<void> _loadFirstTransactions(int epoch) async {
    state = state.copyWith(
      isLoadingTransactions: true,
      isLoadingMore: false,
      transactionsFailure: null,
      loadMoreFailure: null,
    );
    try {
      final page = await _repository.fetchTransactions();
      if (!_isCurrent(epoch)) return;
      state = state.copyWith(
        transactions: page.items,
        cursor: page.cursor,
        hasMore: page.hasMore,
        isLoadingTransactions: false,
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      state = state.copyWith(
        isLoadingTransactions: false,
        transactionsFailure: _asFailure(error, '温油流水加载失败，请重试。'),
      );
    }
  }

  bool _isCurrent(int epoch) => mounted && epoch == _epoch;

  ApiFailure _asFailure(Object error, String message) {
    return mapApplicationFailure(error, message);
  }
}

final walletControllerProvider = StateNotifierProvider.autoDispose
    .family<WalletController, WalletState, String>((ref, userId) {
      return WalletController(ref.watch(walletRepositoryProvider));
    }, dependencies: [walletRepositoryProvider]);

enum DailyCheckInPhase { idle, submitting, completed, failed }

class DailyCheckInState {
  const DailyCheckInState({
    this.phase = DailyCheckInPhase.idle,
    this.result,
    this.failure,
  });

  final DailyCheckInPhase phase;
  final DailyCheckInResult? result;
  final ApiFailure? failure;
}

class DailyCheckInController extends StateNotifier<DailyCheckInState> {
  DailyCheckInController(this._repository) : super(const DailyCheckInState());

  final WalletRepository _repository;

  Future<DailyCheckInResult?> checkIn() async {
    if (state.phase == DailyCheckInPhase.submitting) return null;
    state = const DailyCheckInState(phase: DailyCheckInPhase.submitting);
    try {
      final result = await _repository.checkIn();
      if (!mounted) return null;
      state = DailyCheckInState(
        phase: DailyCheckInPhase.completed,
        result: result,
      );
      return result;
    } on Object catch (error) {
      if (!mounted) return null;
      state = DailyCheckInState(
        phase: DailyCheckInPhase.failed,
        failure: error is ApiFailure
            ? error
            : ApiFailure(userMessage: '每日签到失败。', cause: error),
      );
      return null;
    }
  }
}

final dailyCheckInControllerProvider =
    StateNotifierProvider<DailyCheckInController, DailyCheckInState>((ref) {
      return DailyCheckInController(ref.watch(walletRepositoryProvider));
    }, dependencies: [walletRepositoryProvider]);

class TipState {
  const TipState({
    this.isSubmitting = false,
    this.pendingAmount,
    this.pendingRequestId,
    this.failure,
  });

  final bool isSubmitting;
  final String? pendingAmount;
  final String? pendingRequestId;
  final ApiFailure? failure;
}

class TipController extends StateNotifier<TipState> {
  TipController(this._repository, this.target, [this._uuid = const Uuid()])
    : super(const TipState());

  final WalletRepository _repository;
  final TipTarget target;
  final Uuid _uuid;

  Future<TipResult?> submit(String input) async {
    if (state.isSubmitting) return null;
    String amount;
    try {
      amount = WenyouAmount.normalizeTip(input);
    } on WenyouAmountValidationException catch (failure) {
      state = TipState(failure: ApiFailure(userMessage: failure.userMessage));
      return null;
    }
    final requestId = state.pendingAmount == amount
        ? state.pendingRequestId ?? _uuid.v4()
        : _uuid.v4();
    state = TipState(
      isSubmitting: true,
      pendingAmount: amount,
      pendingRequestId: requestId,
    );
    try {
      final result = await _repository.tip(
        target,
        amount: amount,
        clientRequestId: requestId,
      );
      if (!mounted) return null;
      state = const TipState();
      return result;
    } on Object catch (error) {
      if (!mounted) return null;
      final failure = error is ApiFailure
          ? error
          : ApiFailure(userMessage: '加油失败，请重试。', cause: error);
      final discardConflictingRequest = failure.businessCode == 40912;
      state = TipState(
        pendingAmount: discardConflictingRequest ? null : amount,
        pendingRequestId: discardConflictingRequest ? null : requestId,
        failure: failure,
      );
      return null;
    }
  }
}

final tipControllerProvider = StateNotifierProvider.autoDispose
    .family<TipController, TipState, TipTarget>((ref, target) {
      return TipController(ref.watch(walletRepositoryProvider), target);
    }, dependencies: [walletRepositoryProvider]);
