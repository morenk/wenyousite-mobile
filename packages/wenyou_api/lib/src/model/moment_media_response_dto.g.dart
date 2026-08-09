// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_media_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MomentMediaResponseDto extends MomentMediaResponseDto {
  @override
  final String id;
  @override
  final String url;
  @override
  final String? thumbnailUrl;
  @override
  final String? feedUrl;
  @override
  final String? mediumUrl;
  @override
  final num? width;
  @override
  final num? height;

  factory _$MomentMediaResponseDto([
    void Function(MomentMediaResponseDtoBuilder)? updates,
  ]) => (MomentMediaResponseDtoBuilder()..update(updates))._build();

  _$MomentMediaResponseDto._({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    this.feedUrl,
    this.mediumUrl,
    this.width,
    this.height,
  }) : super._();
  @override
  MomentMediaResponseDto rebuild(
    void Function(MomentMediaResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentMediaResponseDtoBuilder toBuilder() =>
      MomentMediaResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentMediaResponseDto &&
        id == other.id &&
        url == other.url &&
        thumbnailUrl == other.thumbnailUrl &&
        feedUrl == other.feedUrl &&
        mediumUrl == other.mediumUrl &&
        width == other.width &&
        height == other.height;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, thumbnailUrl.hashCode);
    _$hash = $jc(_$hash, feedUrl.hashCode);
    _$hash = $jc(_$hash, mediumUrl.hashCode);
    _$hash = $jc(_$hash, width.hashCode);
    _$hash = $jc(_$hash, height.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentMediaResponseDto')
          ..add('id', id)
          ..add('url', url)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('feedUrl', feedUrl)
          ..add('mediumUrl', mediumUrl)
          ..add('width', width)
          ..add('height', height))
        .toString();
  }
}

class MomentMediaResponseDtoBuilder
    implements Builder<MomentMediaResponseDto, MomentMediaResponseDtoBuilder> {
  _$MomentMediaResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _thumbnailUrl;
  String? get thumbnailUrl => _$this._thumbnailUrl;
  set thumbnailUrl(String? thumbnailUrl) => _$this._thumbnailUrl = thumbnailUrl;

  String? _feedUrl;
  String? get feedUrl => _$this._feedUrl;
  set feedUrl(String? feedUrl) => _$this._feedUrl = feedUrl;

  String? _mediumUrl;
  String? get mediumUrl => _$this._mediumUrl;
  set mediumUrl(String? mediumUrl) => _$this._mediumUrl = mediumUrl;

  num? _width;
  num? get width => _$this._width;
  set width(num? width) => _$this._width = width;

  num? _height;
  num? get height => _$this._height;
  set height(num? height) => _$this._height = height;

  MomentMediaResponseDtoBuilder() {
    MomentMediaResponseDto._defaults(this);
  }

  MomentMediaResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _url = $v.url;
      _thumbnailUrl = $v.thumbnailUrl;
      _feedUrl = $v.feedUrl;
      _mediumUrl = $v.mediumUrl;
      _width = $v.width;
      _height = $v.height;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentMediaResponseDto other) {
    _$v = other as _$MomentMediaResponseDto;
  }

  @override
  void update(void Function(MomentMediaResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentMediaResponseDto build() => _build();

  _$MomentMediaResponseDto _build() {
    final _$result =
        _$v ??
        _$MomentMediaResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'MomentMediaResponseDto',
            'id',
          ),
          url: BuiltValueNullFieldError.checkNotNull(
            url,
            r'MomentMediaResponseDto',
            'url',
          ),
          thumbnailUrl: thumbnailUrl,
          feedUrl: feedUrl,
          mediumUrl: mediumUrl,
          width: width,
          height: height,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
