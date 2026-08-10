// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_user_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PublicUserResponseDtoRoleEnum _$publicUserResponseDtoRoleEnum_USER =
    const PublicUserResponseDtoRoleEnum._('USER');
const PublicUserResponseDtoRoleEnum _$publicUserResponseDtoRoleEnum_ADMIN =
    const PublicUserResponseDtoRoleEnum._('ADMIN');
const PublicUserResponseDtoRoleEnum
_$publicUserResponseDtoRoleEnum_SUPER_ADMIN =
    const PublicUserResponseDtoRoleEnum._('SUPER_ADMIN');
const PublicUserResponseDtoRoleEnum
_$publicUserResponseDtoRoleEnum_unknownDefaultOpenApi =
    const PublicUserResponseDtoRoleEnum._('unknownDefaultOpenApi');

PublicUserResponseDtoRoleEnum _$publicUserResponseDtoRoleEnumValueOf(
  String name,
) {
  switch (name) {
    case 'USER':
      return _$publicUserResponseDtoRoleEnum_USER;
    case 'ADMIN':
      return _$publicUserResponseDtoRoleEnum_ADMIN;
    case 'SUPER_ADMIN':
      return _$publicUserResponseDtoRoleEnum_SUPER_ADMIN;
    case 'unknownDefaultOpenApi':
      return _$publicUserResponseDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$publicUserResponseDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PublicUserResponseDtoRoleEnum>
_$publicUserResponseDtoRoleEnumValues = BuiltSet<PublicUserResponseDtoRoleEnum>(
  const <PublicUserResponseDtoRoleEnum>[
    _$publicUserResponseDtoRoleEnum_USER,
    _$publicUserResponseDtoRoleEnum_ADMIN,
    _$publicUserResponseDtoRoleEnum_SUPER_ADMIN,
    _$publicUserResponseDtoRoleEnum_unknownDefaultOpenApi,
  ],
);

const PublicUserResponseDtoAccountStatusEnum
_$publicUserResponseDtoAccountStatusEnum_ACTIVE =
    const PublicUserResponseDtoAccountStatusEnum._('ACTIVE');
const PublicUserResponseDtoAccountStatusEnum
_$publicUserResponseDtoAccountStatusEnum_SUSPENDED =
    const PublicUserResponseDtoAccountStatusEnum._('SUSPENDED');
const PublicUserResponseDtoAccountStatusEnum
_$publicUserResponseDtoAccountStatusEnum_BANNED =
    const PublicUserResponseDtoAccountStatusEnum._('BANNED');
const PublicUserResponseDtoAccountStatusEnum
_$publicUserResponseDtoAccountStatusEnum_unknownDefaultOpenApi =
    const PublicUserResponseDtoAccountStatusEnum._('unknownDefaultOpenApi');

PublicUserResponseDtoAccountStatusEnum
_$publicUserResponseDtoAccountStatusEnumValueOf(String name) {
  switch (name) {
    case 'ACTIVE':
      return _$publicUserResponseDtoAccountStatusEnum_ACTIVE;
    case 'SUSPENDED':
      return _$publicUserResponseDtoAccountStatusEnum_SUSPENDED;
    case 'BANNED':
      return _$publicUserResponseDtoAccountStatusEnum_BANNED;
    case 'unknownDefaultOpenApi':
      return _$publicUserResponseDtoAccountStatusEnum_unknownDefaultOpenApi;
    default:
      return _$publicUserResponseDtoAccountStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PublicUserResponseDtoAccountStatusEnum>
_$publicUserResponseDtoAccountStatusEnumValues =
    BuiltSet<PublicUserResponseDtoAccountStatusEnum>(
      const <PublicUserResponseDtoAccountStatusEnum>[
        _$publicUserResponseDtoAccountStatusEnum_ACTIVE,
        _$publicUserResponseDtoAccountStatusEnum_SUSPENDED,
        _$publicUserResponseDtoAccountStatusEnum_BANNED,
        _$publicUserResponseDtoAccountStatusEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PublicUserResponseDtoRoleEnum>
_$publicUserResponseDtoRoleEnumSerializer =
    _$PublicUserResponseDtoRoleEnumSerializer();
Serializer<PublicUserResponseDtoAccountStatusEnum>
_$publicUserResponseDtoAccountStatusEnumSerializer =
    _$PublicUserResponseDtoAccountStatusEnumSerializer();

class _$PublicUserResponseDtoRoleEnumSerializer
    implements PrimitiveSerializer<PublicUserResponseDtoRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'USER': 'USER',
    'ADMIN': 'ADMIN',
    'SUPER_ADMIN': 'SUPER_ADMIN',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'USER': 'USER',
    'ADMIN': 'ADMIN',
    'SUPER_ADMIN': 'SUPER_ADMIN',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[PublicUserResponseDtoRoleEnum];
  @override
  final String wireName = 'PublicUserResponseDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    PublicUserResponseDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PublicUserResponseDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PublicUserResponseDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PublicUserResponseDtoAccountStatusEnumSerializer
    implements PrimitiveSerializer<PublicUserResponseDtoAccountStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ACTIVE': 'ACTIVE',
    'SUSPENDED': 'SUSPENDED',
    'BANNED': 'BANNED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ACTIVE': 'ACTIVE',
    'SUSPENDED': 'SUSPENDED',
    'BANNED': 'BANNED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PublicUserResponseDtoAccountStatusEnum,
  ];
  @override
  final String wireName = 'PublicUserResponseDtoAccountStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    PublicUserResponseDtoAccountStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PublicUserResponseDtoAccountStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PublicUserResponseDtoAccountStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PublicUserResponseDto extends PublicUserResponseDto {
  @override
  final String id;
  @override
  final String username;
  @override
  final String? avatar;
  @override
  final String? bio;
  @override
  final PublicUserResponseDtoRoleEnum? role;
  @override
  final num? level;
  @override
  final String? receivedTipTotal;
  @override
  final num? receivedTipCount;
  @override
  final bool? showRecentReplies;
  @override
  final bool? showPlayerBadges;
  @override
  final bool? showBookmarks;
  @override
  final DateTime? createdAt;
  @override
  final UserSocialCountResponseDto? count;
  @override
  final PublicUserResponseDtoAccountStatusEnum? accountStatus;
  @override
  final bool? isFollowing;
  @override
  final bool? isFollowedBy;
  @override
  final bool? isBlocked;
  @override
  final bool? isBlockedBy;
  @override
  final bool? isDeactivated;

  factory _$PublicUserResponseDto([
    void Function(PublicUserResponseDtoBuilder)? updates,
  ]) => (PublicUserResponseDtoBuilder()..update(updates))._build();

  _$PublicUserResponseDto._({
    required this.id,
    required this.username,
    this.avatar,
    this.bio,
    this.role,
    this.level,
    this.receivedTipTotal,
    this.receivedTipCount,
    this.showRecentReplies,
    this.showPlayerBadges,
    this.showBookmarks,
    this.createdAt,
    this.count,
    this.accountStatus,
    this.isFollowing,
    this.isFollowedBy,
    this.isBlocked,
    this.isBlockedBy,
    this.isDeactivated,
  }) : super._();
  @override
  PublicUserResponseDto rebuild(
    void Function(PublicUserResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PublicUserResponseDtoBuilder toBuilder() =>
      PublicUserResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PublicUserResponseDto &&
        id == other.id &&
        username == other.username &&
        avatar == other.avatar &&
        bio == other.bio &&
        role == other.role &&
        level == other.level &&
        receivedTipTotal == other.receivedTipTotal &&
        receivedTipCount == other.receivedTipCount &&
        showRecentReplies == other.showRecentReplies &&
        showPlayerBadges == other.showPlayerBadges &&
        showBookmarks == other.showBookmarks &&
        createdAt == other.createdAt &&
        count == other.count &&
        accountStatus == other.accountStatus &&
        isFollowing == other.isFollowing &&
        isFollowedBy == other.isFollowedBy &&
        isBlocked == other.isBlocked &&
        isBlockedBy == other.isBlockedBy &&
        isDeactivated == other.isDeactivated;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, level.hashCode);
    _$hash = $jc(_$hash, receivedTipTotal.hashCode);
    _$hash = $jc(_$hash, receivedTipCount.hashCode);
    _$hash = $jc(_$hash, showRecentReplies.hashCode);
    _$hash = $jc(_$hash, showPlayerBadges.hashCode);
    _$hash = $jc(_$hash, showBookmarks.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jc(_$hash, accountStatus.hashCode);
    _$hash = $jc(_$hash, isFollowing.hashCode);
    _$hash = $jc(_$hash, isFollowedBy.hashCode);
    _$hash = $jc(_$hash, isBlocked.hashCode);
    _$hash = $jc(_$hash, isBlockedBy.hashCode);
    _$hash = $jc(_$hash, isDeactivated.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PublicUserResponseDto')
          ..add('id', id)
          ..add('username', username)
          ..add('avatar', avatar)
          ..add('bio', bio)
          ..add('role', role)
          ..add('level', level)
          ..add('receivedTipTotal', receivedTipTotal)
          ..add('receivedTipCount', receivedTipCount)
          ..add('showRecentReplies', showRecentReplies)
          ..add('showPlayerBadges', showPlayerBadges)
          ..add('showBookmarks', showBookmarks)
          ..add('createdAt', createdAt)
          ..add('count', count)
          ..add('accountStatus', accountStatus)
          ..add('isFollowing', isFollowing)
          ..add('isFollowedBy', isFollowedBy)
          ..add('isBlocked', isBlocked)
          ..add('isBlockedBy', isBlockedBy)
          ..add('isDeactivated', isDeactivated))
        .toString();
  }
}

class PublicUserResponseDtoBuilder
    implements Builder<PublicUserResponseDto, PublicUserResponseDtoBuilder> {
  _$PublicUserResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  PublicUserResponseDtoRoleEnum? _role;
  PublicUserResponseDtoRoleEnum? get role => _$this._role;
  set role(PublicUserResponseDtoRoleEnum? role) => _$this._role = role;

  num? _level;
  num? get level => _$this._level;
  set level(num? level) => _$this._level = level;

  String? _receivedTipTotal;
  String? get receivedTipTotal => _$this._receivedTipTotal;
  set receivedTipTotal(String? receivedTipTotal) =>
      _$this._receivedTipTotal = receivedTipTotal;

  num? _receivedTipCount;
  num? get receivedTipCount => _$this._receivedTipCount;
  set receivedTipCount(num? receivedTipCount) =>
      _$this._receivedTipCount = receivedTipCount;

  bool? _showRecentReplies;
  bool? get showRecentReplies => _$this._showRecentReplies;
  set showRecentReplies(bool? showRecentReplies) =>
      _$this._showRecentReplies = showRecentReplies;

  bool? _showPlayerBadges;
  bool? get showPlayerBadges => _$this._showPlayerBadges;
  set showPlayerBadges(bool? showPlayerBadges) =>
      _$this._showPlayerBadges = showPlayerBadges;

  bool? _showBookmarks;
  bool? get showBookmarks => _$this._showBookmarks;
  set showBookmarks(bool? showBookmarks) =>
      _$this._showBookmarks = showBookmarks;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  UserSocialCountResponseDtoBuilder? _count;
  UserSocialCountResponseDtoBuilder get count =>
      _$this._count ??= UserSocialCountResponseDtoBuilder();
  set count(UserSocialCountResponseDtoBuilder? count) => _$this._count = count;

  PublicUserResponseDtoAccountStatusEnum? _accountStatus;
  PublicUserResponseDtoAccountStatusEnum? get accountStatus =>
      _$this._accountStatus;
  set accountStatus(PublicUserResponseDtoAccountStatusEnum? accountStatus) =>
      _$this._accountStatus = accountStatus;

  bool? _isFollowing;
  bool? get isFollowing => _$this._isFollowing;
  set isFollowing(bool? isFollowing) => _$this._isFollowing = isFollowing;

  bool? _isFollowedBy;
  bool? get isFollowedBy => _$this._isFollowedBy;
  set isFollowedBy(bool? isFollowedBy) => _$this._isFollowedBy = isFollowedBy;

  bool? _isBlocked;
  bool? get isBlocked => _$this._isBlocked;
  set isBlocked(bool? isBlocked) => _$this._isBlocked = isBlocked;

  bool? _isBlockedBy;
  bool? get isBlockedBy => _$this._isBlockedBy;
  set isBlockedBy(bool? isBlockedBy) => _$this._isBlockedBy = isBlockedBy;

  bool? _isDeactivated;
  bool? get isDeactivated => _$this._isDeactivated;
  set isDeactivated(bool? isDeactivated) =>
      _$this._isDeactivated = isDeactivated;

  PublicUserResponseDtoBuilder() {
    PublicUserResponseDto._defaults(this);
  }

  PublicUserResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _avatar = $v.avatar;
      _bio = $v.bio;
      _role = $v.role;
      _level = $v.level;
      _receivedTipTotal = $v.receivedTipTotal;
      _receivedTipCount = $v.receivedTipCount;
      _showRecentReplies = $v.showRecentReplies;
      _showPlayerBadges = $v.showPlayerBadges;
      _showBookmarks = $v.showBookmarks;
      _createdAt = $v.createdAt;
      _count = $v.count?.toBuilder();
      _accountStatus = $v.accountStatus;
      _isFollowing = $v.isFollowing;
      _isFollowedBy = $v.isFollowedBy;
      _isBlocked = $v.isBlocked;
      _isBlockedBy = $v.isBlockedBy;
      _isDeactivated = $v.isDeactivated;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PublicUserResponseDto other) {
    _$v = other as _$PublicUserResponseDto;
  }

  @override
  void update(void Function(PublicUserResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PublicUserResponseDto build() => _build();

  _$PublicUserResponseDto _build() {
    _$PublicUserResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$PublicUserResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'PublicUserResponseDto',
              'id',
            ),
            username: BuiltValueNullFieldError.checkNotNull(
              username,
              r'PublicUserResponseDto',
              'username',
            ),
            avatar: avatar,
            bio: bio,
            role: role,
            level: level,
            receivedTipTotal: receivedTipTotal,
            receivedTipCount: receivedTipCount,
            showRecentReplies: showRecentReplies,
            showPlayerBadges: showPlayerBadges,
            showBookmarks: showBookmarks,
            createdAt: createdAt,
            count: _count?.build(),
            accountStatus: accountStatus,
            isFollowing: isFollowing,
            isFollowedBy: isFollowedBy,
            isBlocked: isBlocked,
            isBlockedBy: isBlockedBy,
            isDeactivated: isDeactivated,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'count';
        _count?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'PublicUserResponseDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
