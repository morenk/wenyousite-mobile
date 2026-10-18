import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';

void main() {
  test('文本颜色八类写 DTO 独立序列化整数1，省略兼容旧服务', () {
    final values = <Object?>[
      standardSerializers.serializeWith(
        CreatePostDto.serializer,
        CreatePostDto(
          (b) => b
            ..content = '正文'
            ..textColorVersion = CreatePostDtoTextColorVersionEnum.number1,
        ),
      ),
      standardSerializers.serializeWith(
        UpdatePostDto.serializer,
        UpdatePostDto(
          (b) => b
            ..content = '删光提及'
            ..version = 1
            ..textColorVersion = UpdatePostDtoTextColorVersionEnum.number1,
        ),
      ),
      standardSerializers.serializeWith(
        UpsertBodyDto.serializer,
        UpsertBodyDto(
          (b) => b
            ..content = '正文'
            ..textColorVersion = UpsertBodyDtoTextColorVersionEnum.number1,
        ),
      ),
      standardSerializers.serializeWith(
        CreateSubthreadDto.serializer,
        CreateSubthreadDto(
          (b) => b
            ..title = '子贴'
            ..textColorVersion = CreateSubthreadDtoTextColorVersionEnum.number1,
        ),
      ),
      standardSerializers.serializeWith(
        SaveThreadAggregateDto.serializer,
        SaveThreadAggregateDto(
          (b) => b
            ..content = '正文'
            ..version = 1
            ..defaultSubthreadVersion = 1
            ..textColorVersion =
                SaveThreadAggregateDtoTextColorVersionEnum.number1,
        ),
      ),
      standardSerializers.serializeWith(
        CreateThreadDto.serializer,
        CreateThreadDto(
          (b) => b
            ..content = '初始正文'
            ..textColorVersion = CreateThreadDtoTextColorVersionEnum.number1,
        ),
      ),
      standardSerializers.serializeWith(
        CreateDraftDto.serializer,
        CreateDraftDto(
          (b) => b
            ..content = '草稿'
            ..textColorVersion = CreateDraftDtoTextColorVersionEnum.number1,
        ),
      ),
      standardSerializers.serializeWith(
        UpdateDraftDto.serializer,
        UpdateDraftDto(
          (b) => b
            ..content = '草稿'
            ..version = 1
            ..textColorVersion = UpdateDraftDtoTextColorVersionEnum.number1,
        ),
      ),
    ];
    for (final value in values) {
      final json = value as Map;
      expect(json['textColorVersion'], 1);
      expect(json['textColorVersion'], isA<int>());
    }
    final legacy =
        standardSerializers.serializeWith(
              CreatePostDto.serializer,
              CreatePostDto((b) => b.content = '正文'),
            )
            as Map;
    expect(legacy.containsKey('textColorVersion'), isFalse);
  });
}
