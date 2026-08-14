import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';

abstract interface class ReportRepository {
  Future<ReportResult> create(ReportInput input);
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return const _UnboundReportRepository();
});

class _UnboundReportRepository implements ReportRepository {
  const _UnboundReportRepository();

  @override
  Future<ReportResult> create(ReportInput input) {
    return Future.error(StateError('举报仓储尚未在应用组合根绑定。'));
  }
}
