//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'private_user_response_dto.g.dart';

/// PrivateUserResponseDto
///
/// Properties:
/// * [id]
/// * [email]
/// * [username]
/// * [avatar]
/// * [bio]
/// * [role]
/// * [showRecentReplies]
/// * [showPlayerBadges]
/// * [showBookmarks]
/// * [emailVerified]
/// * [deletedAt]
/// * [createdAt]
/// * [updatedAt]
@BuiltValue()
abstract class PrivateUserResponseDto implements Built<PrivateUserResponseDto, PrivateUserResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  @BuiltValueField(wireName: r'bio')
  String? get bio;

  @BuiltValueField(wireName: r'role')
  PrivateUserResponseDtoRoleEnum get role;
  // enum roleEnum {  USER,  ADMIN,  SUPER_ADMIN,  };

  @BuiltValueField(wireName: r'showRecentReplies')
  bool get showRecentReplies;

  @BuiltValueField(wireName: r'showPlayerBadges')
  bool get showPlayerBadges;

  @BuiltValueField(wireName: r'showBookmarks')
  bool get showBookmarks;

  @BuiltValueField(wireName: r'emailVerified')
  bool get emailVerified;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  PrivateUserResponseDto._();

  factory PrivateUserResponseDto([void updates(PrivateUserResponseDtoBuilder b)]) = _$PrivateUserResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrivateUserResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrivateUserResponseDto> get serializer => _$PrivateUserResponseDtoSerializer();
}

class _$PrivateUserResponseDtoSerializer implements PrimitiveSerializer<PrivateUserResponseDto> {
  @override
  final Iterable<Type> types = const [PrivateUserResponseDto, _$PrivateUserResponseDto];

  @override
  final String wireName = r'PrivateUserResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrivateUserResponseDto object, {
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
    yield r'avatar';
    yield object.avatar == null ? null : serializers.serialize(
      object.avatar,
      specifiedType: const FullType.nullable(String),
    );
    yield r'bio';
    yield object.bio == null ? null : serializers.serialize(
      object.bio,
      specifiedType: const FullType.nullable(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(PrivateUserResponseDtoRoleEnum),
    );
    yield r'showRecentReplies';
    yield serializers.serialize(
      object.showRecentReplies,
      specifiedType: const FullType(bool),
    );
    yield r'showPlayerBadges';
    yield serializers.serialize(
      object.showPlayerBadges,
      specifiedType: const FullType(bool),
    );
    yield r'showBookmarks';
    yield serializers.serialize(
      object.showBookmarks,
      specifiedType: const FullType(bool),
    );
    yield r'emailVerified';
    yield serializers.serialize(
      object.emailVerified,
      specifiedType: const FullType(bool),
    );
    yield r'deletedAt';
    yield object.deletedAt == null ? null : serializers.serialize(
      object.deletedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrivateUserResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PrivateUserResponseDtoBuilder result,
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
        case r'avatar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatar = valueDes;
          break;
        case r'bio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bio = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrivateUserResponseDtoRoleEnum),
          ) as PrivateUserResponseDtoRoleEnum;
          result.role = valueDes;
          break;
        case r'showRecentReplies':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.showRecentReplies = valueDes;
          break;
        case r'showPlayerBadges':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.showPlayerBadges = valueDes;
          break;
        case r'showBookmarks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.showBookmarks = valueDes;
          break;
        case r'emailVerified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.emailVerified = valueDes;
          break;
        case r'deletedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrivateUserResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrivateUserResponseDtoBuilder();
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

class PrivateUserResponseDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const PrivateUserResponseDtoRoleEnum USER = _$privateUserResponseDtoRoleEnum_USER;
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const PrivateUserResponseDtoRoleEnum ADMIN = _$privateUserResponseDtoRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN')
  static const PrivateUserResponseDtoRoleEnum SUPER_ADMIN = _$privateUserResponseDtoRoleEnum_SUPER_ADMIN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const PrivateUserResponseDtoRoleEnum unknownDefaultOpenApi = _$privateUserResponseDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<PrivateUserResponseDtoRoleEnum> get serializer => _$privateUserResponseDtoRoleEnumSerializer;

  const PrivateUserResponseDtoRoleEnum._(String name): super(name);

  static BuiltSet<PrivateUserResponseDtoRoleEnum> get values => _$privateUserResponseDtoRoleEnumValues;
  static PrivateUserResponseDtoRoleEnum valueOf(String name) => _$privateUserResponseDtoRoleEnumValueOf(name);
}
