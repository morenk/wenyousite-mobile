// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_system_notification_history_item_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminSystemNotificationHistoryItemDto
    extends AdminSystemNotificationHistoryItemDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String? content;
  @override
  final BuiltMap<String, JsonObject?>? payload;
  @override
  final String? threadId;
  @override
  final bool isRead;
  @override
  final DateTime createdAt;
  @override
  final AdminNotificationUserResponseDto user;

  factory _$AdminSystemNotificationHistoryItemDto([
    void Function(AdminSystemNotificationHistoryItemDtoBuilder)? updates,
  ]) => (AdminSystemNotificationHistoryItemDtoBuilder()..update(updates))
      ._build();

  _$AdminSystemNotificationHistoryItemDto._({
    required this.id,
    required this.userId,
    this.content,
    this.payload,
    this.threadId,
    required this.isRead,
    required this.createdAt,
    required this.user,
  }) : super._();
  @override
  AdminSystemNotificationHistoryItemDto rebuild(
    void Function(AdminSystemNotificationHistoryItemDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminSystemNotificationHistoryItemDtoBuilder toBuilder() =>
      AdminSystemNotificationHistoryItemDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminSystemNotificationHistoryItemDto &&
        id == other.id &&
        userId == other.userId &&
        content == other.content &&
        payload == other.payload &&
        threadId == other.threadId &&
        isRead == other.isRead &&
        createdAt == other.createdAt &&
        user == other.user;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, isRead.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminSystemNotificationHistoryItemDto',
          )
          ..add('id', id)
          ..add('userId', userId)
          ..add('content', content)
          ..add('payload', payload)
          ..add('threadId', threadId)
          ..add('isRead', isRead)
          ..add('createdAt', createdAt)
          ..add('user', user))
        .toString();
  }
}

class AdminSystemNotificationHistoryItemDtoBuilder
    implements
        Builder<
          AdminSystemNotificationHistoryItemDto,
          AdminSystemNotificationHistoryItemDtoBuilder
        > {
  _$AdminSystemNotificationHistoryItemDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  MapBuilder<String, JsonObject?>? _payload;
  MapBuilder<String, JsonObject?> get payload =>
      _$this._payload ??= MapBuilder<String, JsonObject?>();
  set payload(MapBuilder<String, JsonObject?>? payload) =>
      _$this._payload = payload;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  bool? _isRead;
  bool? get isRead => _$this._isRead;
  set isRead(bool? isRead) => _$this._isRead = isRead;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AdminNotificationUserResponseDtoBuilder? _user;
  AdminNotificationUserResponseDtoBuilder get user =>
      _$this._user ??= AdminNotificationUserResponseDtoBuilder();
  set user(AdminNotificationUserResponseDtoBuilder? user) =>
      _$this._user = user;

  AdminSystemNotificationHistoryItemDtoBuilder() {
    AdminSystemNotificationHistoryItemDto._defaults(this);
  }

  AdminSystemNotificationHistoryItemDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _content = $v.content;
      _payload = $v.payload?.toBuilder();
      _threadId = $v.threadId;
      _isRead = $v.isRead;
      _createdAt = $v.createdAt;
      _user = $v.user.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminSystemNotificationHistoryItemDto other) {
    _$v = other as _$AdminSystemNotificationHistoryItemDto;
  }

  @override
  void update(
    void Function(AdminSystemNotificationHistoryItemDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminSystemNotificationHistoryItemDto build() => _build();

  _$AdminSystemNotificationHistoryItemDto _build() {
    _$AdminSystemNotificationHistoryItemDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminSystemNotificationHistoryItemDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'AdminSystemNotificationHistoryItemDto',
              'id',
            ),
            userId: BuiltValueNullFieldError.checkNotNull(
              userId,
              r'AdminSystemNotificationHistoryItemDto',
              'userId',
            ),
            content: content,
            payload: _payload?.build(),
            threadId: threadId,
            isRead: BuiltValueNullFieldError.checkNotNull(
              isRead,
              r'AdminSystemNotificationHistoryItemDto',
              'isRead',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'AdminSystemNotificationHistoryItemDto',
              'createdAt',
            ),
            user: user.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        _payload?.build();

        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminSystemNotificationHistoryItemDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
