//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_subthread_count_response_dto.g.dart';

/// ThreadSubthreadCountResponseDto
///
/// Properties:
/// * [posts]
@BuiltValue()
abstract class ThreadSubthreadCountResponseDto implements Built<ThreadSubthreadCountResponseDto, ThreadSubthreadCountResponseDtoBuilder> {
  @BuiltValueField(wireName: r'posts')
  num get posts;

  ThreadSubthreadCountResponseDto._();

  factory ThreadSubthreadCountResponseDto([void updates(ThreadSubthreadCountResponseDtoBuilder b)]) = _$ThreadSubthreadCountResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadSubthreadCountResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadSubthreadCountResponseDto> get serializer => _$ThreadSubthreadCountResponseDtoSerializer();
}

class _$ThreadSubthreadCountResponseDtoSerializer implements PrimitiveSerializer<ThreadSubthreadCountResponseDto> {
  @override
  final Iterable<Type> types = const [ThreadSubthreadCountResponseDto, _$ThreadSubthreadCountResponseDto];

  @override
  final String wireName = r'ThreadSubthreadCountResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadSubthreadCountResponseDto object, {
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
    ThreadSubthreadCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadSubthreadCountResponseDtoBuilder result,
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
  ThreadSubthreadCountResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadSubthreadCountResponseDtoBuilder();
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
