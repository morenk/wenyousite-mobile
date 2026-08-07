//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_like_response_dto.g.dart';

/// ThreadLikeResponseDto
///
/// Properties:
/// * [id]
/// * [likeCount]
@BuiltValue()
abstract class ThreadLikeResponseDto implements Built<ThreadLikeResponseDto, ThreadLikeResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'likeCount')
  num get likeCount;

  ThreadLikeResponseDto._();

  factory ThreadLikeResponseDto([void updates(ThreadLikeResponseDtoBuilder b)]) = _$ThreadLikeResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadLikeResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadLikeResponseDto> get serializer => _$ThreadLikeResponseDtoSerializer();
}

class _$ThreadLikeResponseDtoSerializer implements PrimitiveSerializer<ThreadLikeResponseDto> {
  @override
  final Iterable<Type> types = const [ThreadLikeResponseDto, _$ThreadLikeResponseDto];

  @override
  final String wireName = r'ThreadLikeResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadLikeResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'likeCount';
    yield serializers.serialize(
      object.likeCount,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadLikeResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadLikeResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'likeCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.likeCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadLikeResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadLikeResponseDtoBuilder();
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
