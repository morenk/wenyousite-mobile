// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_asset_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StickerAssetResponseDto extends StickerAssetResponseDto {
  @override
  final String id;
  @override
  final String url;
  @override
  final String thumbnailUrl;
  @override
  final num width;
  @override
  final num height;
  @override
  final bool animated;
  @override
  final num frameCount;
  @override
  final num durationMs;

  factory _$StickerAssetResponseDto([
    void Function(StickerAssetResponseDtoBuilder)? updates,
  ]) => (StickerAssetResponseDtoBuilder()..update(updates))._build();

  _$StickerAssetResponseDto._({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.width,
    required this.height,
    required this.animated,
    required this.frameCount,
    required this.durationMs,
  }) : super._();
  @override
  StickerAssetResponseDto rebuild(
    void Function(StickerAssetResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  StickerAssetResponseDtoBuilder toBuilder() =>
      StickerAssetResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickerAssetResponseDto &&
        id == other.id &&
        url == other.url &&
        thumbnailUrl == other.thumbnailUrl &&
        width == other.width &&
        height == other.height &&
        animated == other.animated &&
        frameCount == other.frameCount &&
        durationMs == other.durationMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, thumbnailUrl.hashCode);
    _$hash = $jc(_$hash, width.hashCode);
    _$hash = $jc(_$hash, height.hashCode);
    _$hash = $jc(_$hash, animated.hashCode);
    _$hash = $jc(_$hash, frameCount.hashCode);
    _$hash = $jc(_$hash, durationMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StickerAssetResponseDto')
          ..add('id', id)
          ..add('url', url)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('width', width)
          ..add('height', height)
          ..add('animated', animated)
          ..add('frameCount', frameCount)
          ..add('durationMs', durationMs))
        .toString();
  }
}

class StickerAssetResponseDtoBuilder
    implements
        Builder<StickerAssetResponseDto, StickerAssetResponseDtoBuilder> {
  _$StickerAssetResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _thumbnailUrl;
  String? get thumbnailUrl => _$this._thumbnailUrl;
  set thumbnailUrl(String? thumbnailUrl) => _$this._thumbnailUrl = thumbnailUrl;

  num? _width;
  num? get width => _$this._width;
  set width(num? width) => _$this._width = width;

  num? _height;
  num? get height => _$this._height;
  set height(num? height) => _$this._height = height;

  bool? _animated;
  bool? get animated => _$this._animated;
  set animated(bool? animated) => _$this._animated = animated;

  num? _frameCount;
  num? get frameCount => _$this._frameCount;
  set frameCount(num? frameCount) => _$this._frameCount = frameCount;

  num? _durationMs;
  num? get durationMs => _$this._durationMs;
  set durationMs(num? durationMs) => _$this._durationMs = durationMs;

  StickerAssetResponseDtoBuilder() {
    StickerAssetResponseDto._defaults(this);
  }

  StickerAssetResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _url = $v.url;
      _thumbnailUrl = $v.thumbnailUrl;
      _width = $v.width;
      _height = $v.height;
      _animated = $v.animated;
      _frameCount = $v.frameCount;
      _durationMs = $v.durationMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StickerAssetResponseDto other) {
    _$v = other as _$StickerAssetResponseDto;
  }

  @override
  void update(void Function(StickerAssetResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StickerAssetResponseDto build() => _build();

  _$StickerAssetResponseDto _build() {
    final _$result =
        _$v ??
        _$StickerAssetResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'StickerAssetResponseDto',
            'id',
          ),
          url: BuiltValueNullFieldError.checkNotNull(
            url,
            r'StickerAssetResponseDto',
            'url',
          ),
          thumbnailUrl: BuiltValueNullFieldError.checkNotNull(
            thumbnailUrl,
            r'StickerAssetResponseDto',
            'thumbnailUrl',
          ),
          width: BuiltValueNullFieldError.checkNotNull(
            width,
            r'StickerAssetResponseDto',
            'width',
          ),
          height: BuiltValueNullFieldError.checkNotNull(
            height,
            r'StickerAssetResponseDto',
            'height',
          ),
          animated: BuiltValueNullFieldError.checkNotNull(
            animated,
            r'StickerAssetResponseDto',
            'animated',
          ),
          frameCount: BuiltValueNullFieldError.checkNotNull(
            frameCount,
            r'StickerAssetResponseDto',
            'frameCount',
          ),
          durationMs: BuiltValueNullFieldError.checkNotNull(
            durationMs,
            r'StickerAssetResponseDto',
            'durationMs',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
