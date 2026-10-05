// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_rp_identity_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateRpIdentityDto extends UpdateRpIdentityDto {
  @override
  final bool? clearNickname;
  @override
  final bool? clearAvatar;
  @override
  final String? nickname;
  @override
  final String? avatarMediaId;
  @override
  final num version;

  factory _$UpdateRpIdentityDto([
    void Function(UpdateRpIdentityDtoBuilder)? updates,
  ]) => (UpdateRpIdentityDtoBuilder()..update(updates))._build();

  _$UpdateRpIdentityDto._({
    this.clearNickname,
    this.clearAvatar,
    this.nickname,
    this.avatarMediaId,
    required this.version,
  }) : super._();
  @override
  UpdateRpIdentityDto rebuild(
    void Function(UpdateRpIdentityDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdateRpIdentityDtoBuilder toBuilder() =>
      UpdateRpIdentityDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateRpIdentityDto &&
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
    return (newBuiltValueToStringHelper(r'UpdateRpIdentityDto')
          ..add('clearNickname', clearNickname)
          ..add('clearAvatar', clearAvatar)
          ..add('nickname', nickname)
          ..add('avatarMediaId', avatarMediaId)
          ..add('version', version))
        .toString();
  }
}

class UpdateRpIdentityDtoBuilder
    implements Builder<UpdateRpIdentityDto, UpdateRpIdentityDtoBuilder> {
  _$UpdateRpIdentityDto? _$v;

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

  UpdateRpIdentityDtoBuilder() {
    UpdateRpIdentityDto._defaults(this);
  }

  UpdateRpIdentityDtoBuilder get _$this {
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
  void replace(UpdateRpIdentityDto other) {
    _$v = other as _$UpdateRpIdentityDto;
  }

  @override
  void update(void Function(UpdateRpIdentityDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateRpIdentityDto build() => _build();

  _$UpdateRpIdentityDto _build() {
    final _$result =
        _$v ??
        _$UpdateRpIdentityDto._(
          clearNickname: clearNickname,
          clearAvatar: clearAvatar,
          nickname: nickname,
          avatarMediaId: avatarMediaId,
          version: BuiltValueNullFieldError.checkNotNull(
            version,
            r'UpdateRpIdentityDto',
            'version',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
