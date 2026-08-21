import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/reports/application/report_repository_ports.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';

export 'package:wenyousite_mobile/features/reports/application/report_repository_ports.dart'
    show ReportRepository, reportRepositoryProvider;

class ApiReportRepository implements ReportRepository {
  ApiReportRepository(this._api);

  final ReportsApi _api;

  @override
  Future<ReportResult> create(ReportInput input) async {
    late final ReportInput normalized;
    try {
      normalized = input.normalized();
    } on ReportInputValidationException catch (failure) {
      throw ApiFailure(userMessage: failure.userMessage, cause: failure);
    }
    final request = CreateReportDto((builder) {
      builder
        ..targetType = _requestTargetType(normalized.target.type)
        ..targetId = normalized.target.id
        ..reasonCode = _requestReason(normalized.reason);
      if (normalized.details != null) builder.details = normalized.details;
    });
    try {
      final dto = (await _api.reportsCreate(
        createReportDto: request,
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '举报失败，请稍后重试。');
      }
      final target = _responseTarget(dto.targetType, dto.targetId);
      final reason = _responseReason(dto.reasonCode);
      if (dto.status != ReportResponseDtoStatusEnum.PENDING ||
          target != normalized.target ||
          reason != normalized.reason) {
        throw const ApiFailure(userMessage: '举报确认信息与本次提交不一致，请重新加载。');
      }
      final id = dto.id.trim();
      if (id.isEmpty) {
        throw const ApiFailure(userMessage: '举报失败，请重试。');
      }
      return ReportResult(
        id: id,
        target: target,
        reason: reason,
        createdAt: dto.createdAt,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  CreateReportDtoTargetTypeEnum _requestTargetType(ReportTargetType type) {
    return switch (type) {
      ReportTargetType.user => CreateReportDtoTargetTypeEnum.USER,
      ReportTargetType.thread => CreateReportDtoTargetTypeEnum.THREAD,
      ReportTargetType.post => CreateReportDtoTargetTypeEnum.POST,
      ReportTargetType.moment => CreateReportDtoTargetTypeEnum.MOMENT,
      ReportTargetType.momentComment =>
        CreateReportDtoTargetTypeEnum.MOMENT_COMMENT,
      ReportTargetType.directMessage =>
        CreateReportDtoTargetTypeEnum.DIRECT_MESSAGE,
    };
  }

  CreateReportDtoReasonCodeEnum _requestReason(ReportReason reason) {
    return switch (reason) {
      ReportReason.spam => CreateReportDtoReasonCodeEnum.SPAM,
      ReportReason.harassment => CreateReportDtoReasonCodeEnum.HARASSMENT,
      ReportReason.hateOrThreats =>
        CreateReportDtoReasonCodeEnum.HATE_OR_THREATS,
      ReportReason.sexualContent =>
        CreateReportDtoReasonCodeEnum.SEXUAL_CONTENT,
      ReportReason.violentContent =>
        CreateReportDtoReasonCodeEnum.VIOLENT_CONTENT,
      ReportReason.personalInformation =>
        CreateReportDtoReasonCodeEnum.PERSONAL_INFORMATION,
      ReportReason.impersonationOrFraud =>
        CreateReportDtoReasonCodeEnum.IMPERSONATION_OR_FRAUD,
      ReportReason.intellectualProperty =>
        CreateReportDtoReasonCodeEnum.INTELLECTUAL_PROPERTY,
      ReportReason.illegalContent =>
        CreateReportDtoReasonCodeEnum.ILLEGAL_CONTENT,
      ReportReason.other => CreateReportDtoReasonCodeEnum.OTHER,
    };
  }

  ReportTarget _responseTarget(
    ReportResponseDtoTargetTypeEnum type,
    String id,
  ) {
    return switch (type) {
      ReportResponseDtoTargetTypeEnum.USER => ReportTarget.user(id),
      ReportResponseDtoTargetTypeEnum.THREAD => ReportTarget.thread(id),
      ReportResponseDtoTargetTypeEnum.POST => ReportTarget.post(id),
      ReportResponseDtoTargetTypeEnum.MOMENT => ReportTarget.moment(id),
      ReportResponseDtoTargetTypeEnum.MOMENT_COMMENT =>
        ReportTarget.momentComment(id),
      ReportResponseDtoTargetTypeEnum.DIRECT_MESSAGE =>
        ReportTarget.directMessage(id),
      _ => throw const ApiFailure(userMessage: '暂时无法举报这类内容。'),
    };
  }

  ReportReason _responseReason(ReportResponseDtoReasonCodeEnum reason) {
    return switch (reason) {
      ReportResponseDtoReasonCodeEnum.SPAM => ReportReason.spam,
      ReportResponseDtoReasonCodeEnum.HARASSMENT => ReportReason.harassment,
      ReportResponseDtoReasonCodeEnum.HATE_OR_THREATS =>
        ReportReason.hateOrThreats,
      ReportResponseDtoReasonCodeEnum.SEXUAL_CONTENT =>
        ReportReason.sexualContent,
      ReportResponseDtoReasonCodeEnum.VIOLENT_CONTENT =>
        ReportReason.violentContent,
      ReportResponseDtoReasonCodeEnum.PERSONAL_INFORMATION =>
        ReportReason.personalInformation,
      ReportResponseDtoReasonCodeEnum.IMPERSONATION_OR_FRAUD =>
        ReportReason.impersonationOrFraud,
      ReportResponseDtoReasonCodeEnum.INTELLECTUAL_PROPERTY =>
        ReportReason.intellectualProperty,
      ReportResponseDtoReasonCodeEnum.ILLEGAL_CONTENT =>
        ReportReason.illegalContent,
      ReportResponseDtoReasonCodeEnum.OTHER => ReportReason.other,
      _ => throw const ApiFailure(userMessage: '暂时无法使用这类举报原因。'),
    };
  }
}

final apiReportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ApiReportRepository(ref.watch(wenyouApiProvider).getReportsApi());
});
