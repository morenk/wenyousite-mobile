// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_liker_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationLikerResponseDto extends NotificationLikerResponseDto {
  @override
  final String userId;
  @override
  final String username;

  factory _$NotificationLikerResponseDto([
    void Function(NotificationLikerResponseDtoBuilder)? updates,
  ]) => (NotificationLikerResponseDtoBuilder()..update(updates))._build();

  _$NotificationLikerResponseDto._({
    required this.userId,
    required this.username,
  }) : super._();
  @override
  NotificationLikerResponseDto rebuild(
    void Function(NotificationLikerResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationLikerResponseDtoBuilder toBuilder() =>
      NotificationLikerResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationLikerResponseDto &&
        userId == other.userId &&
        username == other.username;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationLikerResponseDto')
          ..add('userId', userId)
          ..add('username', username))
        .toString();
  }
}

class NotificationLikerResponseDtoBuilder
    implements
        Builder<
          NotificationLikerResponseDto,
          NotificationLikerResponseDtoBuilder
        > {
  _$NotificationLikerResponseDto? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  NotificationLikerResponseDtoBuilder() {
    NotificationLikerResponseDto._defaults(this);
  }

  NotificationLikerResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _username = $v.username;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationLikerResponseDto other) {
    _$v = other as _$NotificationLikerResponseDto;
  }

  @override
  void update(void Function(NotificationLikerResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationLikerResponseDto build() => _build();

  _$NotificationLikerResponseDto _build() {
    final _$result =
        _$v ??
        _$NotificationLikerResponseDto._(
          userId: BuiltValueNullFieldError.checkNotNull(
            userId,
            r'NotificationLikerResponseDto',
            'userId',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'NotificationLikerResponseDto',
            'username',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
