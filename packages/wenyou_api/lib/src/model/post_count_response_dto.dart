//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_count_response_dto.g.dart';

/// PostCountResponseDto
///
/// Properties:
/// * [replies]
@BuiltValue()
abstract class PostCountResponseDto implements Built<PostCountResponseDto, PostCountResponseDtoBuilder> {
  @BuiltValueField(wireName: r'replies')
  num get replies;

  PostCountResponseDto._();

  factory PostCountResponseDto([void updates(PostCountResponseDtoBuilder b)]) = _$PostCountResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostCountResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostCountResponseDto> get serializer => _$PostCountResponseDtoSerializer();
}

class _$PostCountResponseDtoSerializer implements PrimitiveSerializer<PostCountResponseDto> {
  @override
  final Iterable<Type> types = const [PostCountResponseDto, _$PostCountResponseDto];

  @override
  final String wireName = r'PostCountResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'replies';
    yield serializers.serialize(
      object.replies,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostCountResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'replies':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.replies = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostCountResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostCountResponseDtoBuilder();
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
