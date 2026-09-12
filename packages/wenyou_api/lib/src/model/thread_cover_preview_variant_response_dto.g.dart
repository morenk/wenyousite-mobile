// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_cover_preview_variant_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadCoverPreviewVariantResponseDto
    extends ThreadCoverPreviewVariantResponseDto {
  @override
  final String url;
  @override
  final int width;
  @override
  final int height;
  @override
  final int bytes;

  factory _$ThreadCoverPreviewVariantResponseDto([
    void Function(ThreadCoverPreviewVariantResponseDtoBuilder)? updates,
  ]) =>
      (ThreadCoverPreviewVariantResponseDtoBuilder()..update(updates))._build();

  _$ThreadCoverPreviewVariantResponseDto._({
    required this.url,
    required this.width,
    required this.height,
    required this.bytes,
  }) : super._();
  @override
  ThreadCoverPreviewVariantResponseDto rebuild(
    void Function(ThreadCoverPreviewVariantResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadCoverPreviewVariantResponseDtoBuilder toBuilder() =>
      ThreadCoverPreviewVariantResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadCoverPreviewVariantResponseDto &&
        url == other.url &&
        width == other.width &&
        height == other.height &&
        bytes == other.bytes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, width.hashCode);
    _$hash = $jc(_$hash, height.hashCode);
    _$hash = $jc(_$hash, bytes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadCoverPreviewVariantResponseDto')
          ..add('url', url)
          ..add('width', width)
          ..add('height', height)
          ..add('bytes', bytes))
        .toString();
  }
}

class ThreadCoverPreviewVariantResponseDtoBuilder
    implements
        Builder<
          ThreadCoverPreviewVariantResponseDto,
          ThreadCoverPreviewVariantResponseDtoBuilder
        > {
  _$ThreadCoverPreviewVariantResponseDto? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  int? _width;
  int? get width => _$this._width;
  set width(int? width) => _$this._width = width;

  int? _height;
  int? get height => _$this._height;
  set height(int? height) => _$this._height = height;

  int? _bytes;
  int? get bytes => _$this._bytes;
  set bytes(int? bytes) => _$this._bytes = bytes;

  ThreadCoverPreviewVariantResponseDtoBuilder() {
    ThreadCoverPreviewVariantResponseDto._defaults(this);
  }

  ThreadCoverPreviewVariantResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _width = $v.width;
      _height = $v.height;
      _bytes = $v.bytes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadCoverPreviewVariantResponseDto other) {
    _$v = other as _$ThreadCoverPreviewVariantResponseDto;
  }

  @override
  void update(
    void Function(ThreadCoverPreviewVariantResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ThreadCoverPreviewVariantResponseDto build() => _build();

  _$ThreadCoverPreviewVariantResponseDto _build() {
    final _$result =
        _$v ??
        _$ThreadCoverPreviewVariantResponseDto._(
          url: BuiltValueNullFieldError.checkNotNull(
            url,
            r'ThreadCoverPreviewVariantResponseDto',
            'url',
          ),
          width: BuiltValueNullFieldError.checkNotNull(
            width,
            r'ThreadCoverPreviewVariantResponseDto',
            'width',
          ),
          height: BuiltValueNullFieldError.checkNotNull(
            height,
            r'ThreadCoverPreviewVariantResponseDto',
            'height',
          ),
          bytes: BuiltValueNullFieldError.checkNotNull(
            bytes,
            r'ThreadCoverPreviewVariantResponseDto',
            'bytes',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
