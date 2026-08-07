// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_owner_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InviteOwnerResponseDto extends InviteOwnerResponseDto {
  @override
  final String id;
  @override
  final String username;
  @override
  final String? avatar;

  factory _$InviteOwnerResponseDto([
    void Function(InviteOwnerResponseDtoBuilder)? updates,
  ]) => (InviteOwnerResponseDtoBuilder()..update(updates))._build();

  _$InviteOwnerResponseDto._({
    required this.id,
    required this.username,
    this.avatar,
  }) : super._();
  @override
  InviteOwnerResponseDto rebuild(
    void Function(InviteOwnerResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  InviteOwnerResponseDtoBuilder toBuilder() =>
      InviteOwnerResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InviteOwnerResponseDto &&
        id == other.id &&
        username == other.username &&
        avatar == other.avatar;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InviteOwnerResponseDto')
          ..add('id', id)
          ..add('username', username)
          ..add('avatar', avatar))
        .toString();
  }
}

class InviteOwnerResponseDtoBuilder
    implements Builder<InviteOwnerResponseDto, InviteOwnerResponseDtoBuilder> {
  _$InviteOwnerResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  InviteOwnerResponseDtoBuilder() {
    InviteOwnerResponseDto._defaults(this);
  }

  InviteOwnerResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _avatar = $v.avatar;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InviteOwnerResponseDto other) {
    _$v = other as _$InviteOwnerResponseDto;
  }

  @override
  void update(void Function(InviteOwnerResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InviteOwnerResponseDto build() => _build();

  _$InviteOwnerResponseDto _build() {
    final _$result =
        _$v ??
        _$InviteOwnerResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'InviteOwnerResponseDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'InviteOwnerResponseDto',
            'username',
          ),
          avatar: avatar,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
