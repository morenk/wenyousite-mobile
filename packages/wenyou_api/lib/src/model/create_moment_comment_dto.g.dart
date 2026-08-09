// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_moment_comment_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateMomentCommentDto extends CreateMomentCommentDto {
  @override
  final String? content;
  @override
  final String? mediaId;
  @override
  final String? stickerAssetId;
  @override
  final String? replyToCommentId;
  @override
  final String clientRequestId;

  factory _$CreateMomentCommentDto([
    void Function(CreateMomentCommentDtoBuilder)? updates,
  ]) => (CreateMomentCommentDtoBuilder()..update(updates))._build();

  _$CreateMomentCommentDto._({
    this.content,
    this.mediaId,
    this.stickerAssetId,
    this.replyToCommentId,
    required this.clientRequestId,
  }) : super._();
  @override
  CreateMomentCommentDto rebuild(
    void Function(CreateMomentCommentDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateMomentCommentDtoBuilder toBuilder() =>
      CreateMomentCommentDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateMomentCommentDto &&
        content == other.content &&
        mediaId == other.mediaId &&
        stickerAssetId == other.stickerAssetId &&
        replyToCommentId == other.replyToCommentId &&
        clientRequestId == other.clientRequestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jc(_$hash, stickerAssetId.hashCode);
    _$hash = $jc(_$hash, replyToCommentId.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateMomentCommentDto')
          ..add('content', content)
          ..add('mediaId', mediaId)
          ..add('stickerAssetId', stickerAssetId)
          ..add('replyToCommentId', replyToCommentId)
          ..add('clientRequestId', clientRequestId))
        .toString();
  }
}

class CreateMomentCommentDtoBuilder
    implements Builder<CreateMomentCommentDto, CreateMomentCommentDtoBuilder> {
  _$CreateMomentCommentDto? _$v;

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

  String? _replyToCommentId;
  String? get replyToCommentId => _$this._replyToCommentId;
  set replyToCommentId(String? replyToCommentId) =>
      _$this._replyToCommentId = replyToCommentId;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  CreateMomentCommentDtoBuilder() {
    CreateMomentCommentDto._defaults(this);
  }

  CreateMomentCommentDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _mediaId = $v.mediaId;
      _stickerAssetId = $v.stickerAssetId;
      _replyToCommentId = $v.replyToCommentId;
      _clientRequestId = $v.clientRequestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateMomentCommentDto other) {
    _$v = other as _$CreateMomentCommentDto;
  }

  @override
  void update(void Function(CreateMomentCommentDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateMomentCommentDto build() => _build();

  _$CreateMomentCommentDto _build() {
    final _$result =
        _$v ??
        _$CreateMomentCommentDto._(
          content: content,
          mediaId: mediaId,
          stickerAssetId: stickerAssetId,
          replyToCommentId: replyToCommentId,
          clientRequestId: BuiltValueNullFieldError.checkNotNull(
            clientRequestId,
            r'CreateMomentCommentDto',
            'clientRequestId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
