//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/media_display_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'markdown_media_display_response_dto.g.dart';

/// MarkdownMediaDisplayResponseDto
///
/// Properties:
/// * [sourceUrl] - 正文精确来源 URL；编辑、引用和收藏继续持久化此身份
/// * [display] - 历史未补处理或无法确认时为空
@BuiltValue()
abstract class MarkdownMediaDisplayResponseDto implements Built<MarkdownMediaDisplayResponseDto, MarkdownMediaDisplayResponseDtoBuilder> {
  /// 正文精确来源 URL；编辑、引用和收藏继续持久化此身份
  @BuiltValueField(wireName: r'sourceUrl')
  String get sourceUrl;

  /// 历史未补处理或无法确认时为空
  @BuiltValueField(wireName: r'display')
  MediaDisplayResponseDto? get display;

  MarkdownMediaDisplayResponseDto._();

  factory MarkdownMediaDisplayResponseDto([void updates(MarkdownMediaDisplayResponseDtoBuilder b)]) = _$MarkdownMediaDisplayResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MarkdownMediaDisplayResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MarkdownMediaDisplayResponseDto> get serializer => _$MarkdownMediaDisplayResponseDtoSerializer();
}

class _$MarkdownMediaDisplayResponseDtoSerializer implements PrimitiveSerializer<MarkdownMediaDisplayResponseDto> {
  @override
  final Iterable<Type> types = const [MarkdownMediaDisplayResponseDto, _$MarkdownMediaDisplayResponseDto];

  @override
  final String wireName = r'MarkdownMediaDisplayResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MarkdownMediaDisplayResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sourceUrl';
    yield serializers.serialize(
      object.sourceUrl,
      specifiedType: const FullType(String),
    );
    yield r'display';
    yield object.display == null ? null : serializers.serialize(
      object.display,
      specifiedType: const FullType.nullable(MediaDisplayResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MarkdownMediaDisplayResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MarkdownMediaDisplayResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sourceUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceUrl = valueDes;
          break;
        case r'display':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MediaDisplayResponseDto),
          ) as MediaDisplayResponseDto?;
          if (valueDes == null) continue;
          result.display.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MarkdownMediaDisplayResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MarkdownMediaDisplayResponseDtoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
