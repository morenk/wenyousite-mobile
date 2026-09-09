// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_cover_media_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadCoverMediaResponseDto extends ThreadCoverMediaResponseDto {
  @override
  final String url;
  @override
  final bool? animated;
  @override
  final String? posterUrl;

  factory _$ThreadCoverMediaResponseDto([
    void Function(ThreadCoverMediaResponseDtoBuilder)? updates,
  ]) => (ThreadCoverMediaResponseDtoBuilder()..update(updates))._build();

  _$ThreadCoverMediaResponseDto._({
    required this.url,
    this.animated,
    this.posterUrl,
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
        url == other.url &&
        animated == other.animated &&
        posterUrl == other.posterUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, animated.hashCode);
    _$hash = $jc(_$hash, posterUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadCoverMediaResponseDto')
          ..add('url', url)
          ..add('animated', animated)
          ..add('posterUrl', posterUrl))
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

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  bool? _animated;
  bool? get animated => _$this._animated;
  set animated(bool? animated) => _$this._animated = animated;

  String? _posterUrl;
  String? get posterUrl => _$this._posterUrl;
  set posterUrl(String? posterUrl) => _$this._posterUrl = posterUrl;

  ThreadCoverMediaResponseDtoBuilder() {
    ThreadCoverMediaResponseDto._defaults(this);
  }

  ThreadCoverMediaResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _animated = $v.animated;
      _posterUrl = $v.posterUrl;
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
    final _$result =
        _$v ??
        _$ThreadCoverMediaResponseDto._(
          url: BuiltValueNullFieldError.checkNotNull(
            url,
            r'ThreadCoverMediaResponseDto',
            'url',
          ),
          animated: animated,
          posterUrl: posterUrl,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
