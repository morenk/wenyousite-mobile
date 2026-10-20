import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';

import '../../support/post_edited_time_fixture.dart';

void main() {
  final readers = <String, DateTime? Function(Map<String, Object?>)>{
    'PostResponseDto': (json) => standardSerializers
        .deserializeWith(PostResponseDto.serializer, json)!
        .editedAt,
    'FloorResponseDto': (json) => standardSerializers
        .deserializeWith(FloorResponseDto.serializer, json)!
        .editedAt,
    'ReplyResponseDto': (json) => standardSerializers
        .deserializeWith(ReplyResponseDto.serializer, json)!
        .editedAt,
    'PostDetailResponseDto': (json) => standardSerializers
        .deserializeWith(PostDetailResponseDto.serializer, json)!
        .editedAt,
  };
  for (final entry in readers.entries) {
    test('${entry.key} 缺少或空编辑时间兼容，时间戳保持精度', () {
      expect(entry.value(postEditedTimeJson(includeEditedAt: false)), isNull);
      expect(entry.value(postEditedTimeJson()), isNull);
      expect(
        entry.value(
          postEditedTimeJson(editedAt: '2026-09-29T11:23:45.678+08:00'),
        ),
        DateTime.utc(2026, 9, 29, 3, 23, 45, 678),
      );
    });
  }
}
