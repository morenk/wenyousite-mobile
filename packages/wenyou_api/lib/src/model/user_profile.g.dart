// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserProfile extends UserProfile {
  @override
  final String id;
  @override
  final String email;
  @override
  final String username;
  @override
  final String? avatar;
  @override
  final String role;
  @override
  final bool emailVerified;
  @override
  final num level;

  factory _$UserProfile([void Function(UserProfileBuilder)? updates]) =>
      (UserProfileBuilder()..update(updates))._build();

  _$UserProfile._({
    required this.id,
    required this.email,
    required this.username,
    this.avatar,
    required this.role,
    required this.emailVerified,
    required this.level,
  }) : super._();
  @override
  UserProfile rebuild(void Function(UserProfileBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserProfileBuilder toBuilder() => UserProfileBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserProfile &&
        id == other.id &&
        email == other.email &&
        username == other.username &&
        avatar == other.avatar &&
        role == other.role &&
        emailVerified == other.emailVerified &&
        level == other.level;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, emailVerified.hashCode);
    _$hash = $jc(_$hash, level.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserProfile')
          ..add('id', id)
          ..add('email', email)
          ..add('username', username)
          ..add('avatar', avatar)
          ..add('role', role)
          ..add('emailVerified', emailVerified)
          ..add('level', level))
        .toString();
  }
}

class UserProfileBuilder implements Builder<UserProfile, UserProfileBuilder> {
  _$UserProfile? _$v;

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

  String? _role;
  String? get role => _$this._role;
  set role(String? role) => _$this._role = role;

  bool? _emailVerified;
  bool? get emailVerified => _$this._emailVerified;
  set emailVerified(bool? emailVerified) =>
      _$this._emailVerified = emailVerified;

  num? _level;
  num? get level => _$this._level;
  set level(num? level) => _$this._level = level;

  UserProfileBuilder() {
    UserProfile._defaults(this);
  }

  UserProfileBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _username = $v.username;
      _avatar = $v.avatar;
      _role = $v.role;
      _emailVerified = $v.emailVerified;
      _level = $v.level;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserProfile other) {
    _$v = other as _$UserProfile;
  }

  @override
  void update(void Function(UserProfileBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserProfile build() => _build();

  _$UserProfile _build() {
    final _$result =
        _$v ??
        _$UserProfile._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'UserProfile', 'id'),
          email: BuiltValueNullFieldError.checkNotNull(
            email,
            r'UserProfile',
            'email',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'UserProfile',
            'username',
          ),
          avatar: avatar,
          role: BuiltValueNullFieldError.checkNotNull(
            role,
            r'UserProfile',
            'role',
          ),
          emailVerified: BuiltValueNullFieldError.checkNotNull(
            emailVerified,
            r'UserProfile',
            'emailVerified',
          ),
          level: BuiltValueNullFieldError.checkNotNull(
            level,
            r'UserProfile',
            'level',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
