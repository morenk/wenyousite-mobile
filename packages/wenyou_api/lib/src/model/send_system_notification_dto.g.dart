// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_system_notification_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SendSystemNotificationDto extends SendSystemNotificationDto {
  @override
  final String content;
  @override
  final JsonObject? payload;
  @override
  final BuiltList<String>? recipientIds;
  @override
  final UserConditionDto? conditions;
  @override
  final String? threadId;

  factory _$SendSystemNotificationDto([
    void Function(SendSystemNotificationDtoBuilder)? updates,
  ]) => (SendSystemNotificationDtoBuilder()..update(updates))._build();

  _$SendSystemNotificationDto._({
    required this.content,
    this.payload,
    this.recipientIds,
    this.conditions,
    this.threadId,
  }) : super._();
  @override
  SendSystemNotificationDto rebuild(
    void Function(SendSystemNotificationDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SendSystemNotificationDtoBuilder toBuilder() =>
      SendSystemNotificationDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SendSystemNotificationDto &&
        content == other.content &&
        payload == other.payload &&
        recipientIds == other.recipientIds &&
        conditions == other.conditions &&
        threadId == other.threadId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jc(_$hash, recipientIds.hashCode);
    _$hash = $jc(_$hash, conditions.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SendSystemNotificationDto')
          ..add('content', content)
          ..add('payload', payload)
          ..add('recipientIds', recipientIds)
          ..add('conditions', conditions)
          ..add('threadId', threadId))
        .toString();
  }
}

class SendSystemNotificationDtoBuilder
    implements
        Builder<SendSystemNotificationDto, SendSystemNotificationDtoBuilder> {
  _$SendSystemNotificationDto? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  JsonObject? _payload;
  JsonObject? get payload => _$this._payload;
  set payload(JsonObject? payload) => _$this._payload = payload;

  ListBuilder<String>? _recipientIds;
  ListBuilder<String> get recipientIds =>
      _$this._recipientIds ??= ListBuilder<String>();
  set recipientIds(ListBuilder<String>? recipientIds) =>
      _$this._recipientIds = recipientIds;

  UserConditionDtoBuilder? _conditions;
  UserConditionDtoBuilder get conditions =>
      _$this._conditions ??= UserConditionDtoBuilder();
  set conditions(UserConditionDtoBuilder? conditions) =>
      _$this._conditions = conditions;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  SendSystemNotificationDtoBuilder() {
    SendSystemNotificationDto._defaults(this);
  }

  SendSystemNotificationDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _payload = $v.payload;
      _recipientIds = $v.recipientIds?.toBuilder();
      _conditions = $v.conditions?.toBuilder();
      _threadId = $v.threadId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SendSystemNotificationDto other) {
    _$v = other as _$SendSystemNotificationDto;
  }

  @override
  void update(void Function(SendSystemNotificationDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SendSystemNotificationDto build() => _build();

  _$SendSystemNotificationDto _build() {
    _$SendSystemNotificationDto _$result;
    try {
      _$result =
          _$v ??
          _$SendSystemNotificationDto._(
            content: BuiltValueNullFieldError.checkNotNull(
              content,
              r'SendSystemNotificationDto',
              'content',
            ),
            payload: payload,
            recipientIds: _recipientIds?.build(),
            conditions: _conditions?.build(),
            threadId: threadId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'recipientIds';
        _recipientIds?.build();
        _$failedField = 'conditions';
        _conditions?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SendSystemNotificationDto',
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
