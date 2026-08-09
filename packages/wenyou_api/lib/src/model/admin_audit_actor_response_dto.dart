//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_audit_actor_response_dto.g.dart';

/// AdminAuditActorResponseDto
///
/// Properties:
/// * [id]
/// * [username]
/// * [role]
@BuiltValue()
abstract class AdminAuditActorResponseDto implements Built<AdminAuditActorResponseDto, AdminAuditActorResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'role')
  AdminAuditActorResponseDtoRoleEnum get role;
  // enum roleEnum {  USER,  ADMIN,  SUPER_ADMIN,  };

  AdminAuditActorResponseDto._();

  factory AdminAuditActorResponseDto([void updates(AdminAuditActorResponseDtoBuilder b)]) = _$AdminAuditActorResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAuditActorResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAuditActorResponseDto> get serializer => _$AdminAuditActorResponseDtoSerializer();
}

class _$AdminAuditActorResponseDtoSerializer implements PrimitiveSerializer<AdminAuditActorResponseDto> {
  @override
  final Iterable<Type> types = const [AdminAuditActorResponseDto, _$AdminAuditActorResponseDto];

  @override
  final String wireName = r'AdminAuditActorResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAuditActorResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(AdminAuditActorResponseDtoRoleEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminAuditActorResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAuditActorResponseDtoBuilder result,
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
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminAuditActorResponseDtoRoleEnum),
          ) as AdminAuditActorResponseDtoRoleEnum;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminAuditActorResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAuditActorResponseDtoBuilder();
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

class AdminAuditActorResponseDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const AdminAuditActorResponseDtoRoleEnum USER = _$adminAuditActorResponseDtoRoleEnum_USER;
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const AdminAuditActorResponseDtoRoleEnum ADMIN = _$adminAuditActorResponseDtoRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN')
  static const AdminAuditActorResponseDtoRoleEnum SUPER_ADMIN = _$adminAuditActorResponseDtoRoleEnum_SUPER_ADMIN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminAuditActorResponseDtoRoleEnum unknownDefaultOpenApi = _$adminAuditActorResponseDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<AdminAuditActorResponseDtoRoleEnum> get serializer => _$adminAuditActorResponseDtoRoleEnumSerializer;

  const AdminAuditActorResponseDtoRoleEnum._(String name): super(name);

  static BuiltSet<AdminAuditActorResponseDtoRoleEnum> get values => _$adminAuditActorResponseDtoRoleEnumValues;
  static AdminAuditActorResponseDtoRoleEnum valueOf(String name) => _$adminAuditActorResponseDtoRoleEnumValueOf(name);
}
