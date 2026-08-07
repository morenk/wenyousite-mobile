// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_sticker_media_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImportStickerMediaDto extends ImportStickerMediaDto {
  @override
  final String mediaId;
  @override
  final String clientRequestId;

  factory _$ImportStickerMediaDto([
    void Function(ImportStickerMediaDtoBuilder)? updates,
  ]) => (ImportStickerMediaDtoBuilder()..update(updates))._build();

  _$ImportStickerMediaDto._({
    required this.mediaId,
    required this.clientRequestId,
  }) : super._();
  @override
  ImportStickerMediaDto rebuild(
    void Function(ImportStickerMediaDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ImportStickerMediaDtoBuilder toBuilder() =>
      ImportStickerMediaDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImportStickerMediaDto &&
        mediaId == other.mediaId &&
        clientRequestId == other.clientRequestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ImportStickerMediaDto')
          ..add('mediaId', mediaId)
          ..add('clientRequestId', clientRequestId))
        .toString();
  }
}

class ImportStickerMediaDtoBuilder
    implements Builder<ImportStickerMediaDto, ImportStickerMediaDtoBuilder> {
  _$ImportStickerMediaDto? _$v;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  ImportStickerMediaDtoBuilder() {
    ImportStickerMediaDto._defaults(this);
  }

  ImportStickerMediaDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mediaId = $v.mediaId;
      _clientRequestId = $v.clientRequestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImportStickerMediaDto other) {
    _$v = other as _$ImportStickerMediaDto;
  }

  @override
  void update(void Function(ImportStickerMediaDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ImportStickerMediaDto build() => _build();

  _$ImportStickerMediaDto _build() {
    final _$result =
        _$v ??
        _$ImportStickerMediaDto._(
          mediaId: BuiltValueNullFieldError.checkNotNull(
            mediaId,
            r'ImportStickerMediaDto',
            'mediaId',
          ),
          clientRequestId: BuiltValueNullFieldError.checkNotNull(
            clientRequestId,
            r'ImportStickerMediaDto',
            'clientRequestId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
