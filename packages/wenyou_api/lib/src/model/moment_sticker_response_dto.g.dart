// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_sticker_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MomentStickerResponseDto extends MomentStickerResponseDto {
  @override
  final String id;
  @override
  final String url;
  @override
  final String thumbnailUrl;
  @override
  final String mediumUrl;
  @override
  final num? width;
  @override
  final num? height;
  @override
  final bool animated;
  @override
  final num frameCount;
  @override
  final num durationMs;

  factory _$MomentStickerResponseDto([
    void Function(MomentStickerResponseDtoBuilder)? updates,
  ]) => (MomentStickerResponseDtoBuilder()..update(updates))._build();

  _$MomentStickerResponseDto._({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.mediumUrl,
    this.width,
    this.height,
    required this.animated,
    required this.frameCount,
    required this.durationMs,
  }) : super._();
  @override
  MomentStickerResponseDto rebuild(
    void Function(MomentStickerResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentStickerResponseDtoBuilder toBuilder() =>
      MomentStickerResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentStickerResponseDto &&
        id == other.id &&
        url == other.url &&
        thumbnailUrl == other.thumbnailUrl &&
        mediumUrl == other.mediumUrl &&
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
    _$hash = $jc(_$hash, mediumUrl.hashCode);
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
    return (newBuiltValueToStringHelper(r'MomentStickerResponseDto')
          ..add('id', id)
          ..add('url', url)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('mediumUrl', mediumUrl)
          ..add('width', width)
          ..add('height', height)
          ..add('animated', animated)
          ..add('frameCount', frameCount)
          ..add('durationMs', durationMs))
        .toString();
  }
}

class MomentStickerResponseDtoBuilder
    implements
        Builder<MomentStickerResponseDto, MomentStickerResponseDtoBuilder> {
  _$MomentStickerResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _thumbnailUrl;
  String? get thumbnailUrl => _$this._thumbnailUrl;
  set thumbnailUrl(String? thumbnailUrl) => _$this._thumbnailUrl = thumbnailUrl;

  String? _mediumUrl;
  String? get mediumUrl => _$this._mediumUrl;
  set mediumUrl(String? mediumUrl) => _$this._mediumUrl = mediumUrl;

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

  MomentStickerResponseDtoBuilder() {
    MomentStickerResponseDto._defaults(this);
  }

  MomentStickerResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _url = $v.url;
      _thumbnailUrl = $v.thumbnailUrl;
      _mediumUrl = $v.mediumUrl;
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
  void replace(MomentStickerResponseDto other) {
    _$v = other as _$MomentStickerResponseDto;
  }

  @override
  void update(void Function(MomentStickerResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentStickerResponseDto build() => _build();

  _$MomentStickerResponseDto _build() {
    final _$result =
        _$v ??
        _$MomentStickerResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'MomentStickerResponseDto',
            'id',
          ),
          url: BuiltValueNullFieldError.checkNotNull(
            url,
            r'MomentStickerResponseDto',
            'url',
          ),
          thumbnailUrl: BuiltValueNullFieldError.checkNotNull(
            thumbnailUrl,
            r'MomentStickerResponseDto',
            'thumbnailUrl',
          ),
          mediumUrl: BuiltValueNullFieldError.checkNotNull(
            mediumUrl,
            r'MomentStickerResponseDto',
            'mediumUrl',
          ),
          width: width,
          height: height,
          animated: BuiltValueNullFieldError.checkNotNull(
            animated,
            r'MomentStickerResponseDto',
            'animated',
          ),
          frameCount: BuiltValueNullFieldError.checkNotNull(
            frameCount,
            r'MomentStickerResponseDto',
            'frameCount',
          ),
          durationMs: BuiltValueNullFieldError.checkNotNull(
            durationMs,
            r'MomentStickerResponseDto',
            'durationMs',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
