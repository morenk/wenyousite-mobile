// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_display_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MediaDisplayResponseDtoContentTypeEnum
_$mediaDisplayResponseDtoContentTypeEnum_imageSlashWebp =
    const MediaDisplayResponseDtoContentTypeEnum._('imageSlashWebp');
const MediaDisplayResponseDtoContentTypeEnum
_$mediaDisplayResponseDtoContentTypeEnum_unknownDefaultOpenApi =
    const MediaDisplayResponseDtoContentTypeEnum._('unknownDefaultOpenApi');

MediaDisplayResponseDtoContentTypeEnum
_$mediaDisplayResponseDtoContentTypeEnumValueOf(String name) {
  switch (name) {
    case 'imageSlashWebp':
      return _$mediaDisplayResponseDtoContentTypeEnum_imageSlashWebp;
    case 'unknownDefaultOpenApi':
      return _$mediaDisplayResponseDtoContentTypeEnum_unknownDefaultOpenApi;
    default:
      return _$mediaDisplayResponseDtoContentTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MediaDisplayResponseDtoContentTypeEnum>
_$mediaDisplayResponseDtoContentTypeEnumValues =
    BuiltSet<MediaDisplayResponseDtoContentTypeEnum>(
      const <MediaDisplayResponseDtoContentTypeEnum>[
        _$mediaDisplayResponseDtoContentTypeEnum_imageSlashWebp,
        _$mediaDisplayResponseDtoContentTypeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MediaDisplayResponseDtoContentTypeEnum>
_$mediaDisplayResponseDtoContentTypeEnumSerializer =
    _$MediaDisplayResponseDtoContentTypeEnumSerializer();

class _$MediaDisplayResponseDtoContentTypeEnumSerializer
    implements PrimitiveSerializer<MediaDisplayResponseDtoContentTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'imageSlashWebp': 'image/webp',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'image/webp': 'imageSlashWebp',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    MediaDisplayResponseDtoContentTypeEnum,
  ];
  @override
  final String wireName = 'MediaDisplayResponseDtoContentTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MediaDisplayResponseDtoContentTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MediaDisplayResponseDtoContentTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MediaDisplayResponseDtoContentTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MediaDisplayResponseDto extends MediaDisplayResponseDto {
  @override
  final String url;
  @override
  final MediaDisplayResponseDtoContentTypeEnum contentType;
  @override
  final num width;
  @override
  final num height;
  @override
  final num bytes;
  @override
  final bool animated;
  @override
  final num frameCount;
  @override
  final num durationMs;
  @override
  final num loopCount;

  factory _$MediaDisplayResponseDto([
    void Function(MediaDisplayResponseDtoBuilder)? updates,
  ]) => (MediaDisplayResponseDtoBuilder()..update(updates))._build();

  _$MediaDisplayResponseDto._({
    required this.url,
    required this.contentType,
    required this.width,
    required this.height,
    required this.bytes,
    required this.animated,
    required this.frameCount,
    required this.durationMs,
    required this.loopCount,
  }) : super._();
  @override
  MediaDisplayResponseDto rebuild(
    void Function(MediaDisplayResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MediaDisplayResponseDtoBuilder toBuilder() =>
      MediaDisplayResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MediaDisplayResponseDto &&
        url == other.url &&
        contentType == other.contentType &&
        width == other.width &&
        height == other.height &&
        bytes == other.bytes &&
        animated == other.animated &&
        frameCount == other.frameCount &&
        durationMs == other.durationMs &&
        loopCount == other.loopCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, width.hashCode);
    _$hash = $jc(_$hash, height.hashCode);
    _$hash = $jc(_$hash, bytes.hashCode);
    _$hash = $jc(_$hash, animated.hashCode);
    _$hash = $jc(_$hash, frameCount.hashCode);
    _$hash = $jc(_$hash, durationMs.hashCode);
    _$hash = $jc(_$hash, loopCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MediaDisplayResponseDto')
          ..add('url', url)
          ..add('contentType', contentType)
          ..add('width', width)
          ..add('height', height)
          ..add('bytes', bytes)
          ..add('animated', animated)
          ..add('frameCount', frameCount)
          ..add('durationMs', durationMs)
          ..add('loopCount', loopCount))
        .toString();
  }
}

class MediaDisplayResponseDtoBuilder
    implements
        Builder<MediaDisplayResponseDto, MediaDisplayResponseDtoBuilder> {
  _$MediaDisplayResponseDto? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  MediaDisplayResponseDtoContentTypeEnum? _contentType;
  MediaDisplayResponseDtoContentTypeEnum? get contentType =>
      _$this._contentType;
  set contentType(MediaDisplayResponseDtoContentTypeEnum? contentType) =>
      _$this._contentType = contentType;

  num? _width;
  num? get width => _$this._width;
  set width(num? width) => _$this._width = width;

  num? _height;
  num? get height => _$this._height;
  set height(num? height) => _$this._height = height;

  num? _bytes;
  num? get bytes => _$this._bytes;
  set bytes(num? bytes) => _$this._bytes = bytes;

  bool? _animated;
  bool? get animated => _$this._animated;
  set animated(bool? animated) => _$this._animated = animated;

  num? _frameCount;
  num? get frameCount => _$this._frameCount;
  set frameCount(num? frameCount) => _$this._frameCount = frameCount;

  num? _durationMs;
  num? get durationMs => _$this._durationMs;
  set durationMs(num? durationMs) => _$this._durationMs = durationMs;

  num? _loopCount;
  num? get loopCount => _$this._loopCount;
  set loopCount(num? loopCount) => _$this._loopCount = loopCount;

  MediaDisplayResponseDtoBuilder() {
    MediaDisplayResponseDto._defaults(this);
  }

  MediaDisplayResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _contentType = $v.contentType;
      _width = $v.width;
      _height = $v.height;
      _bytes = $v.bytes;
      _animated = $v.animated;
      _frameCount = $v.frameCount;
      _durationMs = $v.durationMs;
      _loopCount = $v.loopCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MediaDisplayResponseDto other) {
    _$v = other as _$MediaDisplayResponseDto;
  }

  @override
  void update(void Function(MediaDisplayResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MediaDisplayResponseDto build() => _build();

  _$MediaDisplayResponseDto _build() {
    final _$result =
        _$v ??
        _$MediaDisplayResponseDto._(
          url: BuiltValueNullFieldError.checkNotNull(
            url,
            r'MediaDisplayResponseDto',
            'url',
          ),
          contentType: BuiltValueNullFieldError.checkNotNull(
            contentType,
            r'MediaDisplayResponseDto',
            'contentType',
          ),
          width: BuiltValueNullFieldError.checkNotNull(
            width,
            r'MediaDisplayResponseDto',
            'width',
          ),
          height: BuiltValueNullFieldError.checkNotNull(
            height,
            r'MediaDisplayResponseDto',
            'height',
          ),
          bytes: BuiltValueNullFieldError.checkNotNull(
            bytes,
            r'MediaDisplayResponseDto',
            'bytes',
          ),
          animated: BuiltValueNullFieldError.checkNotNull(
            animated,
            r'MediaDisplayResponseDto',
            'animated',
          ),
          frameCount: BuiltValueNullFieldError.checkNotNull(
            frameCount,
            r'MediaDisplayResponseDto',
            'frameCount',
          ),
          durationMs: BuiltValueNullFieldError.checkNotNull(
            durationMs,
            r'MediaDisplayResponseDto',
            'durationMs',
          ),
          loopCount: BuiltValueNullFieldError.checkNotNull(
            loopCount,
            r'MediaDisplayResponseDto',
            'loopCount',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
