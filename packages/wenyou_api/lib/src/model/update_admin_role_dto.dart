//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_admin_role_dto.g.dart';

/// UpdateAdminRoleDto
///
/// Properties:
/// * [role]
/// * [reason]
@BuiltValue()
abstract class UpdateAdminRoleDto implements Built<UpdateAdminRoleDto, UpdateAdminRoleDtoBuilder> {
  @BuiltValueField(wireName: r'role')
  UpdateAdminRoleDtoRoleEnum get role;
  // enum roleEnum {  USER,  ADMIN,  };

  @BuiltValueField(wireName: r'reason')
  String get reason;

  UpdateAdminRoleDto._();

  factory UpdateAdminRoleDto([void updates(UpdateAdminRoleDtoBuilder b)]) = _$UpdateAdminRoleDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateAdminRoleDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateAdminRoleDto> get serializer => _$UpdateAdminRoleDtoSerializer();
}

class _$UpdateAdminRoleDtoSerializer implements PrimitiveSerializer<UpdateAdminRoleDto> {
  @override
  final Iterable<Type> types = const [UpdateAdminRoleDto, _$UpdateAdminRoleDto];

  @override
  final String wireName = r'UpdateAdminRoleDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateAdminRoleDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(UpdateAdminRoleDtoRoleEnum),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateAdminRoleDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateAdminRoleDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateAdminRoleDtoRoleEnum),
          ) as UpdateAdminRoleDtoRoleEnum;
          result.role = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateAdminRoleDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateAdminRoleDtoBuilder();
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

class UpdateAdminRoleDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const UpdateAdminRoleDtoRoleEnum USER = _$updateAdminRoleDtoRoleEnum_USER;
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const UpdateAdminRoleDtoRoleEnum ADMIN = _$updateAdminRoleDtoRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const UpdateAdminRoleDtoRoleEnum unknownDefaultOpenApi = _$updateAdminRoleDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<UpdateAdminRoleDtoRoleEnum> get serializer => _$updateAdminRoleDtoRoleEnumSerializer;

  const UpdateAdminRoleDtoRoleEnum._(String name): super(name);

  static BuiltSet<UpdateAdminRoleDtoRoleEnum> get values => _$updateAdminRoleDtoRoleEnumValues;
  static UpdateAdminRoleDtoRoleEnum valueOf(String name) => _$updateAdminRoleDtoRoleEnumValueOf(name);
}
