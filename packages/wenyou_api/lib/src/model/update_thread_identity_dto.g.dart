// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_thread_identity_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateThreadIdentityDto extends UpdateThreadIdentityDto {
  @override
  final bool? clearNickname;
  @override
  final bool? clearAvatar;
  @override
  final String? nickname;
  @override
  final String? avatarMediaId;
  @override
  final num? version;

  factory _$UpdateThreadIdentityDto([
    void Function(UpdateThreadIdentityDtoBuilder)? updates,
  ]) => (UpdateThreadIdentityDtoBuilder()..update(updates))._build();

  _$UpdateThreadIdentityDto._({
    this.clearNickname,
    this.clearAvatar,
    this.nickname,
    this.avatarMediaId,
    this.version,
  }) : super._();
  @override
  UpdateThreadIdentityDto rebuild(
    void Function(UpdateThreadIdentityDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdateThreadIdentityDtoBuilder toBuilder() =>
      UpdateThreadIdentityDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateThreadIdentityDto &&
        clearNickname == other.clearNickname &&
        clearAvatar == other.clearAvatar &&
        nickname == other.nickname &&
        avatarMediaId == other.avatarMediaId &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clearNickname.hashCode);
    _$hash = $jc(_$hash, clearAvatar.hashCode);
    _$hash = $jc(_$hash, nickname.hashCode);
    _$hash = $jc(_$hash, avatarMediaId.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateThreadIdentityDto')
          ..add('clearNickname', clearNickname)
          ..add('clearAvatar', clearAvatar)
          ..add('nickname', nickname)
          ..add('avatarMediaId', avatarMediaId)
          ..add('version', version))
        .toString();
  }
}

class UpdateThreadIdentityDtoBuilder
    implements
        Builder<UpdateThreadIdentityDto, UpdateThreadIdentityDtoBuilder> {
  _$UpdateThreadIdentityDto? _$v;

  bool? _clearNickname;
  bool? get clearNickname => _$this._clearNickname;
  set clearNickname(bool? clearNickname) =>
      _$this._clearNickname = clearNickname;

  bool? _clearAvatar;
  bool? get clearAvatar => _$this._clearAvatar;
  set clearAvatar(bool? clearAvatar) => _$this._clearAvatar = clearAvatar;

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

  UpdateThreadIdentityDtoBuilder() {
    UpdateThreadIdentityDto._defaults(this);
  }

  UpdateThreadIdentityDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clearNickname = $v.clearNickname;
      _clearAvatar = $v.clearAvatar;
      _nickname = $v.nickname;
      _avatarMediaId = $v.avatarMediaId;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateThreadIdentityDto other) {
    _$v = other as _$UpdateThreadIdentityDto;
  }

  @override
  void update(void Function(UpdateThreadIdentityDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateThreadIdentityDto build() => _build();

  _$UpdateThreadIdentityDto _build() {
    final _$result =
        _$v ??
        _$UpdateThreadIdentityDto._(
          clearNickname: clearNickname,
          clearAvatar: clearAvatar,
          nickname: nickname,
          avatarMediaId: avatarMediaId,
          version: version,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
