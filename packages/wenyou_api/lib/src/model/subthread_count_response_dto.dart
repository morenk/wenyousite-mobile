//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subthread_count_response_dto.g.dart';

/// SubthreadCountResponseDto
///
/// Properties:
/// * [posts]
@BuiltValue()
abstract class SubthreadCountResponseDto implements Built<SubthreadCountResponseDto, SubthreadCountResponseDtoBuilder> {
  @BuiltValueField(wireName: r'posts')
  num get posts;

  SubthreadCountResponseDto._();

  factory SubthreadCountResponseDto([void updates(SubthreadCountResponseDtoBuilder b)]) = _$SubthreadCountResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubthreadCountResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubthreadCountResponseDto> get serializer => _$SubthreadCountResponseDtoSerializer();
}

class _$SubthreadCountResponseDtoSerializer implements PrimitiveSerializer<SubthreadCountResponseDto> {
  @override
  final Iterable<Type> types = const [SubthreadCountResponseDto, _$SubthreadCountResponseDto];

  @override
  final String wireName = r'SubthreadCountResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubthreadCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'posts';
    yield serializers.serialize(
      object.posts,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SubthreadCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubthreadCountResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'posts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.posts = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SubthreadCountResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubthreadCountResponseDtoBuilder();
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
