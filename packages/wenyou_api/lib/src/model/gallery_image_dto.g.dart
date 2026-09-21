// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_image_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GalleryImageDto extends GalleryImageDto {
  @override
  final String id;
  @override
  final String sourceId;
  @override
  final num sourceVersion;
  @override
  final num imageIndex;
  @override
  final num imageCount;
  @override
  final String? mediaId;
  @override
  final String url;
  @override
  final MediaDisplayResponseDto? display;
  @override
  final num? width;
  @override
  final num? height;
  @override
  final bool animated;
  @override
  final String? threadId;
  @override
  final String? subthreadId;
  @override
  final String? parentPostId;
  @override
  final String? momentId;
  @override
  final String? parentCommentId;
  @override
  final num? floorNumber;

  factory _$GalleryImageDto([void Function(GalleryImageDtoBuilder)? updates]) =>
      (GalleryImageDtoBuilder()..update(updates))._build();

  _$GalleryImageDto._({
    required this.id,
    required this.sourceId,
    required this.sourceVersion,
    required this.imageIndex,
    required this.imageCount,
    this.mediaId,
    required this.url,
    this.display,
    this.width,
    this.height,
    required this.animated,
    this.threadId,
    this.subthreadId,
    this.parentPostId,
    this.momentId,
    this.parentCommentId,
    this.floorNumber,
  }) : super._();
  @override
  GalleryImageDto rebuild(void Function(GalleryImageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GalleryImageDtoBuilder toBuilder() => GalleryImageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GalleryImageDto &&
        id == other.id &&
        sourceId == other.sourceId &&
        sourceVersion == other.sourceVersion &&
        imageIndex == other.imageIndex &&
        imageCount == other.imageCount &&
        mediaId == other.mediaId &&
        url == other.url &&
        display == other.display &&
        width == other.width &&
        height == other.height &&
        animated == other.animated &&
        threadId == other.threadId &&
        subthreadId == other.subthreadId &&
        parentPostId == other.parentPostId &&
        momentId == other.momentId &&
        parentCommentId == other.parentCommentId &&
        floorNumber == other.floorNumber;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, sourceId.hashCode);
    _$hash = $jc(_$hash, sourceVersion.hashCode);
    _$hash = $jc(_$hash, imageIndex.hashCode);
    _$hash = $jc(_$hash, imageCount.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, display.hashCode);
    _$hash = $jc(_$hash, width.hashCode);
    _$hash = $jc(_$hash, height.hashCode);
    _$hash = $jc(_$hash, animated.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, subthreadId.hashCode);
    _$hash = $jc(_$hash, parentPostId.hashCode);
    _$hash = $jc(_$hash, momentId.hashCode);
    _$hash = $jc(_$hash, parentCommentId.hashCode);
    _$hash = $jc(_$hash, floorNumber.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GalleryImageDto')
          ..add('id', id)
          ..add('sourceId', sourceId)
          ..add('sourceVersion', sourceVersion)
          ..add('imageIndex', imageIndex)
          ..add('imageCount', imageCount)
          ..add('mediaId', mediaId)
          ..add('url', url)
          ..add('display', display)
          ..add('width', width)
          ..add('height', height)
          ..add('animated', animated)
          ..add('threadId', threadId)
          ..add('subthreadId', subthreadId)
          ..add('parentPostId', parentPostId)
          ..add('momentId', momentId)
          ..add('parentCommentId', parentCommentId)
          ..add('floorNumber', floorNumber))
        .toString();
  }
}

class GalleryImageDtoBuilder
    implements Builder<GalleryImageDto, GalleryImageDtoBuilder> {
  _$GalleryImageDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _sourceId;
  String? get sourceId => _$this._sourceId;
  set sourceId(String? sourceId) => _$this._sourceId = sourceId;

  num? _sourceVersion;
  num? get sourceVersion => _$this._sourceVersion;
  set sourceVersion(num? sourceVersion) =>
      _$this._sourceVersion = sourceVersion;

  num? _imageIndex;
  num? get imageIndex => _$this._imageIndex;
  set imageIndex(num? imageIndex) => _$this._imageIndex = imageIndex;

  num? _imageCount;
  num? get imageCount => _$this._imageCount;
  set imageCount(num? imageCount) => _$this._imageCount = imageCount;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  MediaDisplayResponseDtoBuilder? _display;
  MediaDisplayResponseDtoBuilder get display =>
      _$this._display ??= MediaDisplayResponseDtoBuilder();
  set display(MediaDisplayResponseDtoBuilder? display) =>
      _$this._display = display;

  num? _width;
  num? get width => _$this._width;
  set width(num? width) => _$this._width = width;

  num? _height;
  num? get height => _$this._height;
  set height(num? height) => _$this._height = height;

  bool? _animated;
  bool? get animated => _$this._animated;
  set animated(bool? animated) => _$this._animated = animated;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _subthreadId;
  String? get subthreadId => _$this._subthreadId;
  set subthreadId(String? subthreadId) => _$this._subthreadId = subthreadId;

  String? _parentPostId;
  String? get parentPostId => _$this._parentPostId;
  set parentPostId(String? parentPostId) => _$this._parentPostId = parentPostId;

  String? _momentId;
  String? get momentId => _$this._momentId;
  set momentId(String? momentId) => _$this._momentId = momentId;

  String? _parentCommentId;
  String? get parentCommentId => _$this._parentCommentId;
  set parentCommentId(String? parentCommentId) =>
      _$this._parentCommentId = parentCommentId;

  num? _floorNumber;
  num? get floorNumber => _$this._floorNumber;
  set floorNumber(num? floorNumber) => _$this._floorNumber = floorNumber;

  GalleryImageDtoBuilder() {
    GalleryImageDto._defaults(this);
  }

  GalleryImageDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _sourceId = $v.sourceId;
      _sourceVersion = $v.sourceVersion;
      _imageIndex = $v.imageIndex;
      _imageCount = $v.imageCount;
      _mediaId = $v.mediaId;
      _url = $v.url;
      _display = $v.display?.toBuilder();
      _width = $v.width;
      _height = $v.height;
      _animated = $v.animated;
      _threadId = $v.threadId;
      _subthreadId = $v.subthreadId;
      _parentPostId = $v.parentPostId;
      _momentId = $v.momentId;
      _parentCommentId = $v.parentCommentId;
      _floorNumber = $v.floorNumber;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GalleryImageDto other) {
    _$v = other as _$GalleryImageDto;
  }

  @override
  void update(void Function(GalleryImageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GalleryImageDto build() => _build();

  _$GalleryImageDto _build() {
    _$GalleryImageDto _$result;
    try {
      _$result =
          _$v ??
          _$GalleryImageDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GalleryImageDto',
              'id',
            ),
            sourceId: BuiltValueNullFieldError.checkNotNull(
              sourceId,
              r'GalleryImageDto',
              'sourceId',
            ),
            sourceVersion: BuiltValueNullFieldError.checkNotNull(
              sourceVersion,
              r'GalleryImageDto',
              'sourceVersion',
            ),
            imageIndex: BuiltValueNullFieldError.checkNotNull(
              imageIndex,
              r'GalleryImageDto',
              'imageIndex',
            ),
            imageCount: BuiltValueNullFieldError.checkNotNull(
              imageCount,
              r'GalleryImageDto',
              'imageCount',
            ),
            mediaId: mediaId,
            url: BuiltValueNullFieldError.checkNotNull(
              url,
              r'GalleryImageDto',
              'url',
            ),
            display: _display?.build(),
            width: width,
            height: height,
            animated: BuiltValueNullFieldError.checkNotNull(
              animated,
              r'GalleryImageDto',
              'animated',
            ),
            threadId: threadId,
            subthreadId: subthreadId,
            parentPostId: parentPostId,
            momentId: momentId,
            parentCommentId: parentCommentId,
            floorNumber: floorNumber,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'display';
        _display?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GalleryImageDto',
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
