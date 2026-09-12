import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';

void main() {
  final fixture =
      jsonDecode(
            File('contracts/media-display-v1-fixtures.json').readAsStringSync(),
          )
          as Map<String, Object?>;
  for (final raw in fixture['cases']! as List<Object?>) {
    final item = raw! as Map<String, Object?>;
    test('完整展示共享契约：${item['id']}', () {
      if (item['display'] case final Map<String, Object?> display) {
        final dto = standardSerializers.deserializeWith(
          MediaDisplayResponseDto.serializer,
          display,
        )!;
        expect(
          dto.contentType,
          MediaDisplayResponseDtoContentTypeEnum.imageSlashWebp,
        );
        expect(
          standardSerializers.serializeWith(
            MediaDisplayResponseDto.serializer,
            dto,
          ),
          display,
        );
        switch (item['id']) {
          case 'full-animation':
            expect(dto.url, item['expectedDisplayUrl']);
            expect(item['sourceUrl'], item['expectedPersistedUrl']);
            expect(dto.url, isNot(item['sourceUrl']));
            expect(dto.animated, isTrue);
            expect(dto.loopCount, 0);
          case 'static':
            expect(dto.animated, isFalse);
            expect(dto.frameCount, 1);
            expect(dto.durationMs, 0);
            expect(dto.loopCount, 1);
          case 'finite-loop':
            expect(dto.loopCount, 3);
        }
      } else if (item['id'] == 'legacy-pending') {
        final dto = standardSerializers.deserializeWith(
          ThreadCoverMediaResponseDto.serializer,
          {'url': item['sourceUrl'], 'display': null},
        )!;
        expect(dto.display, isNull);
        expect(dto.url, item['sourceUrl']);
      } else if (item['id'] == 'markdown-identities') {
        final entries = item['mediaDisplays']! as List<Object?>;
        final dto = standardSerializers.deserializeWith(
          MarkdownMediaDisplayResponseDto.serializer,
          entries.single,
        )!;
        expect(item['content'], contains(dto.sourceUrl));
        expect(item['content'], isNot(contains(dto.display!.url)));
      } else {
        fail('新增共享语料必须补充明确断言：${item['id']}');
      }
    });
  }
}
