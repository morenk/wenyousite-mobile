// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_from_user_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationFromUserResponseDto
    extends NotificationFromUserResponseDto {
  @override
  final String id;
  @override
  final String username;
  @override
  final String? avatar;
  @override
  final DateTime? deletedAt;

  factory _$NotificationFromUserResponseDto([
    void Function(NotificationFromUserResponseDtoBuilder)? updates,
  ]) => (NotificationFromUserResponseDtoBuilder()..update(updates))._build();

  _$NotificationFromUserResponseDto._({
    required this.id,
    required this.username,
    this.avatar,
    this.deletedAt,
  }) : super._();
  @override
  NotificationFromUserResponseDto rebuild(
    void Function(NotificationFromUserResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationFromUserResponseDtoBuilder toBuilder() =>
      NotificationFromUserResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationFromUserResponseDto &&
        id == other.id &&
        username == other.username &&
        avatar == other.avatar &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationFromUserResponseDto')
          ..add('id', id)
          ..add('username', username)
          ..add('avatar', avatar)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class NotificationFromUserResponseDtoBuilder
    implements
        Builder<
          NotificationFromUserResponseDto,
          NotificationFromUserResponseDtoBuilder
        > {
  _$NotificationFromUserResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  NotificationFromUserResponseDtoBuilder() {
    NotificationFromUserResponseDto._defaults(this);
  }

  NotificationFromUserResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _avatar = $v.avatar;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationFromUserResponseDto other) {
    _$v = other as _$NotificationFromUserResponseDto;
  }

  @override
  void update(void Function(NotificationFromUserResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationFromUserResponseDto build() => _build();

  _$NotificationFromUserResponseDto _build() {
    final _$result =
        _$v ??
        _$NotificationFromUserResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'NotificationFromUserResponseDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'NotificationFromUserResponseDto',
            'username',
          ),
          avatar: avatar,
          deletedAt: deletedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
