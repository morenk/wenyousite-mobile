// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_message_user_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DirectMessageUserResponseDto extends DirectMessageUserResponseDto {
  @override
  final String id;
  @override
  final String username;
  @override
  final String? avatar;
  @override
  final bool isDeactivated;

  factory _$DirectMessageUserResponseDto([
    void Function(DirectMessageUserResponseDtoBuilder)? updates,
  ]) => (DirectMessageUserResponseDtoBuilder()..update(updates))._build();

  _$DirectMessageUserResponseDto._({
    required this.id,
    required this.username,
    this.avatar,
    required this.isDeactivated,
  }) : super._();
  @override
  DirectMessageUserResponseDto rebuild(
    void Function(DirectMessageUserResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectMessageUserResponseDtoBuilder toBuilder() =>
      DirectMessageUserResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectMessageUserResponseDto &&
        id == other.id &&
        username == other.username &&
        avatar == other.avatar &&
        isDeactivated == other.isDeactivated;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jc(_$hash, isDeactivated.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DirectMessageUserResponseDto')
          ..add('id', id)
          ..add('username', username)
          ..add('avatar', avatar)
          ..add('isDeactivated', isDeactivated))
        .toString();
  }
}

class DirectMessageUserResponseDtoBuilder
    implements
        Builder<
          DirectMessageUserResponseDto,
          DirectMessageUserResponseDtoBuilder
        > {
  _$DirectMessageUserResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  bool? _isDeactivated;
  bool? get isDeactivated => _$this._isDeactivated;
  set isDeactivated(bool? isDeactivated) =>
      _$this._isDeactivated = isDeactivated;

  DirectMessageUserResponseDtoBuilder() {
    DirectMessageUserResponseDto._defaults(this);
  }

  DirectMessageUserResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _avatar = $v.avatar;
      _isDeactivated = $v.isDeactivated;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DirectMessageUserResponseDto other) {
    _$v = other as _$DirectMessageUserResponseDto;
  }

  @override
  void update(void Function(DirectMessageUserResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DirectMessageUserResponseDto build() => _build();

  _$DirectMessageUserResponseDto _build() {
    final _$result =
        _$v ??
        _$DirectMessageUserResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'DirectMessageUserResponseDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'DirectMessageUserResponseDto',
            'username',
          ),
          avatar: avatar,
          isDeactivated: BuiltValueNullFieldError.checkNotNull(
            isDeactivated,
            r'DirectMessageUserResponseDto',
            'isDeactivated',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
