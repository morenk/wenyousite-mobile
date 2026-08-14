import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/contract_info.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

export 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart'
    show MetaRepository;

class ApiMetaRepository implements MetaRepository {
  ApiMetaRepository(this._api);

  final WenyouApi _api;

  @override
  Future<ContractInfo> fetch() async {
    try {
      final response = await _api.getMetaApi().metaGetMeta(
        extra: ApiRequestPolicy.public.extra,
      );
      final data = response.data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '服务端没有返回兼容信息。');
      }
      return ContractInfo(
        contractVersion: data.contractVersion,
        markdownContractVersion: data.markdownContractVersion.toInt(),
        buildSha: data.buildSha,
        android: _policyFromDto(data.mobileCompatibility.android),
        ios: _policyFromDto(data.mobileCompatibility.ios),
        stickersEnabled: data.capabilities.stickers,
        directMessagesEnabled: data.capabilities.directMessages,
        pushNotificationsEnabled: data.capabilities.pushNotifications,
      );
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint(
          'meta response failed type=${error.type.name} '
          'status=${error.response?.statusCode} error=${error.error}',
        );
      }
      throw ApiFailure.fromDio(error);
    }
  }

  MobilePlatformPolicy _policyFromDto(MobilePlatformCompatibilityDto dto) {
    return MobilePlatformPolicy(
      minimumSupportedBuild: _integerOrNull(dto.minimumSupportedBuild),
      recommendedBuild: _integerOrNull(dto.recommendedBuild),
      updateUrl: dto.updateUrl,
    );
  }

  int? _integerOrNull(num? value) {
    if (value == null || !value.isFinite || value < 1) return null;
    final integer = value.toInt();
    return integer == value ? integer : null;
  }
}

final apiMetaRepositoryProvider = Provider<MetaRepository>((ref) {
  return ApiMetaRepository(ref.watch(wenyouApiProvider));
});
