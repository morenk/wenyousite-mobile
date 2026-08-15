import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/moderation/application/moderation_appeal_repository_ports.dart';
import 'package:wenyousite_mobile/features/moderation/domain/moderation_appeal_models.dart';

export 'package:wenyousite_mobile/features/moderation/application/moderation_appeal_repository_ports.dart'
    show ModerationAppealRepository, moderationAppealRepositoryProvider;

class ApiModerationAppealRepository implements ModerationAppealRepository {
  ApiModerationAppealRepository(this._api);

  final ModerationAppealsApi _api;

  static const _featureMessages = <int, String>{
    40105: '密码尝试次数过多，请稍后再试。',
    40108: '账号处于暂停状态，请验证密码后进入申诉通道。',
    40109: '账号已被封禁，请验证密码后进入申诉通道。',
    40110: '账号或密码错误。',
    40120: '申诉凭据已过期，请重新验证账号密码。',
    40417: '这项治理决定不存在或不属于当前账号。',
    40921: '这项决定已经提交过申诉，请刷新查看。',
    40922: '这项决定已超过 30 天申诉期限。',
  };

  @override
  Future<AppealCredential> issueCredential({
    required String account,
    required String password,
  }) async {
    try {
      final response = await _api.userModerationAppealsIssueToken(
        issueAppealTokenDto: IssueAppealTokenDto(
          (builder) => builder
            ..account = account.trim()
            ..password = password,
        ),
        extra: ApiRequestPolicy.public.extra,
      );
      final data = response.data?.data;
      if (data == null || data.appealToken.trim().isEmpty) {
        throw const ApiFailure(userMessage: '服务端没有返回可用的申诉凭据，请稍后重试。');
      }
      return AppealCredential(
        token: data.appealToken,
        expiresAt: data.expiresAt.toUtc(),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: _featureMessages);
    }
  }

  @override
  Future<List<ModerationDecision>> fetchMyDecisions({
    String? appealToken,
  }) async {
    try {
      final response = await _api.userModerationAppealsMine(
        headers: _headers(appealToken),
        extra: _extra(appealToken),
      );
      final data = response.data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '治理决定响应为空，请稍后重试。');
      }
      return data.map(_mapDecision).toList(growable: false);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: _featureMessages);
    }
  }

  @override
  Future<void> submitAppeal({
    required String decisionId,
    required String statement,
    String? appealToken,
  }) async {
    try {
      final response = await _api.userModerationAppealsAppeal(
        createModerationAppealDto: CreateModerationAppealDto(
          (builder) => builder
            ..decisionId = decisionId
            ..statement = statement.trim(),
        ),
        headers: _headers(appealToken),
        extra: _extra(appealToken),
      );
      final data = response.data?.data;
      if (data == null ||
          data.id.trim().isEmpty ||
          data.decision.id != decisionId ||
          data.appellant.id.trim().isEmpty) {
        throw const ApiFailure(userMessage: '申诉结果不完整，请重新加载确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error, featureMessages: _featureMessages);
    }
  }

  Map<String, dynamic>? _headers(String? appealToken) => appealToken == null
      ? null
      : <String, dynamic>{'Authorization': 'Bearer $appealToken'};

  Map<String, dynamic>? _extra(String? appealToken) =>
      appealToken == null ? null : ApiRequestPolicy.public.extra;

  ModerationDecision _mapDecision(ModerationDecisionPublicResponseDto dto) {
    return ModerationDecision(
      id: dto.id,
      targetType: dto.targetType.name,
      targetId: dto.targetId,
      action: dto.action.name,
      policyCode: dto.policyCode.name,
      publicExplanation: dto.publicExplanation,
      active: dto.active,
      createdAt: dto.createdAt.toUtc(),
      appeal: _mapAppeal(
        dto.appeal == null
            ? null
            : <String, Object?>{
                for (final entry in dto.appeal!.entries)
                  entry.key: entry.value?.value,
              },
      ),
    );
  }

  ModerationAppealSummary? _mapAppeal(Map<String, Object?>? values) {
    if (values == null) return null;
    final id = values['id']?.toString();
    final statement = values['statement']?.toString();
    final createdAt = DateTime.tryParse(values['createdAt']?.toString() ?? '');
    if (id == null || statement == null || createdAt == null) return null;
    return ModerationAppealSummary(
      id: id,
      statement: statement,
      status: switch (values['status']?.toString()) {
        'PENDING' => ModerationAppealStatus.pending,
        'UPHELD' => ModerationAppealStatus.upheld,
        'OVERTURNED' => ModerationAppealStatus.overturned,
        _ => ModerationAppealStatus.unknown,
      },
      createdAt: createdAt.toUtc(),
      handledNote: _nonEmpty(values['handledNote']),
      handledAt: DateTime.tryParse(
        values['handledAt']?.toString() ?? '',
      )?.toUtc(),
    );
  }

  String? _nonEmpty(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

final apiModerationAppealRepositoryProvider =
    Provider<ModerationAppealRepository>(
      (ref) => ApiModerationAppealRepository(
        ref.watch(wenyouApiProvider).getModerationAppealsApi(),
      ),
    );
