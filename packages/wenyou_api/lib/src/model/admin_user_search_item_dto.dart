//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_user_search_item_dto.g.dart';

/// AdminUserSearchItemDto
///
/// Properties:
/// * [id]
/// * [username]
/// * [email]
/// * [role]
/// * [emailVerified]
/// * [createdAt]
@BuiltValue()
abstract class AdminUserSearchItemDto implements Built<AdminUserSearchItemDto, AdminUserSearchItemDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'role')
  AdminUserSearchItemDtoRoleEnum get role;
  // enum roleEnum {  USER,  ADMIN,  SUPER_ADMIN,  };

  @BuiltValueField(wireName: r'emailVerified')
  bool get emailVerified;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  AdminUserSearchItemDto._();

  factory AdminUserSearchItemDto([void updates(AdminUserSearchItemDtoBuilder b)]) = _$AdminUserSearchItemDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUserSearchItemDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUserSearchItemDto> get serializer => _$AdminUserSearchItemDtoSerializer();
}

class _$AdminUserSearchItemDtoSerializer implements PrimitiveSerializer<AdminUserSearchItemDto> {
  @override
  final Iterable<Type> types = const [AdminUserSearchItemDto, _$AdminUserSearchItemDto];

  @override
  final String wireName = r'AdminUserSearchItemDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUserSearchItemDto object, {
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
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(AdminUserSearchItemDtoRoleEnum),
    );
    yield r'emailVerified';
    yield serializers.serialize(
      object.emailVerified,
      specifiedType: const FullType(bool),
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
    AdminUserSearchItemDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUserSearchItemDtoBuilder result,
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
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUserSearchItemDtoRoleEnum),
          ) as AdminUserSearchItemDtoRoleEnum;
          result.role = valueDes;
          break;
        case r'emailVerified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.emailVerified = valueDes;
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
  AdminUserSearchItemDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUserSearchItemDtoBuilder();
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

class AdminUserSearchItemDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const AdminUserSearchItemDtoRoleEnum USER = _$adminUserSearchItemDtoRoleEnum_USER;
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const AdminUserSearchItemDtoRoleEnum ADMIN = _$adminUserSearchItemDtoRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN')
  static const AdminUserSearchItemDtoRoleEnum SUPER_ADMIN = _$adminUserSearchItemDtoRoleEnum_SUPER_ADMIN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminUserSearchItemDtoRoleEnum unknownDefaultOpenApi = _$adminUserSearchItemDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<AdminUserSearchItemDtoRoleEnum> get serializer => _$adminUserSearchItemDtoRoleEnumSerializer;

  const AdminUserSearchItemDtoRoleEnum._(String name): super(name);

  static BuiltSet<AdminUserSearchItemDtoRoleEnum> get values => _$adminUserSearchItemDtoRoleEnumValues;
  static AdminUserSearchItemDtoRoleEnum valueOf(String name) => _$adminUserSearchItemDtoRoleEnumValueOf(name);
}
