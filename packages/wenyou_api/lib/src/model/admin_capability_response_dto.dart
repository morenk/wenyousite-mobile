//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_capability_response_dto.g.dart';

/// AdminCapabilityResponseDto
///
/// Properties:
/// * [role]
/// * [capabilities]
@BuiltValue()
abstract class AdminCapabilityResponseDto implements Built<AdminCapabilityResponseDto, AdminCapabilityResponseDtoBuilder> {
  @BuiltValueField(wireName: r'role')
  AdminCapabilityResponseDtoRoleEnum get role;
  // enum roleEnum {  ADMIN,  SUPER_ADMIN,  };

  @BuiltValueField(wireName: r'capabilities')
  BuiltList<String> get capabilities;

  AdminCapabilityResponseDto._();

  factory AdminCapabilityResponseDto([void updates(AdminCapabilityResponseDtoBuilder b)]) = _$AdminCapabilityResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminCapabilityResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminCapabilityResponseDto> get serializer => _$AdminCapabilityResponseDtoSerializer();
}

class _$AdminCapabilityResponseDtoSerializer implements PrimitiveSerializer<AdminCapabilityResponseDto> {
  @override
  final Iterable<Type> types = const [AdminCapabilityResponseDto, _$AdminCapabilityResponseDto];

  @override
  final String wireName = r'AdminCapabilityResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminCapabilityResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(AdminCapabilityResponseDtoRoleEnum),
    );
    yield r'capabilities';
    yield serializers.serialize(
      object.capabilities,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminCapabilityResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminCapabilityResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminCapabilityResponseDtoRoleEnum),
          ) as AdminCapabilityResponseDtoRoleEnum;
          result.role = valueDes;
          break;
        case r'capabilities':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.capabilities.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminCapabilityResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminCapabilityResponseDtoBuilder();
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

class AdminCapabilityResponseDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const AdminCapabilityResponseDtoRoleEnum ADMIN = _$adminCapabilityResponseDtoRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN')
  static const AdminCapabilityResponseDtoRoleEnum SUPER_ADMIN = _$adminCapabilityResponseDtoRoleEnum_SUPER_ADMIN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminCapabilityResponseDtoRoleEnum unknownDefaultOpenApi = _$adminCapabilityResponseDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<AdminCapabilityResponseDtoRoleEnum> get serializer => _$adminCapabilityResponseDtoRoleEnumSerializer;

  const AdminCapabilityResponseDtoRoleEnum._(String name): super(name);

  static BuiltSet<AdminCapabilityResponseDtoRoleEnum> get values => _$adminCapabilityResponseDtoRoleEnumValues;
  static AdminCapabilityResponseDtoRoleEnum valueOf(String name) => _$adminCapabilityResponseDtoRoleEnumValueOf(name);
}
