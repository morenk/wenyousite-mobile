import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/reports/data/report_repository.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';

void main() {
  setUpAll(() => registerFallbackValue(_FakeCreateReportDto()));

  test('五类目标与八类原因完整映射 reportsCreate 并校验待处理响应', () async {
    final api = _MockReportsApi();
    final payloads = <CreateReportDto>[];
    when(
      () => api.reportsCreate(createReportDto: any(named: 'createReportDto')),
    ).thenAnswer((invocation) async {
      final request =
          invocation.namedArguments[#createReportDto]! as CreateReportDto;
      payloads.add(request);
      return Response<ReportsCreate201Response>(
        requestOptions: RequestOptions(path: '/api/v1/reports'),
        data: ReportsCreate201Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.update(
              (report) => report
                ..id = 'report-${payloads.length}'
                ..reporterId = 'reporter-1'
                ..targetType = _responseTarget(request.targetType)
                ..targetId = request.targetId
                ..reasonCode = _responseReason(request.reasonCode)
                ..details = request.details
                ..status = ReportResponseDtoStatusEnum.PENDING
                ..createdAt = DateTime.utc(2026, 8, 10)
                ..updatedAt = DateTime.utc(2026, 8, 10),
            ),
        ),
      );
    });
    final repository = ApiReportRepository(api);
    final targets = <ReportTarget>[
      const ReportTarget.user('user-1'),
      const ReportTarget.thread('thread-1'),
      const ReportTarget.post('post-1'),
      const ReportTarget.moment('moment-1'),
      const ReportTarget.momentComment('comment-1'),
    ];

    for (var index = 0; index < ReportReason.values.length; index++) {
      final reason = ReportReason.values[index];
      final target = targets[index % targets.length];
      final result = await repository.create(
        ReportInput(
          target: target,
          reason: reason,
          details: reason.requiresDetails ? '  具体问题  ' : null,
        ),
      );
      expect(result.target, target);
      expect(result.reason, reason);
    }

    expect(payloads, hasLength(8));
    expect(
      payloads.map((item) => item.targetType).toSet(),
      containsAll(targets.map((target) => _requestTarget(target.type))),
    );
    expect(
      payloads.map((item) => item.reasonCode).toSet(),
      containsAll(ReportReason.values.map(_requestReason)),
    );
    expect(payloads.last.details, '具体问题');
  });

  test('其他原因缺少说明和服务端目标错配均 fail-closed', () async {
    final api = _MockReportsApi();
    final repository = ApiReportRepository(api);

    await expectLater(
      repository.create(
        const ReportInput(
          target: ReportTarget.user('user-1'),
          reason: ReportReason.other,
          details: '   ',
        ),
      ),
      throwsA(isA<ApiFailure>()),
    );
    verifyNever(
      () => api.reportsCreate(createReportDto: any(named: 'createReportDto')),
    );

    when(
      () => api.reportsCreate(createReportDto: any(named: 'createReportDto')),
    ).thenAnswer(
      (_) async => Response<ReportsCreate201Response>(
        requestOptions: RequestOptions(path: '/api/v1/reports'),
        data: ReportsCreate201Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.update(
              (report) => report
                ..id = 'report-1'
                ..reporterId = 'reporter-1'
                ..targetType = ReportResponseDtoTargetTypeEnum.THREAD
                ..targetId = 'thread-other'
                ..reasonCode = ReportResponseDtoReasonCodeEnum.SPAM
                ..status = ReportResponseDtoStatusEnum.PENDING
                ..createdAt = DateTime.utc(2026, 8, 10)
                ..updatedAt = DateTime.utc(2026, 8, 10),
            ),
        ),
      ),
    );
    await expectLater(
      repository.create(
        const ReportInput(
          target: ReportTarget.thread('thread-1'),
          reason: ReportReason.spam,
        ),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('不一致'),
        ),
      ),
    );
  });
}

class _MockReportsApi extends Mock implements ReportsApi {}

class _FakeCreateReportDto extends Fake implements CreateReportDto {}

CreateReportDtoTargetTypeEnum _requestTarget(ReportTargetType target) {
  return switch (target) {
    ReportTargetType.user => CreateReportDtoTargetTypeEnum.USER,
    ReportTargetType.thread => CreateReportDtoTargetTypeEnum.THREAD,
    ReportTargetType.post => CreateReportDtoTargetTypeEnum.POST,
    ReportTargetType.moment => CreateReportDtoTargetTypeEnum.MOMENT,
    ReportTargetType.momentComment =>
      CreateReportDtoTargetTypeEnum.MOMENT_COMMENT,
  };
}

ReportResponseDtoTargetTypeEnum _responseTarget(
  CreateReportDtoTargetTypeEnum target,
) {
  return switch (target) {
    CreateReportDtoTargetTypeEnum.USER => ReportResponseDtoTargetTypeEnum.USER,
    CreateReportDtoTargetTypeEnum.THREAD =>
      ReportResponseDtoTargetTypeEnum.THREAD,
    CreateReportDtoTargetTypeEnum.POST => ReportResponseDtoTargetTypeEnum.POST,
    CreateReportDtoTargetTypeEnum.MOMENT =>
      ReportResponseDtoTargetTypeEnum.MOMENT,
    CreateReportDtoTargetTypeEnum.MOMENT_COMMENT =>
      ReportResponseDtoTargetTypeEnum.MOMENT_COMMENT,
    _ => throw StateError('unexpected target'),
  };
}

CreateReportDtoReasonCodeEnum _requestReason(ReportReason reason) {
  return switch (reason) {
    ReportReason.spam => CreateReportDtoReasonCodeEnum.SPAM,
    ReportReason.harassment => CreateReportDtoReasonCodeEnum.HARASSMENT,
    ReportReason.hateOrThreats => CreateReportDtoReasonCodeEnum.HATE_OR_THREATS,
    ReportReason.sexualContent => CreateReportDtoReasonCodeEnum.SEXUAL_CONTENT,
    ReportReason.violentContent =>
      CreateReportDtoReasonCodeEnum.VIOLENT_CONTENT,
    ReportReason.personalInformation =>
      CreateReportDtoReasonCodeEnum.PERSONAL_INFORMATION,
    ReportReason.illegalContent =>
      CreateReportDtoReasonCodeEnum.ILLEGAL_CONTENT,
    ReportReason.other => CreateReportDtoReasonCodeEnum.OTHER,
  };
}

ReportResponseDtoReasonCodeEnum _responseReason(
  CreateReportDtoReasonCodeEnum reason,
) {
  return switch (reason) {
    CreateReportDtoReasonCodeEnum.SPAM => ReportResponseDtoReasonCodeEnum.SPAM,
    CreateReportDtoReasonCodeEnum.HARASSMENT =>
      ReportResponseDtoReasonCodeEnum.HARASSMENT,
    CreateReportDtoReasonCodeEnum.HATE_OR_THREATS =>
      ReportResponseDtoReasonCodeEnum.HATE_OR_THREATS,
    CreateReportDtoReasonCodeEnum.SEXUAL_CONTENT =>
      ReportResponseDtoReasonCodeEnum.SEXUAL_CONTENT,
    CreateReportDtoReasonCodeEnum.VIOLENT_CONTENT =>
      ReportResponseDtoReasonCodeEnum.VIOLENT_CONTENT,
    CreateReportDtoReasonCodeEnum.PERSONAL_INFORMATION =>
      ReportResponseDtoReasonCodeEnum.PERSONAL_INFORMATION,
    CreateReportDtoReasonCodeEnum.ILLEGAL_CONTENT =>
      ReportResponseDtoReasonCodeEnum.ILLEGAL_CONTENT,
    CreateReportDtoReasonCodeEnum.OTHER =>
      ReportResponseDtoReasonCodeEnum.OTHER,
    _ => throw StateError('unexpected reason'),
  };
}
