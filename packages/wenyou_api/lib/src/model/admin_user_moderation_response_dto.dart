//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_user_sanction_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_user_moderation_response_dto.g.dart';

/// AdminUserModerationResponseDto
///
/// Properties:
/// * [id]
/// * [email]
/// * [username]
/// * [role]
/// * [emailVerified]
/// * [moderationStatus]
/// * [currentSanction]
/// * [createdAt]
@BuiltValue()
abstract class AdminUserModerationResponseDto implements Built<AdminUserModerationResponseDto, AdminUserModerationResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'role')
  AdminUserModerationResponseDtoRoleEnum get role;
  // enum roleEnum {  USER,  ADMIN,  SUPER_ADMIN,  };

  @BuiltValueField(wireName: r'emailVerified')
  bool get emailVerified;

  @BuiltValueField(wireName: r'moderationStatus')
  AdminUserModerationResponseDtoModerationStatusEnum get moderationStatus;
  // enum moderationStatusEnum {  ACTIVE,  SUSPENDED,  BANNED,  };

  @BuiltValueField(wireName: r'currentSanction')
  AdminUserSanctionResponseDto? get currentSanction;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  AdminUserModerationResponseDto._();

  factory AdminUserModerationResponseDto([void updates(AdminUserModerationResponseDtoBuilder b)]) = _$AdminUserModerationResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUserModerationResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUserModerationResponseDto> get serializer => _$AdminUserModerationResponseDtoSerializer();
}

class _$AdminUserModerationResponseDtoSerializer implements PrimitiveSerializer<AdminUserModerationResponseDto> {
  @override
  final Iterable<Type> types = const [AdminUserModerationResponseDto, _$AdminUserModerationResponseDto];

  @override
  final String wireName = r'AdminUserModerationResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUserModerationResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
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
      specifiedType: const FullType(AdminUserModerationResponseDtoRoleEnum),
    );
    yield r'emailVerified';
    yield serializers.serialize(
      object.emailVerified,
      specifiedType: const FullType(bool),
    );
    yield r'moderationStatus';
    yield serializers.serialize(
      object.moderationStatus,
      specifiedType: const FullType(AdminUserModerationResponseDtoModerationStatusEnum),
    );
    if (object.currentSanction != null) {
      yield r'currentSanction';
      yield serializers.serialize(
        object.currentSanction,
        specifiedType: const FullType.nullable(AdminUserSanctionResponseDto),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminUserModerationResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUserModerationResponseDtoBuilder result,
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
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
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
            specifiedType: const FullType(AdminUserModerationResponseDtoRoleEnum),
          ) as AdminUserModerationResponseDtoRoleEnum;
          result.role = valueDes;
          break;
        case r'emailVerified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.emailVerified = valueDes;
          break;
        case r'moderationStatus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUserModerationResponseDtoModerationStatusEnum),
          ) as AdminUserModerationResponseDtoModerationStatusEnum;
          result.moderationStatus = valueDes;
          break;
        case r'currentSanction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(AdminUserSanctionResponseDto),
          ) as AdminUserSanctionResponseDto?;
          if (valueDes == null) continue;
          result.currentSanction.replace(valueDes);
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
  AdminUserModerationResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUserModerationResponseDtoBuilder();
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

class AdminUserModerationResponseDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const AdminUserModerationResponseDtoRoleEnum USER = _$adminUserModerationResponseDtoRoleEnum_USER;
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const AdminUserModerationResponseDtoRoleEnum ADMIN = _$adminUserModerationResponseDtoRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN')
  static const AdminUserModerationResponseDtoRoleEnum SUPER_ADMIN = _$adminUserModerationResponseDtoRoleEnum_SUPER_ADMIN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminUserModerationResponseDtoRoleEnum unknownDefaultOpenApi = _$adminUserModerationResponseDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<AdminUserModerationResponseDtoRoleEnum> get serializer => _$adminUserModerationResponseDtoRoleEnumSerializer;

  const AdminUserModerationResponseDtoRoleEnum._(String name): super(name);

  static BuiltSet<AdminUserModerationResponseDtoRoleEnum> get values => _$adminUserModerationResponseDtoRoleEnumValues;
  static AdminUserModerationResponseDtoRoleEnum valueOf(String name) => _$adminUserModerationResponseDtoRoleEnumValueOf(name);
}

class AdminUserModerationResponseDtoModerationStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ACTIVE')
  static const AdminUserModerationResponseDtoModerationStatusEnum ACTIVE = _$adminUserModerationResponseDtoModerationStatusEnum_ACTIVE;
  @BuiltValueEnumConst(wireName: r'SUSPENDED')
  static const AdminUserModerationResponseDtoModerationStatusEnum SUSPENDED = _$adminUserModerationResponseDtoModerationStatusEnum_SUSPENDED;
  @BuiltValueEnumConst(wireName: r'BANNED')
  static const AdminUserModerationResponseDtoModerationStatusEnum BANNED = _$adminUserModerationResponseDtoModerationStatusEnum_BANNED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminUserModerationResponseDtoModerationStatusEnum unknownDefaultOpenApi = _$adminUserModerationResponseDtoModerationStatusEnum_unknownDefaultOpenApi;

  static Serializer<AdminUserModerationResponseDtoModerationStatusEnum> get serializer => _$adminUserModerationResponseDtoModerationStatusEnumSerializer;

  const AdminUserModerationResponseDtoModerationStatusEnum._(String name): super(name);

  static BuiltSet<AdminUserModerationResponseDtoModerationStatusEnum> get values => _$adminUserModerationResponseDtoModerationStatusEnumValues;
  static AdminUserModerationResponseDtoModerationStatusEnum valueOf(String name) => _$adminUserModerationResponseDtoModerationStatusEnumValueOf(name);
}
