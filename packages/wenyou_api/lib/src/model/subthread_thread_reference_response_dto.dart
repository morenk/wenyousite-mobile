//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subthread_thread_reference_response_dto.g.dart';

/// SubthreadThreadReferenceResponseDto
///
/// Properties:
/// * [id]
/// * [title]
/// * [ownerId]
/// * [visibility]
@BuiltValue()
abstract class SubthreadThreadReferenceResponseDto implements Built<SubthreadThreadReferenceResponseDto, SubthreadThreadReferenceResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'ownerId')
  String get ownerId;

  @BuiltValueField(wireName: r'visibility')
  SubthreadThreadReferenceResponseDtoVisibilityEnum get visibility;
  // enum visibilityEnum {  PUBLIC,  PRIVATE,  };

  SubthreadThreadReferenceResponseDto._();

  factory SubthreadThreadReferenceResponseDto([void updates(SubthreadThreadReferenceResponseDtoBuilder b)]) = _$SubthreadThreadReferenceResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubthreadThreadReferenceResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubthreadThreadReferenceResponseDto> get serializer => _$SubthreadThreadReferenceResponseDtoSerializer();
}

class _$SubthreadThreadReferenceResponseDtoSerializer implements PrimitiveSerializer<SubthreadThreadReferenceResponseDto> {
  @override
  final Iterable<Type> types = const [SubthreadThreadReferenceResponseDto, _$SubthreadThreadReferenceResponseDto];

  @override
  final String wireName = r'SubthreadThreadReferenceResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubthreadThreadReferenceResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield object.title == null ? null : serializers.serialize(
      object.title,
      specifiedType: const FullType.nullable(String),
    );
    yield r'ownerId';
    yield serializers.serialize(
      object.ownerId,
      specifiedType: const FullType(String),
    );
    yield r'visibility';
    yield serializers.serialize(
      object.visibility,
      specifiedType: const FullType(SubthreadThreadReferenceResponseDtoVisibilityEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SubthreadThreadReferenceResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubthreadThreadReferenceResponseDtoBuilder result,
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.title = valueDes;
          break;
        case r'ownerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ownerId = valueDes;
          break;
        case r'visibility':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SubthreadThreadReferenceResponseDtoVisibilityEnum),
          ) as SubthreadThreadReferenceResponseDtoVisibilityEnum;
          result.visibility = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SubthreadThreadReferenceResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubthreadThreadReferenceResponseDtoBuilder();
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

class SubthreadThreadReferenceResponseDtoVisibilityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PUBLIC')
  static const SubthreadThreadReferenceResponseDtoVisibilityEnum PUBLIC = _$subthreadThreadReferenceResponseDtoVisibilityEnum_PUBLIC;
  @BuiltValueEnumConst(wireName: r'PRIVATE')
  static const SubthreadThreadReferenceResponseDtoVisibilityEnum PRIVATE = _$subthreadThreadReferenceResponseDtoVisibilityEnum_PRIVATE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const SubthreadThreadReferenceResponseDtoVisibilityEnum unknownDefaultOpenApi = _$subthreadThreadReferenceResponseDtoVisibilityEnum_unknownDefaultOpenApi;

  static Serializer<SubthreadThreadReferenceResponseDtoVisibilityEnum> get serializer => _$subthreadThreadReferenceResponseDtoVisibilityEnumSerializer;

  const SubthreadThreadReferenceResponseDtoVisibilityEnum._(String name): super(name);

  static BuiltSet<SubthreadThreadReferenceResponseDtoVisibilityEnum> get values => _$subthreadThreadReferenceResponseDtoVisibilityEnumValues;
  static SubthreadThreadReferenceResponseDtoVisibilityEnum valueOf(String name) => _$subthreadThreadReferenceResponseDtoVisibilityEnumValueOf(name);
}
