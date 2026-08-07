// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_url_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UploadUrlResponseDto extends UploadUrlResponseDto {
  @override
  final String uploadUrl;
  @override
  final String mediaId;
  @override
  final String objectKey;
  @override
  final String publicUrl;

  factory _$UploadUrlResponseDto([
    void Function(UploadUrlResponseDtoBuilder)? updates,
  ]) => (UploadUrlResponseDtoBuilder()..update(updates))._build();

  _$UploadUrlResponseDto._({
    required this.uploadUrl,
    required this.mediaId,
    required this.objectKey,
    required this.publicUrl,
  }) : super._();
  @override
  UploadUrlResponseDto rebuild(
    void Function(UploadUrlResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UploadUrlResponseDtoBuilder toBuilder() =>
      UploadUrlResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UploadUrlResponseDto &&
        uploadUrl == other.uploadUrl &&
        mediaId == other.mediaId &&
        objectKey == other.objectKey &&
        publicUrl == other.publicUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, uploadUrl.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jc(_$hash, objectKey.hashCode);
    _$hash = $jc(_$hash, publicUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UploadUrlResponseDto')
          ..add('uploadUrl', uploadUrl)
          ..add('mediaId', mediaId)
          ..add('objectKey', objectKey)
          ..add('publicUrl', publicUrl))
        .toString();
  }
}

class UploadUrlResponseDtoBuilder
    implements Builder<UploadUrlResponseDto, UploadUrlResponseDtoBuilder> {
  _$UploadUrlResponseDto? _$v;

  String? _uploadUrl;
  String? get uploadUrl => _$this._uploadUrl;
  set uploadUrl(String? uploadUrl) => _$this._uploadUrl = uploadUrl;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  String? _objectKey;
  String? get objectKey => _$this._objectKey;
  set objectKey(String? objectKey) => _$this._objectKey = objectKey;

  String? _publicUrl;
  String? get publicUrl => _$this._publicUrl;
  set publicUrl(String? publicUrl) => _$this._publicUrl = publicUrl;

  UploadUrlResponseDtoBuilder() {
    UploadUrlResponseDto._defaults(this);
  }

  UploadUrlResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _uploadUrl = $v.uploadUrl;
      _mediaId = $v.mediaId;
      _objectKey = $v.objectKey;
      _publicUrl = $v.publicUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UploadUrlResponseDto other) {
    _$v = other as _$UploadUrlResponseDto;
  }

  @override
  void update(void Function(UploadUrlResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UploadUrlResponseDto build() => _build();

  _$UploadUrlResponseDto _build() {
    final _$result =
        _$v ??
        _$UploadUrlResponseDto._(
          uploadUrl: BuiltValueNullFieldError.checkNotNull(
            uploadUrl,
            r'UploadUrlResponseDto',
            'uploadUrl',
          ),
          mediaId: BuiltValueNullFieldError.checkNotNull(
            mediaId,
            r'UploadUrlResponseDto',
            'mediaId',
          ),
          objectKey: BuiltValueNullFieldError.checkNotNull(
            objectKey,
            r'UploadUrlResponseDto',
            'objectKey',
          ),
          publicUrl: BuiltValueNullFieldError.checkNotNull(
            publicUrl,
            r'UploadUrlResponseDto',
            'publicUrl',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
