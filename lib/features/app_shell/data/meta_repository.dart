import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

class ContractInfo {
  const ContractInfo({
    required this.contractVersion,
    required this.markdownContractVersion,
    this.buildSha,
  });

  final String contractVersion;
  final int markdownContractVersion;
  final String? buildSha;
}

abstract interface class MetaRepository {
  Future<ContractInfo> fetch();
}

class ApiMetaRepository implements MetaRepository {
  ApiMetaRepository(this._api);

  final WenyouApi _api;

  @override
  Future<ContractInfo> fetch() async {
    try {
      final response = await _api.getMetaApi().metaGetMeta(
        extra: const {'skipAuth': true},
      );
      final data = response.data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '服务端没有返回兼容信息。');
      }
      return ContractInfo(
        contractVersion: data.contractVersion,
        markdownContractVersion: data.markdownContractVersion.toInt(),
        buildSha: data.buildSha,
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
}
