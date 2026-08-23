// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_message_media_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DirectMessageMediaResponseDto extends DirectMessageMediaResponseDto {
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

  factory _$DirectMessageMediaResponseDto([
    void Function(DirectMessageMediaResponseDtoBuilder)? updates,
  ]) => (DirectMessageMediaResponseDtoBuilder()..update(updates))._build();

  _$DirectMessageMediaResponseDto._({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    this.mediumUrl,
    this.contentType,
    this.width,
    this.height,
    required this.animated,
  }) : super._();
  @override
  DirectMessageMediaResponseDto rebuild(
    void Function(DirectMessageMediaResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DirectMessageMediaResponseDtoBuilder toBuilder() =>
      DirectMessageMediaResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DirectMessageMediaResponseDto &&
        id == other.id &&
        url == other.url &&
        thumbnailUrl == other.thumbnailUrl &&
        mediumUrl == other.mediumUrl &&
        contentType == other.contentType &&
        width == other.width &&
        height == other.height &&
        animated == other.animated;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DirectMessageMediaResponseDto')
          ..add('id', id)
          ..add('url', url)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('mediumUrl', mediumUrl)
          ..add('contentType', contentType)
          ..add('width', width)
          ..add('height', height)
          ..add('animated', animated))
        .toString();
  }
}

class DirectMessageMediaResponseDtoBuilder
    implements
        Builder<
          DirectMessageMediaResponseDto,
          DirectMessageMediaResponseDtoBuilder
        > {
  _$DirectMessageMediaResponseDto? _$v;

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

  DirectMessageMediaResponseDtoBuilder() {
    DirectMessageMediaResponseDto._defaults(this);
  }

  DirectMessageMediaResponseDtoBuilder get _$this {
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
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DirectMessageMediaResponseDto other) {
    _$v = other as _$DirectMessageMediaResponseDto;
  }

  @override
  void update(void Function(DirectMessageMediaResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DirectMessageMediaResponseDto build() => _build();

  _$DirectMessageMediaResponseDto _build() {
    final _$result =
        _$v ??
        _$DirectMessageMediaResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'DirectMessageMediaResponseDto',
            'id',
          ),
          url: BuiltValueNullFieldError.checkNotNull(
            url,
            r'DirectMessageMediaResponseDto',
            'url',
          ),
          thumbnailUrl: thumbnailUrl,
          mediumUrl: mediumUrl,
          contentType: contentType,
          width: width,
          height: height,
          animated: BuiltValueNullFieldError.checkNotNull(
            animated,
            r'DirectMessageMediaResponseDto',
            'animated',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
