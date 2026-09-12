// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_cover_media_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadCoverMediaResponseDto extends ThreadCoverMediaResponseDto {
  @override
  final MediaDisplayResponseDto? display;
  @override
  final String url;
  @override
  final bool? animated;
  @override
  final String? posterUrl;
  @override
  final BuiltList<ThreadCoverPreviewVariantResponseDto>? previewVariants;

  factory _$ThreadCoverMediaResponseDto([
    void Function(ThreadCoverMediaResponseDtoBuilder)? updates,
  ]) => (ThreadCoverMediaResponseDtoBuilder()..update(updates))._build();

  _$ThreadCoverMediaResponseDto._({
    this.display,
    required this.url,
    this.animated,
    this.posterUrl,
    this.previewVariants,
  }) : super._();
  @override
  ThreadCoverMediaResponseDto rebuild(
    void Function(ThreadCoverMediaResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadCoverMediaResponseDtoBuilder toBuilder() =>
      ThreadCoverMediaResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadCoverMediaResponseDto &&
        display == other.display &&
        url == other.url &&
        animated == other.animated &&
        posterUrl == other.posterUrl &&
        previewVariants == other.previewVariants;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, display.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, animated.hashCode);
    _$hash = $jc(_$hash, posterUrl.hashCode);
    _$hash = $jc(_$hash, previewVariants.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadCoverMediaResponseDto')
          ..add('display', display)
          ..add('url', url)
          ..add('animated', animated)
          ..add('posterUrl', posterUrl)
          ..add('previewVariants', previewVariants))
        .toString();
  }
}

class ThreadCoverMediaResponseDtoBuilder
    implements
        Builder<
          ThreadCoverMediaResponseDto,
          ThreadCoverMediaResponseDtoBuilder
        > {
  _$ThreadCoverMediaResponseDto? _$v;

  MediaDisplayResponseDtoBuilder? _display;
  MediaDisplayResponseDtoBuilder get display =>
      _$this._display ??= MediaDisplayResponseDtoBuilder();
  set display(MediaDisplayResponseDtoBuilder? display) =>
      _$this._display = display;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  bool? _animated;
  bool? get animated => _$this._animated;
  set animated(bool? animated) => _$this._animated = animated;

  String? _posterUrl;
  String? get posterUrl => _$this._posterUrl;
  set posterUrl(String? posterUrl) => _$this._posterUrl = posterUrl;

  ListBuilder<ThreadCoverPreviewVariantResponseDto>? _previewVariants;
  ListBuilder<ThreadCoverPreviewVariantResponseDto> get previewVariants =>
      _$this._previewVariants ??=
          ListBuilder<ThreadCoverPreviewVariantResponseDto>();
  set previewVariants(
    ListBuilder<ThreadCoverPreviewVariantResponseDto>? previewVariants,
  ) => _$this._previewVariants = previewVariants;

  ThreadCoverMediaResponseDtoBuilder() {
    ThreadCoverMediaResponseDto._defaults(this);
  }

  ThreadCoverMediaResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _display = $v.display?.toBuilder();
      _url = $v.url;
      _animated = $v.animated;
      _posterUrl = $v.posterUrl;
      _previewVariants = $v.previewVariants?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadCoverMediaResponseDto other) {
    _$v = other as _$ThreadCoverMediaResponseDto;
  }

  @override
  void update(void Function(ThreadCoverMediaResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadCoverMediaResponseDto build() => _build();

  _$ThreadCoverMediaResponseDto _build() {
    _$ThreadCoverMediaResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$ThreadCoverMediaResponseDto._(
            display: _display?.build(),
            url: BuiltValueNullFieldError.checkNotNull(
              url,
              r'ThreadCoverMediaResponseDto',
              'url',
            ),
            animated: animated,
            posterUrl: posterUrl,
            previewVariants: _previewVariants?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'display';
        _display?.build();

        _$failedField = 'previewVariants';
        _previewVariants?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ThreadCoverMediaResponseDto',
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
