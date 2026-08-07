// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_notification_user_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminNotificationUserResponseDto
    extends AdminNotificationUserResponseDto {
  @override
  final String id;
  @override
  final String username;
  @override
  final DateTime? deletedAt;

  factory _$AdminNotificationUserResponseDto([
    void Function(AdminNotificationUserResponseDtoBuilder)? updates,
  ]) => (AdminNotificationUserResponseDtoBuilder()..update(updates))._build();

  _$AdminNotificationUserResponseDto._({
    required this.id,
    required this.username,
    this.deletedAt,
  }) : super._();
  @override
  AdminNotificationUserResponseDto rebuild(
    void Function(AdminNotificationUserResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminNotificationUserResponseDtoBuilder toBuilder() =>
      AdminNotificationUserResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminNotificationUserResponseDto &&
        id == other.id &&
        username == other.username &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminNotificationUserResponseDto')
          ..add('id', id)
          ..add('username', username)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class AdminNotificationUserResponseDtoBuilder
    implements
        Builder<
          AdminNotificationUserResponseDto,
          AdminNotificationUserResponseDtoBuilder
        > {
  _$AdminNotificationUserResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  AdminNotificationUserResponseDtoBuilder() {
    AdminNotificationUserResponseDto._defaults(this);
  }

  AdminNotificationUserResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminNotificationUserResponseDto other) {
    _$v = other as _$AdminNotificationUserResponseDto;
  }

  @override
  void update(void Function(AdminNotificationUserResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminNotificationUserResponseDto build() => _build();

  _$AdminNotificationUserResponseDto _build() {
    final _$result =
        _$v ??
        _$AdminNotificationUserResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'AdminNotificationUserResponseDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'AdminNotificationUserResponseDto',
            'username',
          ),
          deletedAt: deletedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
