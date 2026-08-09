//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_user_sanction_response_dto.g.dart';

/// AdminUserSanctionResponseDto
///
/// Properties:
/// * [id]
/// * [type]
/// * [reason]
/// * [startsAt]
/// * [endsAt]
/// * [reportId]
@BuiltValue()
abstract class AdminUserSanctionResponseDto implements Built<AdminUserSanctionResponseDto, AdminUserSanctionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'type')
  AdminUserSanctionResponseDtoTypeEnum get type;
  // enum typeEnum {  SUSPENSION,  BAN,  };

  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'startsAt')
  DateTime get startsAt;

  @BuiltValueField(wireName: r'endsAt')
  DateTime? get endsAt;

  @BuiltValueField(wireName: r'reportId')
  String? get reportId;

  AdminUserSanctionResponseDto._();

  factory AdminUserSanctionResponseDto([void updates(AdminUserSanctionResponseDtoBuilder b)]) = _$AdminUserSanctionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUserSanctionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUserSanctionResponseDto> get serializer => _$AdminUserSanctionResponseDtoSerializer();
}

class _$AdminUserSanctionResponseDtoSerializer implements PrimitiveSerializer<AdminUserSanctionResponseDto> {
  @override
  final Iterable<Type> types = const [AdminUserSanctionResponseDto, _$AdminUserSanctionResponseDto];

  @override
  final String wireName = r'AdminUserSanctionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUserSanctionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(AdminUserSanctionResponseDtoTypeEnum),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    yield r'startsAt';
    yield serializers.serialize(
      object.startsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'endsAt';
    yield object.endsAt == null ? null : serializers.serialize(
      object.endsAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'reportId';
    yield object.reportId == null ? null : serializers.serialize(
      object.reportId,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminUserSanctionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUserSanctionResponseDtoBuilder result,
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
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUserSanctionResponseDtoTypeEnum),
          ) as AdminUserSanctionResponseDtoTypeEnum;
          result.type = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'startsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startsAt = valueDes;
          break;
        case r'endsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endsAt = valueDes;
          break;
        case r'reportId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reportId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminUserSanctionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUserSanctionResponseDtoBuilder();
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

class AdminUserSanctionResponseDtoTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SUSPENSION')
  static const AdminUserSanctionResponseDtoTypeEnum SUSPENSION = _$adminUserSanctionResponseDtoTypeEnum_SUSPENSION;
  @BuiltValueEnumConst(wireName: r'BAN')
  static const AdminUserSanctionResponseDtoTypeEnum BAN = _$adminUserSanctionResponseDtoTypeEnum_BAN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminUserSanctionResponseDtoTypeEnum unknownDefaultOpenApi = _$adminUserSanctionResponseDtoTypeEnum_unknownDefaultOpenApi;

  static Serializer<AdminUserSanctionResponseDtoTypeEnum> get serializer => _$adminUserSanctionResponseDtoTypeEnumSerializer;

  const AdminUserSanctionResponseDtoTypeEnum._(String name): super(name);

  static BuiltSet<AdminUserSanctionResponseDtoTypeEnum> get values => _$adminUserSanctionResponseDtoTypeEnumValues;
  static AdminUserSanctionResponseDtoTypeEnum valueOf(String name) => _$adminUserSanctionResponseDtoTypeEnumValueOf(name);
}
