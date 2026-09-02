// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_sticker_moment_image_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImportStickerMomentImageDto extends ImportStickerMomentImageDto {
  @override
  final String momentId;
  @override
  final String mediaId;
  @override
  final String clientRequestId;

  factory _$ImportStickerMomentImageDto([
    void Function(ImportStickerMomentImageDtoBuilder)? updates,
  ]) => (ImportStickerMomentImageDtoBuilder()..update(updates))._build();

  _$ImportStickerMomentImageDto._({
    required this.momentId,
    required this.mediaId,
    required this.clientRequestId,
  }) : super._();
  @override
  ImportStickerMomentImageDto rebuild(
    void Function(ImportStickerMomentImageDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ImportStickerMomentImageDtoBuilder toBuilder() =>
      ImportStickerMomentImageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImportStickerMomentImageDto &&
        momentId == other.momentId &&
        mediaId == other.mediaId &&
        clientRequestId == other.clientRequestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, momentId.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ImportStickerMomentImageDto')
          ..add('momentId', momentId)
          ..add('mediaId', mediaId)
          ..add('clientRequestId', clientRequestId))
        .toString();
  }
}

class ImportStickerMomentImageDtoBuilder
    implements
        Builder<
          ImportStickerMomentImageDto,
          ImportStickerMomentImageDtoBuilder
        > {
  _$ImportStickerMomentImageDto? _$v;

  String? _momentId;
  String? get momentId => _$this._momentId;
  set momentId(String? momentId) => _$this._momentId = momentId;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  ImportStickerMomentImageDtoBuilder() {
    ImportStickerMomentImageDto._defaults(this);
  }

  ImportStickerMomentImageDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _momentId = $v.momentId;
      _mediaId = $v.mediaId;
      _clientRequestId = $v.clientRequestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImportStickerMomentImageDto other) {
    _$v = other as _$ImportStickerMomentImageDto;
  }

  @override
  void update(void Function(ImportStickerMomentImageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ImportStickerMomentImageDto build() => _build();

  _$ImportStickerMomentImageDto _build() {
    final _$result =
        _$v ??
        _$ImportStickerMomentImageDto._(
          momentId: BuiltValueNullFieldError.checkNotNull(
            momentId,
            r'ImportStickerMomentImageDto',
            'momentId',
          ),
          mediaId: BuiltValueNullFieldError.checkNotNull(
            mediaId,
            r'ImportStickerMomentImageDto',
            'mediaId',
          ),
          clientRequestId: BuiltValueNullFieldError.checkNotNull(
            clientRequestId,
            r'ImportStickerMomentImageDto',
            'clientRequestId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
