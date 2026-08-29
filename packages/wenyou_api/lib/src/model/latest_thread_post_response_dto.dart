//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'latest_thread_post_response_dto.g.dart';

/// LatestThreadPostResponseDto
///
/// Properties:
/// * [id]
/// * [threadId]
/// * [subthreadId]
/// * [parentPostId]
/// * [createdAt]
@BuiltValue()
abstract class LatestThreadPostResponseDto implements Built<LatestThreadPostResponseDto, LatestThreadPostResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  @BuiltValueField(wireName: r'subthreadId')
  String get subthreadId;

  @BuiltValueField(wireName: r'parentPostId')
  String? get parentPostId;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  LatestThreadPostResponseDto._();

  factory LatestThreadPostResponseDto([void updates(LatestThreadPostResponseDtoBuilder b)]) = _$LatestThreadPostResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LatestThreadPostResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LatestThreadPostResponseDto> get serializer => _$LatestThreadPostResponseDtoSerializer();
}

class _$LatestThreadPostResponseDtoSerializer implements PrimitiveSerializer<LatestThreadPostResponseDto> {
  @override
  final Iterable<Type> types = const [LatestThreadPostResponseDto, _$LatestThreadPostResponseDto];

  @override
  final String wireName = r'LatestThreadPostResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LatestThreadPostResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'threadId';
    yield serializers.serialize(
      object.threadId,
      specifiedType: const FullType(String),
    );
    yield r'subthreadId';
    yield serializers.serialize(
      object.subthreadId,
      specifiedType: const FullType(String),
    );
    yield r'parentPostId';
    yield object.parentPostId == null ? null : serializers.serialize(
      object.parentPostId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LatestThreadPostResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LatestThreadPostResponseDtoBuilder result,
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
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.threadId = valueDes;
          break;
        case r'subthreadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.subthreadId = valueDes;
          break;
        case r'parentPostId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentPostId = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LatestThreadPostResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LatestThreadPostResponseDtoBuilder();
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
