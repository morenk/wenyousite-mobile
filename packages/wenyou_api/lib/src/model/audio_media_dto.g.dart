// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_media_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AudioMediaDtoContentTypeEnum
_$audioMediaDtoContentTypeEnum_audioSlashMpeg =
    const AudioMediaDtoContentTypeEnum._('audioSlashMpeg');
const AudioMediaDtoContentTypeEnum
_$audioMediaDtoContentTypeEnum_unknownDefaultOpenApi =
    const AudioMediaDtoContentTypeEnum._('unknownDefaultOpenApi');

AudioMediaDtoContentTypeEnum _$audioMediaDtoContentTypeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'audioSlashMpeg':
      return _$audioMediaDtoContentTypeEnum_audioSlashMpeg;
    case 'unknownDefaultOpenApi':
      return _$audioMediaDtoContentTypeEnum_unknownDefaultOpenApi;
    default:
      return _$audioMediaDtoContentTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AudioMediaDtoContentTypeEnum>
_$audioMediaDtoContentTypeEnumValues =
    BuiltSet<AudioMediaDtoContentTypeEnum>(const <AudioMediaDtoContentTypeEnum>[
      _$audioMediaDtoContentTypeEnum_audioSlashMpeg,
      _$audioMediaDtoContentTypeEnum_unknownDefaultOpenApi,
    ]);

Serializer<AudioMediaDtoContentTypeEnum>
_$audioMediaDtoContentTypeEnumSerializer =
    _$AudioMediaDtoContentTypeEnumSerializer();

class _$AudioMediaDtoContentTypeEnumSerializer
    implements PrimitiveSerializer<AudioMediaDtoContentTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'audioSlashMpeg': 'audio/mpeg',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'audio/mpeg': 'audioSlashMpeg',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AudioMediaDtoContentTypeEnum];
  @override
  final String wireName = 'AudioMediaDtoContentTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AudioMediaDtoContentTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AudioMediaDtoContentTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AudioMediaDtoContentTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AudioMediaDto extends AudioMediaDto {
  @override
  final String sourceUrl;
  @override
  final String mediaId;
  @override
  final AudioMediaDtoContentTypeEnum contentType;
  @override
  final num size;
  @override
  final num durationMs;

  factory _$AudioMediaDto([void Function(AudioMediaDtoBuilder)? updates]) =>
      (AudioMediaDtoBuilder()..update(updates))._build();

  _$AudioMediaDto._({
    required this.sourceUrl,
    required this.mediaId,
    required this.contentType,
    required this.size,
    required this.durationMs,
  }) : super._();
  @override
  AudioMediaDto rebuild(void Function(AudioMediaDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AudioMediaDtoBuilder toBuilder() => AudioMediaDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AudioMediaDto &&
        sourceUrl == other.sourceUrl &&
        mediaId == other.mediaId &&
        contentType == other.contentType &&
        size == other.size &&
        durationMs == other.durationMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sourceUrl.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, durationMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AudioMediaDto')
          ..add('sourceUrl', sourceUrl)
          ..add('mediaId', mediaId)
          ..add('contentType', contentType)
          ..add('size', size)
          ..add('durationMs', durationMs))
        .toString();
  }
}

class AudioMediaDtoBuilder
    implements Builder<AudioMediaDto, AudioMediaDtoBuilder> {
  _$AudioMediaDto? _$v;

  String? _sourceUrl;
  String? get sourceUrl => _$this._sourceUrl;
  set sourceUrl(String? sourceUrl) => _$this._sourceUrl = sourceUrl;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  AudioMediaDtoContentTypeEnum? _contentType;
  AudioMediaDtoContentTypeEnum? get contentType => _$this._contentType;
  set contentType(AudioMediaDtoContentTypeEnum? contentType) =>
      _$this._contentType = contentType;

  num? _size;
  num? get size => _$this._size;
  set size(num? size) => _$this._size = size;

  num? _durationMs;
  num? get durationMs => _$this._durationMs;
  set durationMs(num? durationMs) => _$this._durationMs = durationMs;

  AudioMediaDtoBuilder() {
    AudioMediaDto._defaults(this);
  }

  AudioMediaDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sourceUrl = $v.sourceUrl;
      _mediaId = $v.mediaId;
      _contentType = $v.contentType;
      _size = $v.size;
      _durationMs = $v.durationMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AudioMediaDto other) {
    _$v = other as _$AudioMediaDto;
  }

  @override
  void update(void Function(AudioMediaDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AudioMediaDto build() => _build();

  _$AudioMediaDto _build() {
    final _$result =
        _$v ??
        _$AudioMediaDto._(
          sourceUrl: BuiltValueNullFieldError.checkNotNull(
            sourceUrl,
            r'AudioMediaDto',
            'sourceUrl',
          ),
          mediaId: BuiltValueNullFieldError.checkNotNull(
            mediaId,
            r'AudioMediaDto',
            'mediaId',
          ),
          contentType: BuiltValueNullFieldError.checkNotNull(
            contentType,
            r'AudioMediaDto',
            'contentType',
          ),
          size: BuiltValueNullFieldError.checkNotNull(
            size,
            r'AudioMediaDto',
            'size',
          ),
          durationMs: BuiltValueNullFieldError.checkNotNull(
            durationMs,
            r'AudioMediaDto',
            'durationMs',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
