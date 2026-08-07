// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_direct_conversation_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateDirectConversationDto extends CreateDirectConversationDto {
  @override
  final String? content;
  @override
  final String? mediaId;
  @override
  final String? stickerAssetId;
  @override
  final String clientRequestId;
  @override
  final String recipientId;

  factory _$CreateDirectConversationDto([
    void Function(CreateDirectConversationDtoBuilder)? updates,
  ]) => (CreateDirectConversationDtoBuilder()..update(updates))._build();

  _$CreateDirectConversationDto._({
    this.content,
    this.mediaId,
    this.stickerAssetId,
    required this.clientRequestId,
    required this.recipientId,
  }) : super._();
  @override
  CreateDirectConversationDto rebuild(
    void Function(CreateDirectConversationDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateDirectConversationDtoBuilder toBuilder() =>
      CreateDirectConversationDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateDirectConversationDto &&
        content == other.content &&
        mediaId == other.mediaId &&
        stickerAssetId == other.stickerAssetId &&
        clientRequestId == other.clientRequestId &&
        recipientId == other.recipientId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jc(_$hash, stickerAssetId.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jc(_$hash, recipientId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateDirectConversationDto')
          ..add('content', content)
          ..add('mediaId', mediaId)
          ..add('stickerAssetId', stickerAssetId)
          ..add('clientRequestId', clientRequestId)
          ..add('recipientId', recipientId))
        .toString();
  }
}

class CreateDirectConversationDtoBuilder
    implements
        Builder<
          CreateDirectConversationDto,
          CreateDirectConversationDtoBuilder
        > {
  _$CreateDirectConversationDto? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  String? _stickerAssetId;
  String? get stickerAssetId => _$this._stickerAssetId;
  set stickerAssetId(String? stickerAssetId) =>
      _$this._stickerAssetId = stickerAssetId;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  String? _recipientId;
  String? get recipientId => _$this._recipientId;
  set recipientId(String? recipientId) => _$this._recipientId = recipientId;

  CreateDirectConversationDtoBuilder() {
    CreateDirectConversationDto._defaults(this);
  }

  CreateDirectConversationDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _mediaId = $v.mediaId;
      _stickerAssetId = $v.stickerAssetId;
      _clientRequestId = $v.clientRequestId;
      _recipientId = $v.recipientId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateDirectConversationDto other) {
    _$v = other as _$CreateDirectConversationDto;
  }

  @override
  void update(void Function(CreateDirectConversationDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateDirectConversationDto build() => _build();

  _$CreateDirectConversationDto _build() {
    final _$result =
        _$v ??
        _$CreateDirectConversationDto._(
          content: content,
          mediaId: mediaId,
          stickerAssetId: stickerAssetId,
          clientRequestId: BuiltValueNullFieldError.checkNotNull(
            clientRequestId,
            r'CreateDirectConversationDto',
            'clientRequestId',
          ),
          recipientId: BuiltValueNullFieldError.checkNotNull(
            recipientId,
            r'CreateDirectConversationDto',
            'recipientId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
