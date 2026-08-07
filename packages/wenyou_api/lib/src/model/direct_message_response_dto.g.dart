// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_message_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DirectMessageResponseDto extends DirectMessageResponseDto {
  @override
  final String id;
  @override
  final String conversationId;
  @override
  final String senderId;
  @override
  final String recipientId;
  @override
  final String? content;
  @override
  final DirectMessageMediaResponseDto? media;
  @override
  final DirectMessageStickerResponseDto? sticker;
  @override
  final DateTime? recalledAt;
  @override
  final DateTime createdAt;

  factory _$DirectMessageResponseDto([
    void Function(DirectMessageResponseDtoBuilder)? updates,
  ]) => (DirectMessageResponseDtoBuilder()..update(updates))._build();

  _$DirectMessageResponseDto._({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.recipientId,
    this.content,
    this.media,
    this.sticker,
    this.recalledAt,
    required this.createdAt,
  }) : super._();
  @override
  DirectMessageResponseDto rebuild(
    void Function(DirectMessageResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectMessageResponseDtoBuilder toBuilder() =>
      DirectMessageResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectMessageResponseDto &&
        id == other.id &&
        conversationId == other.conversationId &&
        senderId == other.senderId &&
        recipientId == other.recipientId &&
        content == other.content &&
        media == other.media &&
        sticker == other.sticker &&
        recalledAt == other.recalledAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, conversationId.hashCode);
    _$hash = $jc(_$hash, senderId.hashCode);
    _$hash = $jc(_$hash, recipientId.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, media.hashCode);
    _$hash = $jc(_$hash, sticker.hashCode);
    _$hash = $jc(_$hash, recalledAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DirectMessageResponseDto')
          ..add('id', id)
          ..add('conversationId', conversationId)
          ..add('senderId', senderId)
          ..add('recipientId', recipientId)
          ..add('content', content)
          ..add('media', media)
          ..add('sticker', sticker)
          ..add('recalledAt', recalledAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class DirectMessageResponseDtoBuilder
    implements
        Builder<DirectMessageResponseDto, DirectMessageResponseDtoBuilder> {
  _$DirectMessageResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _conversationId;
  String? get conversationId => _$this._conversationId;
  set conversationId(String? conversationId) =>
      _$this._conversationId = conversationId;

  String? _senderId;
  String? get senderId => _$this._senderId;
  set senderId(String? senderId) => _$this._senderId = senderId;

  String? _recipientId;
  String? get recipientId => _$this._recipientId;
  set recipientId(String? recipientId) => _$this._recipientId = recipientId;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  DirectMessageMediaResponseDtoBuilder? _media;
  DirectMessageMediaResponseDtoBuilder get media =>
      _$this._media ??= DirectMessageMediaResponseDtoBuilder();
  set media(DirectMessageMediaResponseDtoBuilder? media) =>
      _$this._media = media;

  DirectMessageStickerResponseDtoBuilder? _sticker;
  DirectMessageStickerResponseDtoBuilder get sticker =>
      _$this._sticker ??= DirectMessageStickerResponseDtoBuilder();
  set sticker(DirectMessageStickerResponseDtoBuilder? sticker) =>
      _$this._sticker = sticker;

  DateTime? _recalledAt;
  DateTime? get recalledAt => _$this._recalledAt;
  set recalledAt(DateTime? recalledAt) => _$this._recalledAt = recalledAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DirectMessageResponseDtoBuilder() {
    DirectMessageResponseDto._defaults(this);
  }

  DirectMessageResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _conversationId = $v.conversationId;
      _senderId = $v.senderId;
      _recipientId = $v.recipientId;
      _content = $v.content;
      _media = $v.media?.toBuilder();
      _sticker = $v.sticker?.toBuilder();
      _recalledAt = $v.recalledAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DirectMessageResponseDto other) {
    _$v = other as _$DirectMessageResponseDto;
  }

  @override
  void update(void Function(DirectMessageResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DirectMessageResponseDto build() => _build();

  _$DirectMessageResponseDto _build() {
    _$DirectMessageResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$DirectMessageResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'DirectMessageResponseDto',
              'id',
            ),
            conversationId: BuiltValueNullFieldError.checkNotNull(
              conversationId,
              r'DirectMessageResponseDto',
              'conversationId',
            ),
            senderId: BuiltValueNullFieldError.checkNotNull(
              senderId,
              r'DirectMessageResponseDto',
              'senderId',
            ),
            recipientId: BuiltValueNullFieldError.checkNotNull(
              recipientId,
              r'DirectMessageResponseDto',
              'recipientId',
            ),
            content: content,
            media: _media?.build(),
            sticker: _sticker?.build(),
            recalledAt: recalledAt,
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'DirectMessageResponseDto',
              'createdAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'media';
        _media?.build();
        _$failedField = 'sticker';
        _sticker?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DirectMessageResponseDto',
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
