//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_user_sanction_response_dto.dart';
import 'package:wenyou_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_user_content_counts_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_user_detail_response_dto.g.dart';

/// AdminUserDetailResponseDto
///
/// Properties:
/// * [id]
/// * [email]
/// * [username]
/// * [role]
/// * [moderationStatus]
/// * [currentSanction]
/// * [createdAt]
/// * [bio]
/// * [level]
/// * [lastActiveDate]
/// * [contentCounts]
@BuiltValue()
abstract class AdminUserDetailResponseDto implements Built<AdminUserDetailResponseDto, AdminUserDetailResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'role')
  AdminUserDetailResponseDtoRoleEnum get role;
  // enum roleEnum {  USER,  ADMIN,  SUPER_ADMIN,  };

  @BuiltValueField(wireName: r'moderationStatus')
  AdminUserDetailResponseDtoModerationStatusEnum get moderationStatus;
  // enum moderationStatusEnum {  ACTIVE,  SUSPENDED,  BANNED,  };

  @BuiltValueField(wireName: r'currentSanction')
  AdminUserSanctionResponseDto? get currentSanction;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'bio')
  String? get bio;

  @BuiltValueField(wireName: r'level')
  num get level;

  @BuiltValueField(wireName: r'lastActiveDate')
  Date? get lastActiveDate;

  @BuiltValueField(wireName: r'contentCounts')
  AdminUserContentCountsDto get contentCounts;

  AdminUserDetailResponseDto._();

  factory AdminUserDetailResponseDto([void updates(AdminUserDetailResponseDtoBuilder b)]) = _$AdminUserDetailResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUserDetailResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUserDetailResponseDto> get serializer => _$AdminUserDetailResponseDtoSerializer();
}

class _$AdminUserDetailResponseDtoSerializer implements PrimitiveSerializer<AdminUserDetailResponseDto> {
  @override
  final Iterable<Type> types = const [AdminUserDetailResponseDto, _$AdminUserDetailResponseDto];

  @override
  final String wireName = r'AdminUserDetailResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUserDetailResponseDto object, {
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
      specifiedType: const FullType(AdminUserDetailResponseDtoRoleEnum),
    );
    yield r'moderationStatus';
    yield serializers.serialize(
      object.moderationStatus,
      specifiedType: const FullType(AdminUserDetailResponseDtoModerationStatusEnum),
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
    yield r'bio';
    yield object.bio == null ? null : serializers.serialize(
      object.bio,
      specifiedType: const FullType.nullable(String),
    );
    yield r'level';
    yield serializers.serialize(
      object.level,
      specifiedType: const FullType(num),
    );
    yield r'lastActiveDate';
    yield object.lastActiveDate == null ? null : serializers.serialize(
      object.lastActiveDate,
      specifiedType: const FullType.nullable(Date),
    );
    yield r'contentCounts';
    yield serializers.serialize(
      object.contentCounts,
      specifiedType: const FullType(AdminUserContentCountsDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminUserDetailResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUserDetailResponseDtoBuilder result,
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
            specifiedType: const FullType(AdminUserDetailResponseDtoRoleEnum),
          ) as AdminUserDetailResponseDtoRoleEnum;
          result.role = valueDes;
          break;
        case r'moderationStatus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUserDetailResponseDtoModerationStatusEnum),
          ) as AdminUserDetailResponseDtoModerationStatusEnum;
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
        case r'bio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bio = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.level = valueDes;
          break;
        case r'lastActiveDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.lastActiveDate = valueDes;
          break;
        case r'contentCounts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUserContentCountsDto),
          ) as AdminUserContentCountsDto;
          result.contentCounts.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminUserDetailResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUserDetailResponseDtoBuilder();
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

class AdminUserDetailResponseDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const AdminUserDetailResponseDtoRoleEnum USER = _$adminUserDetailResponseDtoRoleEnum_USER;
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const AdminUserDetailResponseDtoRoleEnum ADMIN = _$adminUserDetailResponseDtoRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN')
  static const AdminUserDetailResponseDtoRoleEnum SUPER_ADMIN = _$adminUserDetailResponseDtoRoleEnum_SUPER_ADMIN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminUserDetailResponseDtoRoleEnum unknownDefaultOpenApi = _$adminUserDetailResponseDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<AdminUserDetailResponseDtoRoleEnum> get serializer => _$adminUserDetailResponseDtoRoleEnumSerializer;

  const AdminUserDetailResponseDtoRoleEnum._(String name): super(name);

  static BuiltSet<AdminUserDetailResponseDtoRoleEnum> get values => _$adminUserDetailResponseDtoRoleEnumValues;
  static AdminUserDetailResponseDtoRoleEnum valueOf(String name) => _$adminUserDetailResponseDtoRoleEnumValueOf(name);
}

class AdminUserDetailResponseDtoModerationStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ACTIVE')
  static const AdminUserDetailResponseDtoModerationStatusEnum ACTIVE = _$adminUserDetailResponseDtoModerationStatusEnum_ACTIVE;
  @BuiltValueEnumConst(wireName: r'SUSPENDED')
  static const AdminUserDetailResponseDtoModerationStatusEnum SUSPENDED = _$adminUserDetailResponseDtoModerationStatusEnum_SUSPENDED;
  @BuiltValueEnumConst(wireName: r'BANNED')
  static const AdminUserDetailResponseDtoModerationStatusEnum BANNED = _$adminUserDetailResponseDtoModerationStatusEnum_BANNED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminUserDetailResponseDtoModerationStatusEnum unknownDefaultOpenApi = _$adminUserDetailResponseDtoModerationStatusEnum_unknownDefaultOpenApi;

  static Serializer<AdminUserDetailResponseDtoModerationStatusEnum> get serializer => _$adminUserDetailResponseDtoModerationStatusEnumSerializer;

  const AdminUserDetailResponseDtoModerationStatusEnum._(String name): super(name);

  static BuiltSet<AdminUserDetailResponseDtoModerationStatusEnum> get values => _$adminUserDetailResponseDtoModerationStatusEnumValues;
  static AdminUserDetailResponseDtoModerationStatusEnum valueOf(String name) => _$adminUserDetailResponseDtoModerationStatusEnumValueOf(name);
}
