// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_rp_identity_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateRpIdentityDto extends CreateRpIdentityDto {
  @override
  final bool? clearNickname;
  @override
  final bool? clearAvatar;
  @override
  final String? nickname;
  @override
  final String? avatarMediaId;

  factory _$CreateRpIdentityDto([
    void Function(CreateRpIdentityDtoBuilder)? updates,
  ]) => (CreateRpIdentityDtoBuilder()..update(updates))._build();

  _$CreateRpIdentityDto._({
    this.clearNickname,
    this.clearAvatar,
    this.nickname,
    this.avatarMediaId,
  }) : super._();
  @override
  CreateRpIdentityDto rebuild(
    void Function(CreateRpIdentityDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateRpIdentityDtoBuilder toBuilder() =>
      CreateRpIdentityDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateRpIdentityDto &&
        clearNickname == other.clearNickname &&
        clearAvatar == other.clearAvatar &&
        nickname == other.nickname &&
        avatarMediaId == other.avatarMediaId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clearNickname.hashCode);
    _$hash = $jc(_$hash, clearAvatar.hashCode);
    _$hash = $jc(_$hash, nickname.hashCode);
    _$hash = $jc(_$hash, avatarMediaId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateRpIdentityDto')
          ..add('clearNickname', clearNickname)
          ..add('clearAvatar', clearAvatar)
          ..add('nickname', nickname)
          ..add('avatarMediaId', avatarMediaId))
        .toString();
  }
}

class CreateRpIdentityDtoBuilder
    implements Builder<CreateRpIdentityDto, CreateRpIdentityDtoBuilder> {
  _$CreateRpIdentityDto? _$v;

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

  CreateRpIdentityDtoBuilder() {
    CreateRpIdentityDto._defaults(this);
  }

  CreateRpIdentityDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clearNickname = $v.clearNickname;
      _clearAvatar = $v.clearAvatar;
      _nickname = $v.nickname;
      _avatarMediaId = $v.avatarMediaId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateRpIdentityDto other) {
    _$v = other as _$CreateRpIdentityDto;
  }

  @override
  void update(void Function(CreateRpIdentityDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateRpIdentityDto build() => _build();

  _$CreateRpIdentityDto _build() {
    final _$result =
        _$v ??
        _$CreateRpIdentityDto._(
          clearNickname: clearNickname,
          clearAvatar: clearAvatar,
          nickname: nickname,
          avatarMediaId: avatarMediaId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
