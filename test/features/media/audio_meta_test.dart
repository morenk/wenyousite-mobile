import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/app_shell/data/meta_repository.dart';

void main() {
  for (final version in [null, 1, 2]) {
    test('原始 meta JSON 数字版本 $version 经生成 API 决定上传能力', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api/v1'));
      addTearDown(dio.close);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/api/v1/meta');
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'code': 0,
                  'message': 'ok',
                  'data': {
                    'contractVersion': '5.37.0-dev.20261016.1',
                    'markdownContractVersion': 5,
                    'capabilities': {
                      'stickers': true,
                      'directMessages': true,
                      'pushNotifications': false,
                    },
                    'mobileCompatibility': {
                      'android': <String, Object?>{},
                      'ios': <String, Object?>{},
                    },
                    if (version != null)
                      'audioUpload': {
                        'version': version,
                        'maxBytes': 31457280,
                        'maxDurationMs': 600000,
                        'contentTypes': [
                          'audio/mpeg',
                          'audio/mp4',
                          'audio/wav',
                          'audio/ogg',
                          'audio/flac',
                        ],
                        'outputContentType': 'audio/mpeg',
                      },
                  },
                },
              ),
            );
          },
        ),
      );
      final result = await ApiMetaRepository(WenyouApi(dio: dio)).fetch();
      expect(result.audioUpload != null, version == 1);
      if (version == 1) {
        expect(result.audioUpload!.maxBytes, 31457280);
        expect(result.audioUpload!.contentTypes, hasLength(5));
      }
    });
  }
}
