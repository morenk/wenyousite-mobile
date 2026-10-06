import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';

void main() {
  test('所有正文写 DTO 将能力序列化成整数6，省略仍兼容旧服务', () {
    final values = <Object?>[
      standardSerializers.serializeWith(
        CreatePostDto.serializer,
        CreatePostDto(
          (b) => b
            ..content = '正文'
            ..markdownContractVersion =
                CreatePostDtoMarkdownContractVersionEnum.number6,
        ),
      ),
      standardSerializers.serializeWith(
        UpdatePostDto.serializer,
        UpdatePostDto(
          (b) => b
            ..content = '删光提及'
            ..version = 1
            ..markdownContractVersion =
                UpdatePostDtoMarkdownContractVersionEnum.number6,
        ),
      ),
      standardSerializers.serializeWith(
        UpsertBodyDto.serializer,
        UpsertBodyDto(
          (b) => b
            ..content = '正文'
            ..markdownContractVersion =
                UpsertBodyDtoMarkdownContractVersionEnum.number6,
        ),
      ),
      standardSerializers.serializeWith(
        CreateSubthreadDto.serializer,
        CreateSubthreadDto(
          (b) => b
            ..title = '子贴'
            ..markdownContractVersion =
                CreateSubthreadDtoMarkdownContractVersionEnum.number6,
        ),
      ),
      standardSerializers.serializeWith(
        SaveThreadAggregateDto.serializer,
        SaveThreadAggregateDto(
          (b) => b
            ..content = '正文'
            ..version = 1
            ..defaultSubthreadVersion = 1
            ..markdownContractVersion =
                SaveThreadAggregateDtoMarkdownContractVersionEnum.number6,
        ),
      ),
      standardSerializers.serializeWith(
        CreateThreadDto.serializer,
        CreateThreadDto(
          (b) => b
            ..content = '初始正文'
            ..markdownContractVersion =
                CreateThreadDtoMarkdownContractVersionEnum.number6,
        ),
      ),
      standardSerializers.serializeWith(
        CreateDraftDto.serializer,
        CreateDraftDto(
          (b) => b
            ..content = '草稿'
            ..markdownContractVersion =
                CreateDraftDtoMarkdownContractVersionEnum.number6,
        ),
      ),
      standardSerializers.serializeWith(
        UpdateDraftDto.serializer,
        UpdateDraftDto(
          (b) => b
            ..content = '草稿'
            ..version = 1
            ..markdownContractVersion =
                UpdateDraftDtoMarkdownContractVersionEnum.number6,
        ),
      ),
    ];
    for (final value in values) {
      final json = value as Map;
      expect(json['markdownContractVersion'], 6);
      expect(json['markdownContractVersion'], isA<int>());
    }
    final legacy =
        standardSerializers.serializeWith(
              CreatePostDto.serializer,
              CreatePostDto((b) => b.content = '正文'),
            )
            as Map;
    expect(legacy.containsKey('markdownContractVersion'), isFalse);
  });
}
