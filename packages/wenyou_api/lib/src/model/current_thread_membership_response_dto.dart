//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'current_thread_membership_response_dto.g.dart';

/// CurrentThreadMembershipResponseDto
///
/// Properties:
/// * [id]
/// * [userId]
/// * [role]
/// * [playerMarked]
@BuiltValue()
abstract class CurrentThreadMembershipResponseDto implements Built<CurrentThreadMembershipResponseDto, CurrentThreadMembershipResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'role')
  CurrentThreadMembershipResponseDtoRoleEnum get role;
  // enum roleEnum {  OWNER,  COLLABORATOR,  PARTICIPANT,  };

  @BuiltValueField(wireName: r'playerMarked')
  bool get playerMarked;

  CurrentThreadMembershipResponseDto._();

  factory CurrentThreadMembershipResponseDto([void updates(CurrentThreadMembershipResponseDtoBuilder b)]) = _$CurrentThreadMembershipResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CurrentThreadMembershipResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CurrentThreadMembershipResponseDto> get serializer => _$CurrentThreadMembershipResponseDtoSerializer();
}

class _$CurrentThreadMembershipResponseDtoSerializer implements PrimitiveSerializer<CurrentThreadMembershipResponseDto> {
  @override
  final Iterable<Type> types = const [CurrentThreadMembershipResponseDto, _$CurrentThreadMembershipResponseDto];

  @override
  final String wireName = r'CurrentThreadMembershipResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CurrentThreadMembershipResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(CurrentThreadMembershipResponseDtoRoleEnum),
    );
    yield r'playerMarked';
    yield serializers.serialize(
      object.playerMarked,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CurrentThreadMembershipResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CurrentThreadMembershipResponseDtoBuilder result,
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
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CurrentThreadMembershipResponseDtoRoleEnum),
          ) as CurrentThreadMembershipResponseDtoRoleEnum;
          result.role = valueDes;
          break;
        case r'playerMarked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.playerMarked = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CurrentThreadMembershipResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CurrentThreadMembershipResponseDtoBuilder();
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

class CurrentThreadMembershipResponseDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OWNER')
  static const CurrentThreadMembershipResponseDtoRoleEnum OWNER = _$currentThreadMembershipResponseDtoRoleEnum_OWNER;
  @BuiltValueEnumConst(wireName: r'COLLABORATOR')
  static const CurrentThreadMembershipResponseDtoRoleEnum COLLABORATOR = _$currentThreadMembershipResponseDtoRoleEnum_COLLABORATOR;
  @BuiltValueEnumConst(wireName: r'PARTICIPANT')
  static const CurrentThreadMembershipResponseDtoRoleEnum PARTICIPANT = _$currentThreadMembershipResponseDtoRoleEnum_PARTICIPANT;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CurrentThreadMembershipResponseDtoRoleEnum unknownDefaultOpenApi = _$currentThreadMembershipResponseDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<CurrentThreadMembershipResponseDtoRoleEnum> get serializer => _$currentThreadMembershipResponseDtoRoleEnumSerializer;

  const CurrentThreadMembershipResponseDtoRoleEnum._(String name): super(name);

  static BuiltSet<CurrentThreadMembershipResponseDtoRoleEnum> get values => _$currentThreadMembershipResponseDtoRoleEnumValues;
  static CurrentThreadMembershipResponseDtoRoleEnum valueOf(String name) => _$currentThreadMembershipResponseDtoRoleEnumValueOf(name);
}
