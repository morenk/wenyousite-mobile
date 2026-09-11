//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/markdown_media_display_response_dto.dart';
import 'package:wenyou_api/src/model/dice_roll_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_body_post_response_dto.g.dart';

/// ThreadBodyPostResponseDto
///
/// Properties:
/// * [mediaDisplays] - 仅此次已授权正文中的精确来源映射；编辑保存继续使用 sourceUrl
/// * [id]
/// * [content]
/// * [version]
/// * [diceRolls]
@BuiltValue()
abstract class ThreadBodyPostResponseDto implements Built<ThreadBodyPostResponseDto, ThreadBodyPostResponseDtoBuilder> {
  /// 仅此次已授权正文中的精确来源映射；编辑保存继续使用 sourceUrl
  @BuiltValueField(wireName: r'mediaDisplays')
  BuiltList<MarkdownMediaDisplayResponseDto>? get mediaDisplays;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'version')
  num get version;

  @BuiltValueField(wireName: r'diceRolls')
  BuiltList<DiceRollResponseDto> get diceRolls;

  ThreadBodyPostResponseDto._();

  factory ThreadBodyPostResponseDto([void updates(ThreadBodyPostResponseDtoBuilder b)]) = _$ThreadBodyPostResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadBodyPostResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadBodyPostResponseDto> get serializer => _$ThreadBodyPostResponseDtoSerializer();
}

class _$ThreadBodyPostResponseDtoSerializer implements PrimitiveSerializer<ThreadBodyPostResponseDto> {
  @override
  final Iterable<Type> types = const [ThreadBodyPostResponseDto, _$ThreadBodyPostResponseDto];

  @override
  final String wireName = r'ThreadBodyPostResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadBodyPostResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.mediaDisplays != null) {
      yield r'mediaDisplays';
      yield serializers.serialize(
        object.mediaDisplays,
        specifiedType: const FullType(BuiltList, [FullType(MarkdownMediaDisplayResponseDto)]),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
    yield r'diceRolls';
    yield serializers.serialize(
      object.diceRolls,
      specifiedType: const FullType(BuiltList, [FullType(DiceRollResponseDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadBodyPostResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadBodyPostResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mediaDisplays':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MarkdownMediaDisplayResponseDto)]),
          ) as BuiltList<MarkdownMediaDisplayResponseDto>;
          result.mediaDisplays.replace(valueDes);
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        case r'diceRolls':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DiceRollResponseDto)]),
          ) as BuiltList<DiceRollResponseDto>;
          result.diceRolls.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadBodyPostResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadBodyPostResponseDtoBuilder();
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
