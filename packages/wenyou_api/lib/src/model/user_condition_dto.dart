//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_condition_dto.g.dart';

/// UserConditionDto
///
/// Properties:
/// * [role] - 角色筛选（USER / ADMIN / SUPER_ADMIN）
/// * [emailVerified] - 邮箱验证状态筛选
/// * [createdAfter] - 注册时间起始（ISO 8601）
/// * [createdBefore] - 注册时间截止（ISO 8601）
@BuiltValue()
abstract class UserConditionDto implements Built<UserConditionDto, UserConditionDtoBuilder> {
  /// 角色筛选（USER / ADMIN / SUPER_ADMIN）
  @BuiltValueField(wireName: r'role')
  BuiltList<UserConditionDtoRoleEnum>? get role;
  // enum roleEnum {  USER,  ADMIN,  SUPER_ADMIN,  };

  /// 邮箱验证状态筛选
  @BuiltValueField(wireName: r'emailVerified')
  bool? get emailVerified;

  /// 注册时间起始（ISO 8601）
  @BuiltValueField(wireName: r'createdAfter')
  String? get createdAfter;

  /// 注册时间截止（ISO 8601）
  @BuiltValueField(wireName: r'createdBefore')
  String? get createdBefore;

  UserConditionDto._();

  factory UserConditionDto([void updates(UserConditionDtoBuilder b)]) = _$UserConditionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserConditionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserConditionDto> get serializer => _$UserConditionDtoSerializer();
}

class _$UserConditionDtoSerializer implements PrimitiveSerializer<UserConditionDto> {
  @override
  final Iterable<Type> types = const [UserConditionDto, _$UserConditionDto];

  @override
  final String wireName = r'UserConditionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserConditionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(BuiltList, [FullType(UserConditionDtoRoleEnum)]),
      );
    }
    if (object.emailVerified != null) {
      yield r'emailVerified';
      yield serializers.serialize(
        object.emailVerified,
        specifiedType: const FullType(bool),
      );
    }
    if (object.createdAfter != null) {
      yield r'createdAfter';
      yield serializers.serialize(
        object.createdAfter,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdBefore != null) {
      yield r'createdBefore';
      yield serializers.serialize(
        object.createdBefore,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserConditionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserConditionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(UserConditionDtoRoleEnum)]),
          ) as BuiltList<UserConditionDtoRoleEnum>;
          result.role.replace(valueDes);
          break;
        case r'emailVerified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.emailVerified = valueDes;
          break;
        case r'createdAfter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.createdAfter = valueDes;
          break;
        case r'createdBefore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.createdBefore = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserConditionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserConditionDtoBuilder();
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

class UserConditionDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const UserConditionDtoRoleEnum USER = _$userConditionDtoRoleEnum_USER;
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const UserConditionDtoRoleEnum ADMIN = _$userConditionDtoRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN')
  static const UserConditionDtoRoleEnum SUPER_ADMIN = _$userConditionDtoRoleEnum_SUPER_ADMIN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const UserConditionDtoRoleEnum unknownDefaultOpenApi = _$userConditionDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<UserConditionDtoRoleEnum> get serializer => _$userConditionDtoRoleEnumSerializer;

  const UserConditionDtoRoleEnum._(String name): super(name);

  static BuiltSet<UserConditionDtoRoleEnum> get values => _$userConditionDtoRoleEnumValues;
  static UserConditionDtoRoleEnum valueOf(String name) => _$userConditionDtoRoleEnumValueOf(name);
}
