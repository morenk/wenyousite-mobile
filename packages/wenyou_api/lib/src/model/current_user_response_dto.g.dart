// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CurrentUserResponseDtoRoleEnum _$currentUserResponseDtoRoleEnum_USER =
    const CurrentUserResponseDtoRoleEnum._('USER');
const CurrentUserResponseDtoRoleEnum _$currentUserResponseDtoRoleEnum_ADMIN =
    const CurrentUserResponseDtoRoleEnum._('ADMIN');
const CurrentUserResponseDtoRoleEnum
_$currentUserResponseDtoRoleEnum_SUPER_ADMIN =
    const CurrentUserResponseDtoRoleEnum._('SUPER_ADMIN');
const CurrentUserResponseDtoRoleEnum
_$currentUserResponseDtoRoleEnum_unknownDefaultOpenApi =
    const CurrentUserResponseDtoRoleEnum._('unknownDefaultOpenApi');

CurrentUserResponseDtoRoleEnum _$currentUserResponseDtoRoleEnumValueOf(
  String name,
) {
  switch (name) {
    case 'USER':
      return _$currentUserResponseDtoRoleEnum_USER;
    case 'ADMIN':
      return _$currentUserResponseDtoRoleEnum_ADMIN;
    case 'SUPER_ADMIN':
      return _$currentUserResponseDtoRoleEnum_SUPER_ADMIN;
    case 'unknownDefaultOpenApi':
      return _$currentUserResponseDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$currentUserResponseDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<CurrentUserResponseDtoRoleEnum>
_$currentUserResponseDtoRoleEnumValues =
    BuiltSet<CurrentUserResponseDtoRoleEnum>(
      const <CurrentUserResponseDtoRoleEnum>[
        _$currentUserResponseDtoRoleEnum_USER,
        _$currentUserResponseDtoRoleEnum_ADMIN,
        _$currentUserResponseDtoRoleEnum_SUPER_ADMIN,
        _$currentUserResponseDtoRoleEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<CurrentUserResponseDtoRoleEnum>
_$currentUserResponseDtoRoleEnumSerializer =
    _$CurrentUserResponseDtoRoleEnumSerializer();

class _$CurrentUserResponseDtoRoleEnumSerializer
    implements PrimitiveSerializer<CurrentUserResponseDtoRoleEnum> {
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
  final Iterable<Type> types = const <Type>[CurrentUserResponseDtoRoleEnum];
  @override
  final String wireName = 'CurrentUserResponseDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    CurrentUserResponseDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CurrentUserResponseDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CurrentUserResponseDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CurrentUserResponseDto extends CurrentUserResponseDto {
  @override
  final String id;
  @override
  final String email;
  @override
  final String username;
  @override
  final String? avatar;
  @override
  final ProfileCoverResponseDto? profileCover;
  @override
  final String? bio;
  @override
  final CurrentUserResponseDtoRoleEnum role;
  @override
  final num level;
  @override
  final num experience;
  @override
  final num currentLevelExperience;
  @override
  final num? nextLevelExperience;
  @override
  final String receivedTipTotal;
  @override
  final num receivedTipCount;
  @override
  final bool showRecentReplies;
  @override
  final bool showPlayerBadges;
  @override
  final bool showBookmarks;
  @override
  final bool emailVerified;
  @override
  final DateTime? deletedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final UserSocialCountResponseDto count;

  factory _$CurrentUserResponseDto([
    void Function(CurrentUserResponseDtoBuilder)? updates,
  ]) => (CurrentUserResponseDtoBuilder()..update(updates))._build();

  _$CurrentUserResponseDto._({
    required this.id,
    required this.email,
    required this.username,
    this.avatar,
    this.profileCover,
    this.bio,
    required this.role,
    required this.level,
    required this.experience,
    required this.currentLevelExperience,
    this.nextLevelExperience,
    required this.receivedTipTotal,
    required this.receivedTipCount,
    required this.showRecentReplies,
    required this.showPlayerBadges,
    required this.showBookmarks,
    required this.emailVerified,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.count,
  }) : super._();
  @override
  CurrentUserResponseDto rebuild(
    void Function(CurrentUserResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CurrentUserResponseDtoBuilder toBuilder() =>
      CurrentUserResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CurrentUserResponseDto &&
        id == other.id &&
        email == other.email &&
        username == other.username &&
        avatar == other.avatar &&
        profileCover == other.profileCover &&
        bio == other.bio &&
        role == other.role &&
        level == other.level &&
        experience == other.experience &&
        currentLevelExperience == other.currentLevelExperience &&
        nextLevelExperience == other.nextLevelExperience &&
        receivedTipTotal == other.receivedTipTotal &&
        receivedTipCount == other.receivedTipCount &&
        showRecentReplies == other.showRecentReplies &&
        showPlayerBadges == other.showPlayerBadges &&
        showBookmarks == other.showBookmarks &&
        emailVerified == other.emailVerified &&
        deletedAt == other.deletedAt &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        count == other.count;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jc(_$hash, profileCover.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, level.hashCode);
    _$hash = $jc(_$hash, experience.hashCode);
    _$hash = $jc(_$hash, currentLevelExperience.hashCode);
    _$hash = $jc(_$hash, nextLevelExperience.hashCode);
    _$hash = $jc(_$hash, receivedTipTotal.hashCode);
    _$hash = $jc(_$hash, receivedTipCount.hashCode);
    _$hash = $jc(_$hash, showRecentReplies.hashCode);
    _$hash = $jc(_$hash, showPlayerBadges.hashCode);
    _$hash = $jc(_$hash, showBookmarks.hashCode);
    _$hash = $jc(_$hash, emailVerified.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CurrentUserResponseDto')
          ..add('id', id)
          ..add('email', email)
          ..add('username', username)
          ..add('avatar', avatar)
          ..add('profileCover', profileCover)
          ..add('bio', bio)
          ..add('role', role)
          ..add('level', level)
          ..add('experience', experience)
          ..add('currentLevelExperience', currentLevelExperience)
          ..add('nextLevelExperience', nextLevelExperience)
          ..add('receivedTipTotal', receivedTipTotal)
          ..add('receivedTipCount', receivedTipCount)
          ..add('showRecentReplies', showRecentReplies)
          ..add('showPlayerBadges', showPlayerBadges)
          ..add('showBookmarks', showBookmarks)
          ..add('emailVerified', emailVerified)
          ..add('deletedAt', deletedAt)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('count', count))
        .toString();
  }
}

class CurrentUserResponseDtoBuilder
    implements Builder<CurrentUserResponseDto, CurrentUserResponseDtoBuilder> {
  _$CurrentUserResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  ProfileCoverResponseDtoBuilder? _profileCover;
  ProfileCoverResponseDtoBuilder get profileCover =>
      _$this._profileCover ??= ProfileCoverResponseDtoBuilder();
  set profileCover(ProfileCoverResponseDtoBuilder? profileCover) =>
      _$this._profileCover = profileCover;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  CurrentUserResponseDtoRoleEnum? _role;
  CurrentUserResponseDtoRoleEnum? get role => _$this._role;
  set role(CurrentUserResponseDtoRoleEnum? role) => _$this._role = role;

  num? _level;
  num? get level => _$this._level;
  set level(num? level) => _$this._level = level;

  num? _experience;
  num? get experience => _$this._experience;
  set experience(num? experience) => _$this._experience = experience;

  num? _currentLevelExperience;
  num? get currentLevelExperience => _$this._currentLevelExperience;
  set currentLevelExperience(num? currentLevelExperience) =>
      _$this._currentLevelExperience = currentLevelExperience;

  num? _nextLevelExperience;
  num? get nextLevelExperience => _$this._nextLevelExperience;
  set nextLevelExperience(num? nextLevelExperience) =>
      _$this._nextLevelExperience = nextLevelExperience;

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

  bool? _emailVerified;
  bool? get emailVerified => _$this._emailVerified;
  set emailVerified(bool? emailVerified) =>
      _$this._emailVerified = emailVerified;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  UserSocialCountResponseDtoBuilder? _count;
  UserSocialCountResponseDtoBuilder get count =>
      _$this._count ??= UserSocialCountResponseDtoBuilder();
  set count(UserSocialCountResponseDtoBuilder? count) => _$this._count = count;

  CurrentUserResponseDtoBuilder() {
    CurrentUserResponseDto._defaults(this);
  }

  CurrentUserResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _username = $v.username;
      _avatar = $v.avatar;
      _profileCover = $v.profileCover?.toBuilder();
      _bio = $v.bio;
      _role = $v.role;
      _level = $v.level;
      _experience = $v.experience;
      _currentLevelExperience = $v.currentLevelExperience;
      _nextLevelExperience = $v.nextLevelExperience;
      _receivedTipTotal = $v.receivedTipTotal;
      _receivedTipCount = $v.receivedTipCount;
      _showRecentReplies = $v.showRecentReplies;
      _showPlayerBadges = $v.showPlayerBadges;
      _showBookmarks = $v.showBookmarks;
      _emailVerified = $v.emailVerified;
      _deletedAt = $v.deletedAt;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _count = $v.count.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CurrentUserResponseDto other) {
    _$v = other as _$CurrentUserResponseDto;
  }

  @override
  void update(void Function(CurrentUserResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CurrentUserResponseDto build() => _build();

  _$CurrentUserResponseDto _build() {
    _$CurrentUserResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$CurrentUserResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'CurrentUserResponseDto',
              'id',
            ),
            email: BuiltValueNullFieldError.checkNotNull(
              email,
              r'CurrentUserResponseDto',
              'email',
            ),
            username: BuiltValueNullFieldError.checkNotNull(
              username,
              r'CurrentUserResponseDto',
              'username',
            ),
            avatar: avatar,
            profileCover: _profileCover?.build(),
            bio: bio,
            role: BuiltValueNullFieldError.checkNotNull(
              role,
              r'CurrentUserResponseDto',
              'role',
            ),
            level: BuiltValueNullFieldError.checkNotNull(
              level,
              r'CurrentUserResponseDto',
              'level',
            ),
            experience: BuiltValueNullFieldError.checkNotNull(
              experience,
              r'CurrentUserResponseDto',
              'experience',
            ),
            currentLevelExperience: BuiltValueNullFieldError.checkNotNull(
              currentLevelExperience,
              r'CurrentUserResponseDto',
              'currentLevelExperience',
            ),
            nextLevelExperience: nextLevelExperience,
            receivedTipTotal: BuiltValueNullFieldError.checkNotNull(
              receivedTipTotal,
              r'CurrentUserResponseDto',
              'receivedTipTotal',
            ),
            receivedTipCount: BuiltValueNullFieldError.checkNotNull(
              receivedTipCount,
              r'CurrentUserResponseDto',
              'receivedTipCount',
            ),
            showRecentReplies: BuiltValueNullFieldError.checkNotNull(
              showRecentReplies,
              r'CurrentUserResponseDto',
              'showRecentReplies',
            ),
            showPlayerBadges: BuiltValueNullFieldError.checkNotNull(
              showPlayerBadges,
              r'CurrentUserResponseDto',
              'showPlayerBadges',
            ),
            showBookmarks: BuiltValueNullFieldError.checkNotNull(
              showBookmarks,
              r'CurrentUserResponseDto',
              'showBookmarks',
            ),
            emailVerified: BuiltValueNullFieldError.checkNotNull(
              emailVerified,
              r'CurrentUserResponseDto',
              'emailVerified',
            ),
            deletedAt: deletedAt,
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'CurrentUserResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'CurrentUserResponseDto',
              'updatedAt',
            ),
            count: count.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'profileCover';
        _profileCover?.build();

        _$failedField = 'count';
        count.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CurrentUserResponseDto',
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
