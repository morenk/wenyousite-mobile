//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/profile_cover_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/user_social_count_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'public_user_response_dto.g.dart';

/// PublicUserResponseDto
///
/// Properties:
/// * [id]
/// * [username]
/// * [avatar]
/// * [profileCover]
/// * [bio]
/// * [role]
/// * [level]
/// * [receivedTipTotal]
/// * [receivedTipCount]
/// * [showRecentReplies]
/// * [showPlayerBadges]
/// * [showBookmarks]
/// * [createdAt]
/// * [count]
/// * [accountStatus] - 公开账号状态；只区分有效的临时或永久封禁，不包含处罚截止时间
/// * [isFollowing]
/// * [isFollowedBy]
/// * [isBlocked]
/// * [isBlockedBy]
/// * [isDeactivated]
@BuiltValue()
abstract class PublicUserResponseDto implements Built<PublicUserResponseDto, PublicUserResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  @BuiltValueField(wireName: r'profileCover')
  ProfileCoverResponseDto? get profileCover;

  @BuiltValueField(wireName: r'bio')
  String? get bio;

  @BuiltValueField(wireName: r'role')
  PublicUserResponseDtoRoleEnum? get role;
  // enum roleEnum {  USER,  ADMIN,  SUPER_ADMIN,  };

  @BuiltValueField(wireName: r'level')
  num? get level;

  @BuiltValueField(wireName: r'receivedTipTotal')
  String? get receivedTipTotal;

  @BuiltValueField(wireName: r'receivedTipCount')
  num? get receivedTipCount;

  @BuiltValueField(wireName: r'showRecentReplies')
  bool? get showRecentReplies;

  @BuiltValueField(wireName: r'showPlayerBadges')
  bool? get showPlayerBadges;

  @BuiltValueField(wireName: r'showBookmarks')
  bool? get showBookmarks;

  @BuiltValueField(wireName: r'createdAt')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'_count')
  UserSocialCountResponseDto? get count;

  /// 公开账号状态；只区分有效的临时或永久封禁，不包含处罚截止时间
  @BuiltValueField(wireName: r'accountStatus')
  PublicUserResponseDtoAccountStatusEnum? get accountStatus;
  // enum accountStatusEnum {  ACTIVE,  SUSPENDED,  BANNED,  };

  @BuiltValueField(wireName: r'isFollowing')
  bool? get isFollowing;

  @BuiltValueField(wireName: r'isFollowedBy')
  bool? get isFollowedBy;

  @BuiltValueField(wireName: r'isBlocked')
  bool? get isBlocked;

  @BuiltValueField(wireName: r'isBlockedBy')
  bool? get isBlockedBy;

  @BuiltValueField(wireName: r'isDeactivated')
  bool? get isDeactivated;

  PublicUserResponseDto._();

  factory PublicUserResponseDto([void updates(PublicUserResponseDtoBuilder b)]) = _$PublicUserResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PublicUserResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PublicUserResponseDto> get serializer => _$PublicUserResponseDtoSerializer();
}

class _$PublicUserResponseDtoSerializer implements PrimitiveSerializer<PublicUserResponseDto> {
  @override
  final Iterable<Type> types = const [PublicUserResponseDto, _$PublicUserResponseDto];

  @override
  final String wireName = r'PublicUserResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PublicUserResponseDto object, {
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
    if (object.avatar != null) {
      yield r'avatar';
      yield serializers.serialize(
        object.avatar,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.profileCover != null) {
      yield r'profileCover';
      yield serializers.serialize(
        object.profileCover,
        specifiedType: const FullType.nullable(ProfileCoverResponseDto),
      );
    }
    if (object.bio != null) {
      yield r'bio';
      yield serializers.serialize(
        object.bio,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(PublicUserResponseDtoRoleEnum),
      );
    }
    if (object.level != null) {
      yield r'level';
      yield serializers.serialize(
        object.level,
        specifiedType: const FullType(num),
      );
    }
    if (object.receivedTipTotal != null) {
      yield r'receivedTipTotal';
      yield serializers.serialize(
        object.receivedTipTotal,
        specifiedType: const FullType(String),
      );
    }
    if (object.receivedTipCount != null) {
      yield r'receivedTipCount';
      yield serializers.serialize(
        object.receivedTipCount,
        specifiedType: const FullType(num),
      );
    }
    if (object.showRecentReplies != null) {
      yield r'showRecentReplies';
      yield serializers.serialize(
        object.showRecentReplies,
        specifiedType: const FullType(bool),
      );
    }
    if (object.showPlayerBadges != null) {
      yield r'showPlayerBadges';
      yield serializers.serialize(
        object.showPlayerBadges,
        specifiedType: const FullType(bool),
      );
    }
    if (object.showBookmarks != null) {
      yield r'showBookmarks';
      yield serializers.serialize(
        object.showBookmarks,
        specifiedType: const FullType(bool),
      );
    }
    if (object.createdAt != null) {
      yield r'createdAt';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.count != null) {
      yield r'_count';
      yield serializers.serialize(
        object.count,
        specifiedType: const FullType(UserSocialCountResponseDto),
      );
    }
    if (object.accountStatus != null) {
      yield r'accountStatus';
      yield serializers.serialize(
        object.accountStatus,
        specifiedType: const FullType(PublicUserResponseDtoAccountStatusEnum),
      );
    }
    if (object.isFollowing != null) {
      yield r'isFollowing';
      yield serializers.serialize(
        object.isFollowing,
        specifiedType: const FullType(bool),
      );
    }
    if (object.isFollowedBy != null) {
      yield r'isFollowedBy';
      yield serializers.serialize(
        object.isFollowedBy,
        specifiedType: const FullType(bool),
      );
    }
    if (object.isBlocked != null) {
      yield r'isBlocked';
      yield serializers.serialize(
        object.isBlocked,
        specifiedType: const FullType(bool),
      );
    }
    if (object.isBlockedBy != null) {
      yield r'isBlockedBy';
      yield serializers.serialize(
        object.isBlockedBy,
        specifiedType: const FullType(bool),
      );
    }
    if (object.isDeactivated != null) {
      yield r'isDeactivated';
      yield serializers.serialize(
        object.isDeactivated,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PublicUserResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PublicUserResponseDtoBuilder result,
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
            specifiedType: const FullType(PublicUserResponseDtoRoleEnum),
          ) as PublicUserResponseDtoRoleEnum;
          result.role = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.level = valueDes;
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
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserSocialCountResponseDto),
          ) as UserSocialCountResponseDto;
          result.count.replace(valueDes);
          break;
        case r'accountStatus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PublicUserResponseDtoAccountStatusEnum),
          ) as PublicUserResponseDtoAccountStatusEnum;
          result.accountStatus = valueDes;
          break;
        case r'isFollowing':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isFollowing = valueDes;
          break;
        case r'isFollowedBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isFollowedBy = valueDes;
          break;
        case r'isBlocked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isBlocked = valueDes;
          break;
        case r'isBlockedBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isBlockedBy = valueDes;
          break;
        case r'isDeactivated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDeactivated = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PublicUserResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PublicUserResponseDtoBuilder();
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

class PublicUserResponseDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const PublicUserResponseDtoRoleEnum USER = _$publicUserResponseDtoRoleEnum_USER;
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const PublicUserResponseDtoRoleEnum ADMIN = _$publicUserResponseDtoRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN')
  static const PublicUserResponseDtoRoleEnum SUPER_ADMIN = _$publicUserResponseDtoRoleEnum_SUPER_ADMIN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const PublicUserResponseDtoRoleEnum unknownDefaultOpenApi = _$publicUserResponseDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<PublicUserResponseDtoRoleEnum> get serializer => _$publicUserResponseDtoRoleEnumSerializer;

  const PublicUserResponseDtoRoleEnum._(String name): super(name);

  static BuiltSet<PublicUserResponseDtoRoleEnum> get values => _$publicUserResponseDtoRoleEnumValues;
  static PublicUserResponseDtoRoleEnum valueOf(String name) => _$publicUserResponseDtoRoleEnumValueOf(name);
}

class PublicUserResponseDtoAccountStatusEnum extends EnumClass {

  /// 公开账号状态；只区分有效的临时或永久封禁，不包含处罚截止时间
  @BuiltValueEnumConst(wireName: r'ACTIVE')
  static const PublicUserResponseDtoAccountStatusEnum ACTIVE = _$publicUserResponseDtoAccountStatusEnum_ACTIVE;
  /// 公开账号状态；只区分有效的临时或永久封禁，不包含处罚截止时间
  @BuiltValueEnumConst(wireName: r'SUSPENDED')
  static const PublicUserResponseDtoAccountStatusEnum SUSPENDED = _$publicUserResponseDtoAccountStatusEnum_SUSPENDED;
  /// 公开账号状态；只区分有效的临时或永久封禁，不包含处罚截止时间
  @BuiltValueEnumConst(wireName: r'BANNED')
  static const PublicUserResponseDtoAccountStatusEnum BANNED = _$publicUserResponseDtoAccountStatusEnum_BANNED;
  /// 公开账号状态；只区分有效的临时或永久封禁，不包含处罚截止时间
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const PublicUserResponseDtoAccountStatusEnum unknownDefaultOpenApi = _$publicUserResponseDtoAccountStatusEnum_unknownDefaultOpenApi;

  static Serializer<PublicUserResponseDtoAccountStatusEnum> get serializer => _$publicUserResponseDtoAccountStatusEnumSerializer;

  const PublicUserResponseDtoAccountStatusEnum._(String name): super(name);

  static BuiltSet<PublicUserResponseDtoAccountStatusEnum> get values => _$publicUserResponseDtoAccountStatusEnumValues;
  static PublicUserResponseDtoAccountStatusEnum valueOf(String name) => _$publicUserResponseDtoAccountStatusEnumValueOf(name);
}
