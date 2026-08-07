//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_count_response_dto.g.dart';

/// ThreadCountResponseDto
///
/// Properties:
/// * [members]
/// * [posts]
/// * [players]
@BuiltValue()
abstract class ThreadCountResponseDto implements Built<ThreadCountResponseDto, ThreadCountResponseDtoBuilder> {
  @BuiltValueField(wireName: r'members')
  num get members;

  @BuiltValueField(wireName: r'posts')
  num get posts;

  @BuiltValueField(wireName: r'players')
  num get players;

  ThreadCountResponseDto._();

  factory ThreadCountResponseDto([void updates(ThreadCountResponseDtoBuilder b)]) = _$ThreadCountResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadCountResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadCountResponseDto> get serializer => _$ThreadCountResponseDtoSerializer();
}

class _$ThreadCountResponseDtoSerializer implements PrimitiveSerializer<ThreadCountResponseDto> {
  @override
  final Iterable<Type> types = const [ThreadCountResponseDto, _$ThreadCountResponseDto];

  @override
  final String wireName = r'ThreadCountResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'members';
    yield serializers.serialize(
      object.members,
      specifiedType: const FullType(num),
    );
    yield r'posts';
    yield serializers.serialize(
      object.posts,
      specifiedType: const FullType(num),
    );
    yield r'players';
    yield serializers.serialize(
      object.players,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadCountResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'members':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.members = valueDes;
          break;
        case r'posts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.posts = valueDes;
          break;
        case r'players':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.players = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadCountResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadCountResponseDtoBuilder();
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
