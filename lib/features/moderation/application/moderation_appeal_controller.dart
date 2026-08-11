import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/moderation/data/moderation_appeal_repository.dart';
import 'package:wenyousite_mobile/features/moderation/domain/moderation_appeal_models.dart';

enum ModerationAppealPhase { credential, loading, ready, failed }

class ModerationAppealState {
  const ModerationAppealState({
    required this.phase,
    this.decisions = const [],
    this.failure,
    this.credentialExpiresAt,
    this.isIssuingCredential = false,
    this.submittingDecisionId,
  });

  const ModerationAppealState.credential({ApiFailure? failure})
    : this(phase: ModerationAppealPhase.credential, failure: failure);

  final ModerationAppealPhase phase;
  final List<ModerationDecision> decisions;
  final ApiFailure? failure;
  final DateTime? credentialExpiresAt;
  final bool isIssuingCredential;
  final String? submittingDecisionId;

  bool get isSubmitting => submittingDecisionId != null;

  ModerationAppealState copyWith({
    ModerationAppealPhase? phase,
    List<ModerationDecision>? decisions,
    ApiFailure? failure,
    bool clearFailure = false,
    DateTime? credentialExpiresAt,
    bool clearCredentialExpiry = false,
    bool? isIssuingCredential,
    String? submittingDecisionId,
    bool clearSubmitting = false,
  }) {
    return ModerationAppealState(
      phase: phase ?? this.phase,
      decisions: decisions ?? this.decisions,
      failure: clearFailure ? null : failure ?? this.failure,
      credentialExpiresAt: clearCredentialExpiry
          ? null
          : credentialExpiresAt ?? this.credentialExpiresAt,
      isIssuingCredential: isIssuingCredential ?? this.isIssuingCredential,
      submittingDecisionId: clearSubmitting
          ? null
          : submittingDecisionId ?? this.submittingDecisionId,
    );
  }
}

class ModerationAppealController extends StateNotifier<ModerationAppealState> {
  ModerationAppealController(this._repository, {required bool authenticated})
    : _authenticated = authenticated,
      super(
        authenticated
            ? const ModerationAppealState(phase: ModerationAppealPhase.loading)
            : const ModerationAppealState.credential(),
      ) {
    if (authenticated) unawaited(_load());
  }

  final ModerationAppealRepository _repository;
  final bool _authenticated;
  AppealCredential? _credential;

  Future<bool> issueCredential({
    required String account,
    required String password,
  }) async {
    if (state.isIssuingCredential) return false;
    state = state.copyWith(isIssuingCredential: true, clearFailure: true);
    try {
      final credential = await _repository.issueCredential(
        account: account,
        password: password,
      );
      if (!mounted) return false;
      _credential = credential;
      state = ModerationAppealState(
        phase: ModerationAppealPhase.loading,
        credentialExpiresAt: credential.expiresAt,
      );
      await _load();
      return mounted && state.phase == ModerationAppealPhase.ready;
    } on ApiFailure catch (failure) {
      if (!mounted) return false;
      state = ModerationAppealState(
        phase: ModerationAppealPhase.credential,
        failure: failure,
      );
      return false;
    } on Object catch (error) {
      if (!mounted) return false;
      state = ModerationAppealState.credential(
        failure: ApiFailure(userMessage: '账号验证没有完成，请稍后重试。', cause: error),
      );
      return false;
    }
  }

  Future<void> retry() async {
    if (_credential?.isExpired == true) {
      _clearCredential(const ApiFailure(userMessage: '申诉凭据已过期，请重新验证账号密码。'));
      return;
    }
    if (_credential == null && !_authenticated) {
      state = const ModerationAppealState.credential();
      return;
    }
    state = state.copyWith(
      phase: ModerationAppealPhase.loading,
      clearFailure: true,
    );
    await _load();
  }

  Future<bool> submit({
    required String decisionId,
    required String statement,
  }) async {
    if (state.phase != ModerationAppealPhase.ready || state.isSubmitting) {
      return false;
    }
    if (_credential?.isExpired == true) {
      _clearCredential(const ApiFailure(userMessage: '申诉凭据已过期，请重新验证账号密码。'));
      return false;
    }
    state = state.copyWith(
      submittingDecisionId: decisionId,
      clearFailure: true,
    );
    try {
      await _repository.submitAppeal(
        decisionId: decisionId,
        statement: statement,
        appealToken: _credential?.token,
      );
      if (!mounted) return false;
      await _load(preserveDecisions: true);
      return mounted;
    } on ApiFailure catch (failure) {
      if (!mounted) return false;
      if (failure.businessCode == 40120) {
        _clearCredential(failure);
      } else if (failure.businessCode == 40921) {
        await _load(preserveDecisions: true);
        return mounted;
      } else {
        state = state.copyWith(failure: failure, clearSubmitting: true);
      }
      return false;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        failure: ApiFailure(userMessage: '申诉提交没有完成，请稍后重试。', cause: error),
        clearSubmitting: true,
      );
      return false;
    }
  }

  void clearActionFailure() {
    if (state.failure != null) state = state.copyWith(clearFailure: true);
  }

  Future<void> _load({bool preserveDecisions = false}) async {
    try {
      final decisions = await _repository.fetchMyDecisions(
        appealToken: _credential?.token,
      );
      if (!mounted) return;
      state = ModerationAppealState(
        phase: ModerationAppealPhase.ready,
        decisions: decisions,
        credentialExpiresAt: _credential?.expiresAt,
      );
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      if (failure.businessCode == 40108 ||
          failure.businessCode == 40109 ||
          failure.businessCode == 40120) {
        _clearCredential(failure);
        return;
      }
      state = ModerationAppealState(
        phase: ModerationAppealPhase.failed,
        decisions: preserveDecisions ? state.decisions : const [],
        failure: failure,
        credentialExpiresAt: _credential?.expiresAt,
      );
    } on Object catch (error) {
      if (!mounted) return;
      state = ModerationAppealState(
        phase: ModerationAppealPhase.failed,
        decisions: preserveDecisions ? state.decisions : const [],
        failure: ApiFailure(userMessage: '治理决定没有加载完成，请稍后重试。', cause: error),
        credentialExpiresAt: _credential?.expiresAt,
      );
    }
  }

  void _clearCredential(ApiFailure failure) {
    _credential = null;
    state = ModerationAppealState.credential(failure: failure);
  }
}

final moderationAppealControllerProvider =
    StateNotifierProvider.autoDispose<
      ModerationAppealController,
      ModerationAppealState
    >((ref) {
      final authenticated = ref.watch(
        sessionControllerProvider.select((state) => state.isAuthenticated),
      );
      return ModerationAppealController(
        ref.watch(moderationAppealRepositoryProvider),
        authenticated: authenticated,
      );
    });
