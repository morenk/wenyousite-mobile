// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MediaResponseDtoStatusEnum _$mediaResponseDtoStatusEnum_UPLOADING =
    const MediaResponseDtoStatusEnum._('UPLOADING');
const MediaResponseDtoStatusEnum _$mediaResponseDtoStatusEnum_PROCESSING =
    const MediaResponseDtoStatusEnum._('PROCESSING');
const MediaResponseDtoStatusEnum _$mediaResponseDtoStatusEnum_COMPLETED =
    const MediaResponseDtoStatusEnum._('COMPLETED');
const MediaResponseDtoStatusEnum _$mediaResponseDtoStatusEnum_FAILED =
    const MediaResponseDtoStatusEnum._('FAILED');
const MediaResponseDtoStatusEnum
_$mediaResponseDtoStatusEnum_unknownDefaultOpenApi =
    const MediaResponseDtoStatusEnum._('unknownDefaultOpenApi');

MediaResponseDtoStatusEnum _$mediaResponseDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'UPLOADING':
      return _$mediaResponseDtoStatusEnum_UPLOADING;
    case 'PROCESSING':
      return _$mediaResponseDtoStatusEnum_PROCESSING;
    case 'COMPLETED':
      return _$mediaResponseDtoStatusEnum_COMPLETED;
    case 'FAILED':
      return _$mediaResponseDtoStatusEnum_FAILED;
    case 'unknownDefaultOpenApi':
      return _$mediaResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$mediaResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MediaResponseDtoStatusEnum> _$mediaResponseDtoStatusEnumValues =
    BuiltSet<MediaResponseDtoStatusEnum>(const <MediaResponseDtoStatusEnum>[
      _$mediaResponseDtoStatusEnum_UPLOADING,
      _$mediaResponseDtoStatusEnum_PROCESSING,
      _$mediaResponseDtoStatusEnum_COMPLETED,
      _$mediaResponseDtoStatusEnum_FAILED,
      _$mediaResponseDtoStatusEnum_unknownDefaultOpenApi,
    ]);

Serializer<MediaResponseDtoStatusEnum> _$mediaResponseDtoStatusEnumSerializer =
    _$MediaResponseDtoStatusEnumSerializer();

class _$MediaResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<MediaResponseDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'UPLOADING': 'UPLOADING',
    'PROCESSING': 'PROCESSING',
    'COMPLETED': 'COMPLETED',
    'FAILED': 'FAILED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'UPLOADING': 'UPLOADING',
    'PROCESSING': 'PROCESSING',
    'COMPLETED': 'COMPLETED',
    'FAILED': 'FAILED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[MediaResponseDtoStatusEnum];
  @override
  final String wireName = 'MediaResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    MediaResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MediaResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MediaResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MediaResponseDto extends MediaResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String url;
  @override
  final String? thumbnailUrl;
  @override
  final String? feedUrl;
  @override
  final String? mediumUrl;
  @override
  final String key;
  @override
  final String? contentType;
  @override
  final num? size;
  @override
  final num? width;
  @override
  final num? height;
  @override
  final MediaResponseDtoStatusEnum status;
  @override
  final DateTime createdAt;

  factory _$MediaResponseDto([
    void Function(MediaResponseDtoBuilder)? updates,
  ]) => (MediaResponseDtoBuilder()..update(updates))._build();

  _$MediaResponseDto._({
    required this.id,
    required this.userId,
    required this.url,
    this.thumbnailUrl,
    this.feedUrl,
    this.mediumUrl,
    required this.key,
    this.contentType,
    this.size,
    this.width,
    this.height,
    required this.status,
    required this.createdAt,
  }) : super._();
  @override
  MediaResponseDto rebuild(void Function(MediaResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MediaResponseDtoBuilder toBuilder() =>
      MediaResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MediaResponseDto &&
        id == other.id &&
        userId == other.userId &&
        url == other.url &&
        thumbnailUrl == other.thumbnailUrl &&
        feedUrl == other.feedUrl &&
        mediumUrl == other.mediumUrl &&
        key == other.key &&
        contentType == other.contentType &&
        size == other.size &&
        width == other.width &&
        height == other.height &&
        status == other.status &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, thumbnailUrl.hashCode);
    _$hash = $jc(_$hash, feedUrl.hashCode);
    _$hash = $jc(_$hash, mediumUrl.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, width.hashCode);
    _$hash = $jc(_$hash, height.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MediaResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('url', url)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('feedUrl', feedUrl)
          ..add('mediumUrl', mediumUrl)
          ..add('key', key)
          ..add('contentType', contentType)
          ..add('size', size)
          ..add('width', width)
          ..add('height', height)
          ..add('status', status)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class MediaResponseDtoBuilder
    implements Builder<MediaResponseDto, MediaResponseDtoBuilder> {
  _$MediaResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

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

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _contentType;
  String? get contentType => _$this._contentType;
  set contentType(String? contentType) => _$this._contentType = contentType;

  num? _size;
  num? get size => _$this._size;
  set size(num? size) => _$this._size = size;

  num? _width;
  num? get width => _$this._width;
  set width(num? width) => _$this._width = width;

  num? _height;
  num? get height => _$this._height;
  set height(num? height) => _$this._height = height;

  MediaResponseDtoStatusEnum? _status;
  MediaResponseDtoStatusEnum? get status => _$this._status;
  set status(MediaResponseDtoStatusEnum? status) => _$this._status = status;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  MediaResponseDtoBuilder() {
    MediaResponseDto._defaults(this);
  }

  MediaResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _url = $v.url;
      _thumbnailUrl = $v.thumbnailUrl;
      _feedUrl = $v.feedUrl;
      _mediumUrl = $v.mediumUrl;
      _key = $v.key;
      _contentType = $v.contentType;
      _size = $v.size;
      _width = $v.width;
      _height = $v.height;
      _status = $v.status;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MediaResponseDto other) {
    _$v = other as _$MediaResponseDto;
  }

  @override
  void update(void Function(MediaResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MediaResponseDto build() => _build();

  _$MediaResponseDto _build() {
    final _$result =
        _$v ??
        _$MediaResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'MediaResponseDto',
            'id',
          ),
          userId: BuiltValueNullFieldError.checkNotNull(
            userId,
            r'MediaResponseDto',
            'userId',
          ),
          url: BuiltValueNullFieldError.checkNotNull(
            url,
            r'MediaResponseDto',
            'url',
          ),
          thumbnailUrl: thumbnailUrl,
          feedUrl: feedUrl,
          mediumUrl: mediumUrl,
          key: BuiltValueNullFieldError.checkNotNull(
            key,
            r'MediaResponseDto',
            'key',
          ),
          contentType: contentType,
          size: size,
          width: width,
          height: height,
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'MediaResponseDto',
            'status',
          ),
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'MediaResponseDto',
            'createdAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
