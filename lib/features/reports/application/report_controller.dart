import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/reports/data/report_repository.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';

class ReportState {
  const ReportState({this.isSubmitting = false, this.failure});

  final bool isSubmitting;
  final ApiFailure? failure;
}

class ReportController extends StateNotifier<ReportState> {
  ReportController(this._repository, this.target) : super(const ReportState());

  final ReportRepository _repository;
  final ReportTarget target;

  Future<ReportResult?> submit(ReportReason reason, String details) async {
    if (state.isSubmitting) return null;
    ReportInput input;
    try {
      input = ReportInput(
        target: target,
        reason: reason,
        details: details,
      ).normalized();
    } on ApiFailure catch (failure) {
      state = ReportState(failure: failure);
      return null;
    }
    state = const ReportState(isSubmitting: true);
    try {
      final result = await _repository.create(input);
      if (!mounted) return null;
      state = const ReportState();
      return result;
    } on Object catch (error) {
      if (!mounted) return null;
      state = ReportState(
        failure: error is ApiFailure
            ? error
            : ApiFailure(userMessage: '举报没有提交完成，请重试。', cause: error),
      );
      return null;
    }
  }
}

final reportControllerProvider = StateNotifierProvider.autoDispose
    .family<ReportController, ReportState, ReportTarget>((ref, target) {
      return ReportController(ref.watch(reportRepositoryProvider), target);
    });
