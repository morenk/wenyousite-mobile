//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_content_moderation_response_dto.g.dart';

/// AdminContentModerationResponseDto
///
/// Properties:
/// * [targetType]
/// * [targetId]
/// * [hidden]
/// * [deletedAt]
@BuiltValue()
abstract class AdminContentModerationResponseDto implements Built<AdminContentModerationResponseDto, AdminContentModerationResponseDtoBuilder> {
  @BuiltValueField(wireName: r'targetType')
  AdminContentModerationResponseDtoTargetTypeEnum get targetType;
  // enum targetTypeEnum {  THREAD,  POST,  MOMENT,  MOMENT_COMMENT,  };

  @BuiltValueField(wireName: r'targetId')
  String get targetId;

  @BuiltValueField(wireName: r'hidden')
  bool get hidden;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime? get deletedAt;

  AdminContentModerationResponseDto._();

  factory AdminContentModerationResponseDto([void updates(AdminContentModerationResponseDtoBuilder b)]) = _$AdminContentModerationResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminContentModerationResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminContentModerationResponseDto> get serializer => _$AdminContentModerationResponseDtoSerializer();
}

class _$AdminContentModerationResponseDtoSerializer implements PrimitiveSerializer<AdminContentModerationResponseDto> {
  @override
  final Iterable<Type> types = const [AdminContentModerationResponseDto, _$AdminContentModerationResponseDto];

  @override
  final String wireName = r'AdminContentModerationResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminContentModerationResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'targetType';
    yield serializers.serialize(
      object.targetType,
      specifiedType: const FullType(AdminContentModerationResponseDtoTargetTypeEnum),
    );
    yield r'targetId';
    yield serializers.serialize(
      object.targetId,
      specifiedType: const FullType(String),
    );
    yield r'hidden';
    yield serializers.serialize(
      object.hidden,
      specifiedType: const FullType(bool),
    );
    yield r'deletedAt';
    yield object.deletedAt == null ? null : serializers.serialize(
      object.deletedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminContentModerationResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminContentModerationResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'targetType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminContentModerationResponseDtoTargetTypeEnum),
          ) as AdminContentModerationResponseDtoTargetTypeEnum;
          result.targetType = valueDes;
          break;
        case r'targetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetId = valueDes;
          break;
        case r'hidden':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hidden = valueDes;
          break;
        case r'deletedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminContentModerationResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminContentModerationResponseDtoBuilder();
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

class AdminContentModerationResponseDtoTargetTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'THREAD')
  static const AdminContentModerationResponseDtoTargetTypeEnum THREAD = _$adminContentModerationResponseDtoTargetTypeEnum_THREAD;
  @BuiltValueEnumConst(wireName: r'POST')
  static const AdminContentModerationResponseDtoTargetTypeEnum POST = _$adminContentModerationResponseDtoTargetTypeEnum_POST;
  @BuiltValueEnumConst(wireName: r'MOMENT')
  static const AdminContentModerationResponseDtoTargetTypeEnum MOMENT = _$adminContentModerationResponseDtoTargetTypeEnum_MOMENT;
  @BuiltValueEnumConst(wireName: r'MOMENT_COMMENT')
  static const AdminContentModerationResponseDtoTargetTypeEnum MOMENT_COMMENT = _$adminContentModerationResponseDtoTargetTypeEnum_MOMENT_COMMENT;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminContentModerationResponseDtoTargetTypeEnum unknownDefaultOpenApi = _$adminContentModerationResponseDtoTargetTypeEnum_unknownDefaultOpenApi;

  static Serializer<AdminContentModerationResponseDtoTargetTypeEnum> get serializer => _$adminContentModerationResponseDtoTargetTypeEnumSerializer;

  const AdminContentModerationResponseDtoTargetTypeEnum._(String name): super(name);

  static BuiltSet<AdminContentModerationResponseDtoTargetTypeEnum> get values => _$adminContentModerationResponseDtoTargetTypeEnumValues;
  static AdminContentModerationResponseDtoTargetTypeEnum valueOf(String name) => _$adminContentModerationResponseDtoTargetTypeEnumValueOf(name);
}
