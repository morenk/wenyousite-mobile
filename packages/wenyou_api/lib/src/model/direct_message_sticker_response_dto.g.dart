// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_message_sticker_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DirectMessageStickerResponseDto
    extends DirectMessageStickerResponseDto {
  @override
  final String id;
  @override
  final String url;
  @override
  final String? thumbnailUrl;
  @override
  final String? mediumUrl;
  @override
  final String? contentType;
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

  factory _$DirectMessageStickerResponseDto([
    void Function(DirectMessageStickerResponseDtoBuilder)? updates,
  ]) => (DirectMessageStickerResponseDtoBuilder()..update(updates))._build();

  _$DirectMessageStickerResponseDto._({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    this.mediumUrl,
    this.contentType,
    this.width,
    this.height,
    required this.animated,
    required this.frameCount,
    required this.durationMs,
  }) : super._();
  @override
  DirectMessageStickerResponseDto rebuild(
    void Function(DirectMessageStickerResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectMessageStickerResponseDtoBuilder toBuilder() =>
      DirectMessageStickerResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectMessageStickerResponseDto &&
        id == other.id &&
        url == other.url &&
        thumbnailUrl == other.thumbnailUrl &&
        mediumUrl == other.mediumUrl &&
        contentType == other.contentType &&
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
    _$hash = $jc(_$hash, contentType.hashCode);
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
    return (newBuiltValueToStringHelper(r'DirectMessageStickerResponseDto')
          ..add('id', id)
          ..add('url', url)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('mediumUrl', mediumUrl)
          ..add('contentType', contentType)
          ..add('width', width)
          ..add('height', height)
          ..add('animated', animated)
          ..add('frameCount', frameCount)
          ..add('durationMs', durationMs))
        .toString();
  }
}

class DirectMessageStickerResponseDtoBuilder
    implements
        Builder<
          DirectMessageStickerResponseDto,
          DirectMessageStickerResponseDtoBuilder
        > {
  _$DirectMessageStickerResponseDto? _$v;

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

  String? _contentType;
  String? get contentType => _$this._contentType;
  set contentType(String? contentType) => _$this._contentType = contentType;

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

  DirectMessageStickerResponseDtoBuilder() {
    DirectMessageStickerResponseDto._defaults(this);
  }

  DirectMessageStickerResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _url = $v.url;
      _thumbnailUrl = $v.thumbnailUrl;
      _mediumUrl = $v.mediumUrl;
      _contentType = $v.contentType;
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
  void replace(DirectMessageStickerResponseDto other) {
    _$v = other as _$DirectMessageStickerResponseDto;
  }

  @override
  void update(void Function(DirectMessageStickerResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DirectMessageStickerResponseDto build() => _build();

  _$DirectMessageStickerResponseDto _build() {
    final _$result =
        _$v ??
        _$DirectMessageStickerResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'DirectMessageStickerResponseDto',
            'id',
          ),
          url: BuiltValueNullFieldError.checkNotNull(
            url,
            r'DirectMessageStickerResponseDto',
            'url',
          ),
          thumbnailUrl: thumbnailUrl,
          mediumUrl: mediumUrl,
          contentType: contentType,
          width: width,
          height: height,
          animated: BuiltValueNullFieldError.checkNotNull(
            animated,
            r'DirectMessageStickerResponseDto',
            'animated',
          ),
          frameCount: BuiltValueNullFieldError.checkNotNull(
            frameCount,
            r'DirectMessageStickerResponseDto',
            'frameCount',
          ),
          durationMs: BuiltValueNullFieldError.checkNotNull(
            durationMs,
            r'DirectMessageStickerResponseDto',
            'durationMs',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
