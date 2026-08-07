// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_sticker_post_image_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImportStickerPostImageDto extends ImportStickerPostImageDto {
  @override
  final String postId;
  @override
  final String imageUrl;
  @override
  final String clientRequestId;

  factory _$ImportStickerPostImageDto([
    void Function(ImportStickerPostImageDtoBuilder)? updates,
  ]) => (ImportStickerPostImageDtoBuilder()..update(updates))._build();

  _$ImportStickerPostImageDto._({
    required this.postId,
    required this.imageUrl,
    required this.clientRequestId,
  }) : super._();
  @override
  ImportStickerPostImageDto rebuild(
    void Function(ImportStickerPostImageDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ImportStickerPostImageDtoBuilder toBuilder() =>
      ImportStickerPostImageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImportStickerPostImageDto &&
        postId == other.postId &&
        imageUrl == other.imageUrl &&
        clientRequestId == other.clientRequestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, postId.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ImportStickerPostImageDto')
          ..add('postId', postId)
          ..add('imageUrl', imageUrl)
          ..add('clientRequestId', clientRequestId))
        .toString();
  }
}

class ImportStickerPostImageDtoBuilder
    implements
        Builder<ImportStickerPostImageDto, ImportStickerPostImageDtoBuilder> {
  _$ImportStickerPostImageDto? _$v;

  String? _postId;
  String? get postId => _$this._postId;
  set postId(String? postId) => _$this._postId = postId;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  ImportStickerPostImageDtoBuilder() {
    ImportStickerPostImageDto._defaults(this);
  }

  ImportStickerPostImageDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _postId = $v.postId;
      _imageUrl = $v.imageUrl;
      _clientRequestId = $v.clientRequestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImportStickerPostImageDto other) {
    _$v = other as _$ImportStickerPostImageDto;
  }

  @override
  void update(void Function(ImportStickerPostImageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ImportStickerPostImageDto build() => _build();

  _$ImportStickerPostImageDto _build() {
    final _$result =
        _$v ??
        _$ImportStickerPostImageDto._(
          postId: BuiltValueNullFieldError.checkNotNull(
            postId,
            r'ImportStickerPostImageDto',
            'postId',
          ),
          imageUrl: BuiltValueNullFieldError.checkNotNull(
            imageUrl,
            r'ImportStickerPostImageDto',
            'imageUrl',
          ),
          clientRequestId: BuiltValueNullFieldError.checkNotNull(
            clientRequestId,
            r'ImportStickerPostImageDto',
            'clientRequestId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
