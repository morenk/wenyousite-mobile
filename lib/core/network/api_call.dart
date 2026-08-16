import 'package:dio/dio.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

/// Runs a repository operation and translates transport errors at one boundary.
Future<T> runApiCall<T>(
  Future<T> Function() operation, {
  Map<int, String> featureMessages = const {},
}) async {
  try {
    return await operation();
  } on DioException catch (error) {
    throw ApiFailure.fromDio(error, featureMessages: featureMessages);
  }
}
