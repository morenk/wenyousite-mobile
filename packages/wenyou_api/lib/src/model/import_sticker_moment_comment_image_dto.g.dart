// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_sticker_moment_comment_image_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImportStickerMomentCommentImageDto
    extends ImportStickerMomentCommentImageDto {
  @override
  final String momentCommentId;
  @override
  final String mediaId;
  @override
  final String clientRequestId;

  factory _$ImportStickerMomentCommentImageDto([
    void Function(ImportStickerMomentCommentImageDtoBuilder)? updates,
  ]) => (ImportStickerMomentCommentImageDtoBuilder()..update(updates))._build();

  _$ImportStickerMomentCommentImageDto._({
    required this.momentCommentId,
    required this.mediaId,
    required this.clientRequestId,
  }) : super._();
  @override
  ImportStickerMomentCommentImageDto rebuild(
    void Function(ImportStickerMomentCommentImageDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ImportStickerMomentCommentImageDtoBuilder toBuilder() =>
      ImportStickerMomentCommentImageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImportStickerMomentCommentImageDto &&
        momentCommentId == other.momentCommentId &&
        mediaId == other.mediaId &&
        clientRequestId == other.clientRequestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, momentCommentId.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ImportStickerMomentCommentImageDto')
          ..add('momentCommentId', momentCommentId)
          ..add('mediaId', mediaId)
          ..add('clientRequestId', clientRequestId))
        .toString();
  }
}

class ImportStickerMomentCommentImageDtoBuilder
    implements
        Builder<
          ImportStickerMomentCommentImageDto,
          ImportStickerMomentCommentImageDtoBuilder
        > {
  _$ImportStickerMomentCommentImageDto? _$v;

  String? _momentCommentId;
  String? get momentCommentId => _$this._momentCommentId;
  set momentCommentId(String? momentCommentId) =>
      _$this._momentCommentId = momentCommentId;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  ImportStickerMomentCommentImageDtoBuilder() {
    ImportStickerMomentCommentImageDto._defaults(this);
  }

  ImportStickerMomentCommentImageDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _momentCommentId = $v.momentCommentId;
      _mediaId = $v.mediaId;
      _clientRequestId = $v.clientRequestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImportStickerMomentCommentImageDto other) {
    _$v = other as _$ImportStickerMomentCommentImageDto;
  }

  @override
  void update(
    void Function(ImportStickerMomentCommentImageDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ImportStickerMomentCommentImageDto build() => _build();

  _$ImportStickerMomentCommentImageDto _build() {
    final _$result =
        _$v ??
        _$ImportStickerMomentCommentImageDto._(
          momentCommentId: BuiltValueNullFieldError.checkNotNull(
            momentCommentId,
            r'ImportStickerMomentCommentImageDto',
            'momentCommentId',
          ),
          mediaId: BuiltValueNullFieldError.checkNotNull(
            mediaId,
            r'ImportStickerMomentCommentImageDto',
            'mediaId',
          ),
          clientRequestId: BuiltValueNullFieldError.checkNotNull(
            clientRequestId,
            r'ImportStickerMomentCommentImageDto',
            'clientRequestId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
