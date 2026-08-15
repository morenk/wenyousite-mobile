// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_user_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PrivateUserResponseDtoRoleEnum _$privateUserResponseDtoRoleEnum_USER =
    const PrivateUserResponseDtoRoleEnum._('USER');
const PrivateUserResponseDtoRoleEnum _$privateUserResponseDtoRoleEnum_ADMIN =
    const PrivateUserResponseDtoRoleEnum._('ADMIN');
const PrivateUserResponseDtoRoleEnum
_$privateUserResponseDtoRoleEnum_SUPER_ADMIN =
    const PrivateUserResponseDtoRoleEnum._('SUPER_ADMIN');
const PrivateUserResponseDtoRoleEnum
_$privateUserResponseDtoRoleEnum_unknownDefaultOpenApi =
    const PrivateUserResponseDtoRoleEnum._('unknownDefaultOpenApi');

PrivateUserResponseDtoRoleEnum _$privateUserResponseDtoRoleEnumValueOf(
  String name,
) {
  switch (name) {
    case 'USER':
      return _$privateUserResponseDtoRoleEnum_USER;
    case 'ADMIN':
      return _$privateUserResponseDtoRoleEnum_ADMIN;
    case 'SUPER_ADMIN':
      return _$privateUserResponseDtoRoleEnum_SUPER_ADMIN;
    case 'unknownDefaultOpenApi':
      return _$privateUserResponseDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$privateUserResponseDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PrivateUserResponseDtoRoleEnum>
_$privateUserResponseDtoRoleEnumValues =
    BuiltSet<PrivateUserResponseDtoRoleEnum>(
      const <PrivateUserResponseDtoRoleEnum>[
        _$privateUserResponseDtoRoleEnum_USER,
        _$privateUserResponseDtoRoleEnum_ADMIN,
        _$privateUserResponseDtoRoleEnum_SUPER_ADMIN,
        _$privateUserResponseDtoRoleEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PrivateUserResponseDtoRoleEnum>
_$privateUserResponseDtoRoleEnumSerializer =
    _$PrivateUserResponseDtoRoleEnumSerializer();

class _$PrivateUserResponseDtoRoleEnumSerializer
    implements PrimitiveSerializer<PrivateUserResponseDtoRoleEnum> {
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
  final Iterable<Type> types = const <Type>[PrivateUserResponseDtoRoleEnum];
  @override
  final String wireName = 'PrivateUserResponseDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    PrivateUserResponseDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PrivateUserResponseDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PrivateUserResponseDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PrivateUserResponseDto extends PrivateUserResponseDto {
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
  final PrivateUserResponseDtoRoleEnum role;
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
  final DateTime? deletedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$PrivateUserResponseDto([
    void Function(PrivateUserResponseDtoBuilder)? updates,
  ]) => (PrivateUserResponseDtoBuilder()..update(updates))._build();

  _$PrivateUserResponseDto._({
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
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();
  @override
  PrivateUserResponseDto rebuild(
    void Function(PrivateUserResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PrivateUserResponseDtoBuilder toBuilder() =>
      PrivateUserResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrivateUserResponseDto &&
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
        deletedAt == other.deletedAt &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
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
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrivateUserResponseDto')
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
          ..add('deletedAt', deletedAt)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class PrivateUserResponseDtoBuilder
    implements Builder<PrivateUserResponseDto, PrivateUserResponseDtoBuilder> {
  _$PrivateUserResponseDto? _$v;

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

  PrivateUserResponseDtoRoleEnum? _role;
  PrivateUserResponseDtoRoleEnum? get role => _$this._role;
  set role(PrivateUserResponseDtoRoleEnum? role) => _$this._role = role;

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

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PrivateUserResponseDtoBuilder() {
    PrivateUserResponseDto._defaults(this);
  }

  PrivateUserResponseDtoBuilder get _$this {
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
      _deletedAt = $v.deletedAt;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrivateUserResponseDto other) {
    _$v = other as _$PrivateUserResponseDto;
  }

  @override
  void update(void Function(PrivateUserResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrivateUserResponseDto build() => _build();

  _$PrivateUserResponseDto _build() {
    _$PrivateUserResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$PrivateUserResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'PrivateUserResponseDto',
              'id',
            ),
            email: BuiltValueNullFieldError.checkNotNull(
              email,
              r'PrivateUserResponseDto',
              'email',
            ),
            username: BuiltValueNullFieldError.checkNotNull(
              username,
              r'PrivateUserResponseDto',
              'username',
            ),
            avatar: avatar,
            profileCover: _profileCover?.build(),
            bio: bio,
            role: BuiltValueNullFieldError.checkNotNull(
              role,
              r'PrivateUserResponseDto',
              'role',
            ),
            level: BuiltValueNullFieldError.checkNotNull(
              level,
              r'PrivateUserResponseDto',
              'level',
            ),
            experience: BuiltValueNullFieldError.checkNotNull(
              experience,
              r'PrivateUserResponseDto',
              'experience',
            ),
            currentLevelExperience: BuiltValueNullFieldError.checkNotNull(
              currentLevelExperience,
              r'PrivateUserResponseDto',
              'currentLevelExperience',
            ),
            nextLevelExperience: nextLevelExperience,
            receivedTipTotal: BuiltValueNullFieldError.checkNotNull(
              receivedTipTotal,
              r'PrivateUserResponseDto',
              'receivedTipTotal',
            ),
            receivedTipCount: BuiltValueNullFieldError.checkNotNull(
              receivedTipCount,
              r'PrivateUserResponseDto',
              'receivedTipCount',
            ),
            showRecentReplies: BuiltValueNullFieldError.checkNotNull(
              showRecentReplies,
              r'PrivateUserResponseDto',
              'showRecentReplies',
            ),
            showPlayerBadges: BuiltValueNullFieldError.checkNotNull(
              showPlayerBadges,
              r'PrivateUserResponseDto',
              'showPlayerBadges',
            ),
            showBookmarks: BuiltValueNullFieldError.checkNotNull(
              showBookmarks,
              r'PrivateUserResponseDto',
              'showBookmarks',
            ),
            deletedAt: deletedAt,
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'PrivateUserResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'PrivateUserResponseDto',
              'updatedAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'profileCover';
        _profileCover?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'PrivateUserResponseDto',
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
