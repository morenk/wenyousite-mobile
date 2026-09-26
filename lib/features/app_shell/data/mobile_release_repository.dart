import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_release.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

class ApiMobileReleaseRepository implements MobileReleaseRepository {
  ApiMobileReleaseRepository(this._api);

  final MobileReleasesApi _api;

  @override
  Future<MobileRelease?> fetch(MobileReleaseTarget target) async {
    if (target.platform != MobileClientPlatform.android ||
        target.build < 1 ||
        target.version.isEmpty) {
      throw _invalid;
    }
    try {
      final dto = (await _api.mobileReleasesDetail(
        platform: 'android',
        buildNumber: target.build,
        extra: ApiRequestPolicy.public.extra,
      )).data?.data;
      if (dto == null) throw _invalid;
      final release = _map(dto);
      if (release.target != target) throw _invalid;
      return release;
    } on DioException catch (error) {
      final failure = ApiFailure.fromDio(error);
      if (failure.httpStatus == 404 && failure.businessCode == 40400) {
        return null;
      }
      throw failure;
    }
  }

  @override
  Future<MobileReleasePage> fetchPage({
    required MobileClientPlatform platform,
    String? cursor,
  }) async {
    if (platform != MobileClientPlatform.android) throw _invalid;
    try {
      final response = (await _api.mobileReleasesList(
        platform: 'android',
        cursor: cursor,
        limit: 20,
        extra: ApiRequestPolicy.public.extra,
      )).data;
      if (response == null) throw _invalid;
      final nextCursor = response.meta.cursor;
      if (response.meta.hasMore && (nextCursor == null || nextCursor.isEmpty)) {
        throw _invalid;
      }
      return MobileReleasePage(
        items: List.unmodifiable(response.data.map(_map)),
        nextCursor: response.meta.hasMore ? nextCursor : null,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  MobileRelease _map(PublicMobileReleaseDto dto) {
    if (dto.platform != PublicMobileReleaseDtoPlatformEnum.android ||
        !dto.buildNumber.isFinite ||
        dto.buildNumber < 1 ||
        dto.buildNumber > 2100000000 ||
        dto.buildNumber != dto.buildNumber.toInt() ||
        !dto.revision.isFinite ||
        dto.revision < 1 ||
        dto.revision != dto.revision.toInt() ||
        !RegExp(
          r'^[0-9A-Za-z][0-9A-Za-z._-]{0,63}$',
        ).hasMatch(dto.versionName) ||
        dto.summary.trim().isEmpty ||
        dto.items.isEmpty ||
        dto.items.any((item) => item.trim().isEmpty)) {
      throw _invalid;
    }
    return MobileRelease(
      target: (
        platform: MobileClientPlatform.android,
        build: dto.buildNumber.toInt(),
        version: dto.versionName,
      ),
      summary: dto.summary,
      items: List.unmodifiable(dto.items),
      revision: dto.revision.toInt(),
      publishedAt: dto.publishedAt,
    );
  }

  static const _invalid = ApiFailure.invalidResponse(
    diagnosticCode: 'mobile_release_invalid',
  );
}

final apiMobileReleaseRepositoryProvider = Provider<MobileReleaseRepository>(
  (ref) => ApiMobileReleaseRepository(
    ref.watch(wenyouApiProvider).getMobileReleasesApi(),
  ),
);
