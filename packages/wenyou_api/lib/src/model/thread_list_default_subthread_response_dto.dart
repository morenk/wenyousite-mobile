//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_list_default_subthread_response_dto.g.dart';

/// ThreadListDefaultSubthreadResponseDto
///
/// Properties:
/// * [id]
/// * [title]
/// * [lastPostAt]
@BuiltValue()
abstract class ThreadListDefaultSubthreadResponseDto implements Built<ThreadListDefaultSubthreadResponseDto, ThreadListDefaultSubthreadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'lastPostAt')
  DateTime? get lastPostAt;

  ThreadListDefaultSubthreadResponseDto._();

  factory ThreadListDefaultSubthreadResponseDto([void updates(ThreadListDefaultSubthreadResponseDtoBuilder b)]) = _$ThreadListDefaultSubthreadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadListDefaultSubthreadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadListDefaultSubthreadResponseDto> get serializer => _$ThreadListDefaultSubthreadResponseDtoSerializer();
}

class _$ThreadListDefaultSubthreadResponseDtoSerializer implements PrimitiveSerializer<ThreadListDefaultSubthreadResponseDto> {
  @override
  final Iterable<Type> types = const [ThreadListDefaultSubthreadResponseDto, _$ThreadListDefaultSubthreadResponseDto];

  @override
  final String wireName = r'ThreadListDefaultSubthreadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadListDefaultSubthreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'lastPostAt';
    yield object.lastPostAt == null ? null : serializers.serialize(
      object.lastPostAt,
      specifiedType: const FullType.nullable(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadListDefaultSubthreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadListDefaultSubthreadResponseDtoBuilder result,
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
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'lastPostAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastPostAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadListDefaultSubthreadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadListDefaultSubthreadResponseDtoBuilder();
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
