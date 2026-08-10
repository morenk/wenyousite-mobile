import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/reports/application/report_controller.dart';
import 'package:wenyousite_mobile/features/reports/data/report_repository.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';

void main() {
  test('本地校验阻止空说明，冲突保留失败并允许显式重试', () async {
    final repository = _ControllerReportRepository();
    final controller = ReportController(
      repository,
      const ReportTarget.moment('moment-1'),
    );
    addTearDown(controller.dispose);

    expect(await controller.submit(ReportReason.other, '   '), isNull);
    expect(repository.calls, 0);
    expect(controller.state.failure?.userMessage, contains('补充说明'));

    repository.nextFailure = const ApiFailure(
      userMessage: '已经举报',
      businessCode: 40914,
    );
    expect(await controller.submit(ReportReason.spam, ''), isNull);
    expect(controller.state.failure?.businessCode, 40914);

    final result = await controller.submit(ReportReason.spam, '  重复广告  ');
    expect(result?.id, 'report-1');
    expect(repository.calls, 2);
    expect(repository.lastInput?.details, '重复广告');
    expect(controller.state.failure, isNull);
  });
}

class _ControllerReportRepository implements ReportRepository {
  var calls = 0;
  ApiFailure? nextFailure;
  ReportInput? lastInput;

  @override
  Future<ReportResult> create(ReportInput input) async {
    calls += 1;
    lastInput = input;
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      throw failure;
    }
    return ReportResult(
      id: 'report-1',
      target: input.target,
      reason: input.reason,
      createdAt: DateTime.utc(2026, 8, 10),
    );
  }
}
