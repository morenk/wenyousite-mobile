// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_direct_message_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateDirectMessageDto extends CreateDirectMessageDto {
  @override
  final String? content;
  @override
  final String? mediaId;
  @override
  final String? stickerAssetId;
  @override
  final String clientRequestId;

  factory _$CreateDirectMessageDto([
    void Function(CreateDirectMessageDtoBuilder)? updates,
  ]) => (CreateDirectMessageDtoBuilder()..update(updates))._build();

  _$CreateDirectMessageDto._({
    this.content,
    this.mediaId,
    this.stickerAssetId,
    required this.clientRequestId,
  }) : super._();
  @override
  CreateDirectMessageDto rebuild(
    void Function(CreateDirectMessageDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateDirectMessageDtoBuilder toBuilder() =>
      CreateDirectMessageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateDirectMessageDto &&
        content == other.content &&
        mediaId == other.mediaId &&
        stickerAssetId == other.stickerAssetId &&
        clientRequestId == other.clientRequestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jc(_$hash, stickerAssetId.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateDirectMessageDto')
          ..add('content', content)
          ..add('mediaId', mediaId)
          ..add('stickerAssetId', stickerAssetId)
          ..add('clientRequestId', clientRequestId))
        .toString();
  }
}

class CreateDirectMessageDtoBuilder
    implements Builder<CreateDirectMessageDto, CreateDirectMessageDtoBuilder> {
  _$CreateDirectMessageDto? _$v;

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

  CreateDirectMessageDtoBuilder() {
    CreateDirectMessageDto._defaults(this);
  }

  CreateDirectMessageDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _mediaId = $v.mediaId;
      _stickerAssetId = $v.stickerAssetId;
      _clientRequestId = $v.clientRequestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateDirectMessageDto other) {
    _$v = other as _$CreateDirectMessageDto;
  }

  @override
  void update(void Function(CreateDirectMessageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateDirectMessageDto build() => _build();

  _$CreateDirectMessageDto _build() {
    final _$result =
        _$v ??
        _$CreateDirectMessageDto._(
          content: content,
          mediaId: mediaId,
          stickerAssetId: stickerAssetId,
          clientRequestId: BuiltValueNullFieldError.checkNotNull(
            clientRequestId,
            r'CreateDirectMessageDto',
            'clientRequestId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
