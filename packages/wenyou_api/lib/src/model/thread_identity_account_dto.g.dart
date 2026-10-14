// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_identity_account_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadIdentityAccountDto extends ThreadIdentityAccountDto {
  @override
  final String id;
  @override
  final String username;
  @override
  final String? avatar;

  factory _$ThreadIdentityAccountDto([
    void Function(ThreadIdentityAccountDtoBuilder)? updates,
  ]) => (ThreadIdentityAccountDtoBuilder()..update(updates))._build();

  _$ThreadIdentityAccountDto._({
    required this.id,
    required this.username,
    this.avatar,
  }) : super._();
  @override
  ThreadIdentityAccountDto rebuild(
    void Function(ThreadIdentityAccountDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadIdentityAccountDtoBuilder toBuilder() =>
      ThreadIdentityAccountDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadIdentityAccountDto &&
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
    return (newBuiltValueToStringHelper(r'ThreadIdentityAccountDto')
          ..add('id', id)
          ..add('username', username)
          ..add('avatar', avatar))
        .toString();
  }
}

class ThreadIdentityAccountDtoBuilder
    implements
        Builder<ThreadIdentityAccountDto, ThreadIdentityAccountDtoBuilder> {
  _$ThreadIdentityAccountDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  ThreadIdentityAccountDtoBuilder() {
    ThreadIdentityAccountDto._defaults(this);
  }

  ThreadIdentityAccountDtoBuilder get _$this {
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
  void replace(ThreadIdentityAccountDto other) {
    _$v = other as _$ThreadIdentityAccountDto;
  }

  @override
  void update(void Function(ThreadIdentityAccountDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadIdentityAccountDto build() => _build();

  _$ThreadIdentityAccountDto _build() {
    final _$result =
        _$v ??
        _$ThreadIdentityAccountDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'ThreadIdentityAccountDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'ThreadIdentityAccountDto',
            'username',
          ),
          avatar: avatar,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
