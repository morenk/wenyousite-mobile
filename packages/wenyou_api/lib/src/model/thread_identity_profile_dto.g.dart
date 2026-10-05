// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_identity_profile_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadIdentityProfileDto extends ThreadIdentityProfileDto {
  @override
  final String? profilePostId;
  @override
  final String id;
  @override
  final String? nickname;
  @override
  final String? avatarMediaId;
  @override
  final num version;

  factory _$ThreadIdentityProfileDto([
    void Function(ThreadIdentityProfileDtoBuilder)? updates,
  ]) => (ThreadIdentityProfileDtoBuilder()..update(updates))._build();

  _$ThreadIdentityProfileDto._({
    this.profilePostId,
    required this.id,
    this.nickname,
    this.avatarMediaId,
    required this.version,
  }) : super._();
  @override
  ThreadIdentityProfileDto rebuild(
    void Function(ThreadIdentityProfileDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadIdentityProfileDtoBuilder toBuilder() =>
      ThreadIdentityProfileDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadIdentityProfileDto &&
        profilePostId == other.profilePostId &&
        id == other.id &&
        nickname == other.nickname &&
        avatarMediaId == other.avatarMediaId &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, profilePostId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, nickname.hashCode);
    _$hash = $jc(_$hash, avatarMediaId.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadIdentityProfileDto')
          ..add('profilePostId', profilePostId)
          ..add('id', id)
          ..add('nickname', nickname)
          ..add('avatarMediaId', avatarMediaId)
          ..add('version', version))
        .toString();
  }
}

class ThreadIdentityProfileDtoBuilder
    implements
        Builder<ThreadIdentityProfileDto, ThreadIdentityProfileDtoBuilder> {
  _$ThreadIdentityProfileDto? _$v;

  String? _profilePostId;
  String? get profilePostId => _$this._profilePostId;
  set profilePostId(String? profilePostId) =>
      _$this._profilePostId = profilePostId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _nickname;
  String? get nickname => _$this._nickname;
  set nickname(String? nickname) => _$this._nickname = nickname;

  String? _avatarMediaId;
  String? get avatarMediaId => _$this._avatarMediaId;
  set avatarMediaId(String? avatarMediaId) =>
      _$this._avatarMediaId = avatarMediaId;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  ThreadIdentityProfileDtoBuilder() {
    ThreadIdentityProfileDto._defaults(this);
  }

  ThreadIdentityProfileDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _profilePostId = $v.profilePostId;
      _id = $v.id;
      _nickname = $v.nickname;
      _avatarMediaId = $v.avatarMediaId;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadIdentityProfileDto other) {
    _$v = other as _$ThreadIdentityProfileDto;
  }

  @override
  void update(void Function(ThreadIdentityProfileDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadIdentityProfileDto build() => _build();

  _$ThreadIdentityProfileDto _build() {
    final _$result =
        _$v ??
        _$ThreadIdentityProfileDto._(
          profilePostId: profilePostId,
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'ThreadIdentityProfileDto',
            'id',
          ),
          nickname: nickname,
          avatarMediaId: avatarMediaId,
          version: BuiltValueNullFieldError.checkNotNull(
            version,
            r'ThreadIdentityProfileDto',
            'version',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
