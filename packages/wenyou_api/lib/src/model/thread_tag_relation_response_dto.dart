//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/thread_tag_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_tag_relation_response_dto.g.dart';

/// ThreadTagRelationResponseDto
///
/// Properties:
/// * [id]
/// * [threadId]
/// * [tagId]
/// * [tag]
@BuiltValue()
abstract class ThreadTagRelationResponseDto implements Built<ThreadTagRelationResponseDto, ThreadTagRelationResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  @BuiltValueField(wireName: r'tagId')
  String get tagId;

  @BuiltValueField(wireName: r'tag')
  ThreadTagResponseDto get tag;

  ThreadTagRelationResponseDto._();

  factory ThreadTagRelationResponseDto([void updates(ThreadTagRelationResponseDtoBuilder b)]) = _$ThreadTagRelationResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadTagRelationResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadTagRelationResponseDto> get serializer => _$ThreadTagRelationResponseDtoSerializer();
}

class _$ThreadTagRelationResponseDtoSerializer implements PrimitiveSerializer<ThreadTagRelationResponseDto> {
  @override
  final Iterable<Type> types = const [ThreadTagRelationResponseDto, _$ThreadTagRelationResponseDto];

  @override
  final String wireName = r'ThreadTagRelationResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadTagRelationResponseDto object, {
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
    yield r'tagId';
    yield serializers.serialize(
      object.tagId,
      specifiedType: const FullType(String),
    );
    yield r'tag';
    yield serializers.serialize(
      object.tag,
      specifiedType: const FullType(ThreadTagResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadTagRelationResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadTagRelationResponseDtoBuilder result,
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
        case r'tagId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tagId = valueDes;
          break;
        case r'tag':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadTagResponseDto),
          ) as ThreadTagResponseDto;
          result.tag.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadTagRelationResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadTagRelationResponseDtoBuilder();
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
