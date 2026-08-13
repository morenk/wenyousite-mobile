//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/profile_cover_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/user_social_count_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'current_user_response_dto.g.dart';

/// CurrentUserResponseDto
///
/// Properties:
/// * [id]
/// * [email]
/// * [username]
/// * [avatar]
/// * [profileCover]
/// * [bio]
/// * [role]
/// * [level]
/// * [experience]
/// * [currentLevelExperience]
/// * [nextLevelExperience]
/// * [receivedTipTotal]
/// * [receivedTipCount]
/// * [showRecentReplies]
/// * [showPlayerBadges]
/// * [showBookmarks]
/// * [emailVerified]
/// * [deletedAt]
/// * [createdAt]
/// * [updatedAt]
/// * [count]
@BuiltValue()
abstract class CurrentUserResponseDto implements Built<CurrentUserResponseDto, CurrentUserResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  @BuiltValueField(wireName: r'profileCover')
  ProfileCoverResponseDto? get profileCover;

  @BuiltValueField(wireName: r'bio')
  String? get bio;

  @BuiltValueField(wireName: r'role')
  CurrentUserResponseDtoRoleEnum get role;
  // enum roleEnum {  USER,  ADMIN,  SUPER_ADMIN,  };

  @BuiltValueField(wireName: r'level')
  num get level;

  @BuiltValueField(wireName: r'experience')
  num get experience;

  @BuiltValueField(wireName: r'currentLevelExperience')
  num get currentLevelExperience;

  @BuiltValueField(wireName: r'nextLevelExperience')
  num? get nextLevelExperience;

  @BuiltValueField(wireName: r'receivedTipTotal')
  String get receivedTipTotal;

  @BuiltValueField(wireName: r'receivedTipCount')
  num get receivedTipCount;

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

  @BuiltValueField(wireName: r'_count')
  UserSocialCountResponseDto get count;

  CurrentUserResponseDto._();

  factory CurrentUserResponseDto([void updates(CurrentUserResponseDtoBuilder b)]) = _$CurrentUserResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CurrentUserResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CurrentUserResponseDto> get serializer => _$CurrentUserResponseDtoSerializer();
}

class _$CurrentUserResponseDtoSerializer implements PrimitiveSerializer<CurrentUserResponseDto> {
  @override
  final Iterable<Type> types = const [CurrentUserResponseDto, _$CurrentUserResponseDto];

  @override
  final String wireName = r'CurrentUserResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CurrentUserResponseDto object, {
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
    yield r'profileCover';
    yield object.profileCover == null ? null : serializers.serialize(
      object.profileCover,
      specifiedType: const FullType.nullable(ProfileCoverResponseDto),
    );
    yield r'bio';
    yield object.bio == null ? null : serializers.serialize(
      object.bio,
      specifiedType: const FullType.nullable(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(CurrentUserResponseDtoRoleEnum),
    );
    yield r'level';
    yield serializers.serialize(
      object.level,
      specifiedType: const FullType(num),
    );
    yield r'experience';
    yield serializers.serialize(
      object.experience,
      specifiedType: const FullType(num),
    );
    yield r'currentLevelExperience';
    yield serializers.serialize(
      object.currentLevelExperience,
      specifiedType: const FullType(num),
    );
    yield r'nextLevelExperience';
    yield object.nextLevelExperience == null ? null : serializers.serialize(
      object.nextLevelExperience,
      specifiedType: const FullType.nullable(num),
    );
    yield r'receivedTipTotal';
    yield serializers.serialize(
      object.receivedTipTotal,
      specifiedType: const FullType(String),
    );
    yield r'receivedTipCount';
    yield serializers.serialize(
      object.receivedTipCount,
      specifiedType: const FullType(num),
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
    yield r'_count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(UserSocialCountResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CurrentUserResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CurrentUserResponseDtoBuilder result,
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
        case r'profileCover':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ProfileCoverResponseDto),
          ) as ProfileCoverResponseDto?;
          if (valueDes == null) continue;
          result.profileCover.replace(valueDes);
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
            specifiedType: const FullType(CurrentUserResponseDtoRoleEnum),
          ) as CurrentUserResponseDtoRoleEnum;
          result.role = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.level = valueDes;
          break;
        case r'experience':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.experience = valueDes;
          break;
        case r'currentLevelExperience':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.currentLevelExperience = valueDes;
          break;
        case r'nextLevelExperience':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.nextLevelExperience = valueDes;
          break;
        case r'receivedTipTotal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.receivedTipTotal = valueDes;
          break;
        case r'receivedTipCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.receivedTipCount = valueDes;
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
        case r'_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserSocialCountResponseDto),
          ) as UserSocialCountResponseDto;
          result.count.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CurrentUserResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CurrentUserResponseDtoBuilder();
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

class CurrentUserResponseDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const CurrentUserResponseDtoRoleEnum USER = _$currentUserResponseDtoRoleEnum_USER;
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const CurrentUserResponseDtoRoleEnum ADMIN = _$currentUserResponseDtoRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN')
  static const CurrentUserResponseDtoRoleEnum SUPER_ADMIN = _$currentUserResponseDtoRoleEnum_SUPER_ADMIN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CurrentUserResponseDtoRoleEnum unknownDefaultOpenApi = _$currentUserResponseDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<CurrentUserResponseDtoRoleEnum> get serializer => _$currentUserResponseDtoRoleEnumSerializer;

  const CurrentUserResponseDtoRoleEnum._(String name): super(name);

  static BuiltSet<CurrentUserResponseDtoRoleEnum> get values => _$currentUserResponseDtoRoleEnumValues;
  static CurrentUserResponseDtoRoleEnum valueOf(String name) => _$currentUserResponseDtoRoleEnumValueOf(name);
}
