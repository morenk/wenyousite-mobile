// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_upload_capability_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AudioUploadCapabilityDtoVersionEnum
_$audioUploadCapabilityDtoVersionEnum_n1 =
    const AudioUploadCapabilityDtoVersionEnum._('n1');
const AudioUploadCapabilityDtoVersionEnum
_$audioUploadCapabilityDtoVersionEnum_unknownDefaultOpenApi =
    const AudioUploadCapabilityDtoVersionEnum._('unknownDefaultOpenApi');

AudioUploadCapabilityDtoVersionEnum
_$audioUploadCapabilityDtoVersionEnumValueOf(String name) {
  switch (name) {
    case 'n1':
      return _$audioUploadCapabilityDtoVersionEnum_n1;
    case 'unknownDefaultOpenApi':
      return _$audioUploadCapabilityDtoVersionEnum_unknownDefaultOpenApi;
    default:
      return _$audioUploadCapabilityDtoVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AudioUploadCapabilityDtoVersionEnum>
_$audioUploadCapabilityDtoVersionEnumValues =
    BuiltSet<AudioUploadCapabilityDtoVersionEnum>(
      const <AudioUploadCapabilityDtoVersionEnum>[
        _$audioUploadCapabilityDtoVersionEnum_n1,
        _$audioUploadCapabilityDtoVersionEnum_unknownDefaultOpenApi,
      ],
    );

const AudioUploadCapabilityDtoContentTypesEnum
_$audioUploadCapabilityDtoContentTypesEnum_audioSlashMpeg =
    const AudioUploadCapabilityDtoContentTypesEnum._('audioSlashMpeg');
const AudioUploadCapabilityDtoContentTypesEnum
_$audioUploadCapabilityDtoContentTypesEnum_audioSlashMp4 =
    const AudioUploadCapabilityDtoContentTypesEnum._('audioSlashMp4');
const AudioUploadCapabilityDtoContentTypesEnum
_$audioUploadCapabilityDtoContentTypesEnum_audioSlashWav =
    const AudioUploadCapabilityDtoContentTypesEnum._('audioSlashWav');
const AudioUploadCapabilityDtoContentTypesEnum
_$audioUploadCapabilityDtoContentTypesEnum_audioSlashOgg =
    const AudioUploadCapabilityDtoContentTypesEnum._('audioSlashOgg');
const AudioUploadCapabilityDtoContentTypesEnum
_$audioUploadCapabilityDtoContentTypesEnum_audioSlashFlac =
    const AudioUploadCapabilityDtoContentTypesEnum._('audioSlashFlac');
const AudioUploadCapabilityDtoContentTypesEnum
_$audioUploadCapabilityDtoContentTypesEnum_unknownDefaultOpenApi =
    const AudioUploadCapabilityDtoContentTypesEnum._('unknownDefaultOpenApi');

AudioUploadCapabilityDtoContentTypesEnum
_$audioUploadCapabilityDtoContentTypesEnumValueOf(String name) {
  switch (name) {
    case 'audioSlashMpeg':
      return _$audioUploadCapabilityDtoContentTypesEnum_audioSlashMpeg;
    case 'audioSlashMp4':
      return _$audioUploadCapabilityDtoContentTypesEnum_audioSlashMp4;
    case 'audioSlashWav':
      return _$audioUploadCapabilityDtoContentTypesEnum_audioSlashWav;
    case 'audioSlashOgg':
      return _$audioUploadCapabilityDtoContentTypesEnum_audioSlashOgg;
    case 'audioSlashFlac':
      return _$audioUploadCapabilityDtoContentTypesEnum_audioSlashFlac;
    case 'unknownDefaultOpenApi':
      return _$audioUploadCapabilityDtoContentTypesEnum_unknownDefaultOpenApi;
    default:
      return _$audioUploadCapabilityDtoContentTypesEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AudioUploadCapabilityDtoContentTypesEnum>
_$audioUploadCapabilityDtoContentTypesEnumValues =
    BuiltSet<AudioUploadCapabilityDtoContentTypesEnum>(
      const <AudioUploadCapabilityDtoContentTypesEnum>[
        _$audioUploadCapabilityDtoContentTypesEnum_audioSlashMpeg,
        _$audioUploadCapabilityDtoContentTypesEnum_audioSlashMp4,
        _$audioUploadCapabilityDtoContentTypesEnum_audioSlashWav,
        _$audioUploadCapabilityDtoContentTypesEnum_audioSlashOgg,
        _$audioUploadCapabilityDtoContentTypesEnum_audioSlashFlac,
        _$audioUploadCapabilityDtoContentTypesEnum_unknownDefaultOpenApi,
      ],
    );

const AudioUploadCapabilityDtoOutputContentTypeEnum
_$audioUploadCapabilityDtoOutputContentTypeEnum_audioSlashMpeg =
    const AudioUploadCapabilityDtoOutputContentTypeEnum._('audioSlashMpeg');
const AudioUploadCapabilityDtoOutputContentTypeEnum
_$audioUploadCapabilityDtoOutputContentTypeEnum_unknownDefaultOpenApi =
    const AudioUploadCapabilityDtoOutputContentTypeEnum._(
      'unknownDefaultOpenApi',
    );

AudioUploadCapabilityDtoOutputContentTypeEnum
_$audioUploadCapabilityDtoOutputContentTypeEnumValueOf(String name) {
  switch (name) {
    case 'audioSlashMpeg':
      return _$audioUploadCapabilityDtoOutputContentTypeEnum_audioSlashMpeg;
    case 'unknownDefaultOpenApi':
      return _$audioUploadCapabilityDtoOutputContentTypeEnum_unknownDefaultOpenApi;
    default:
      return _$audioUploadCapabilityDtoOutputContentTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AudioUploadCapabilityDtoOutputContentTypeEnum>
_$audioUploadCapabilityDtoOutputContentTypeEnumValues =
    BuiltSet<AudioUploadCapabilityDtoOutputContentTypeEnum>(
      const <AudioUploadCapabilityDtoOutputContentTypeEnum>[
        _$audioUploadCapabilityDtoOutputContentTypeEnum_audioSlashMpeg,
        _$audioUploadCapabilityDtoOutputContentTypeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AudioUploadCapabilityDtoVersionEnum>
_$audioUploadCapabilityDtoVersionEnumSerializer =
    _$AudioUploadCapabilityDtoVersionEnumSerializer();
Serializer<AudioUploadCapabilityDtoContentTypesEnum>
_$audioUploadCapabilityDtoContentTypesEnumSerializer =
    _$AudioUploadCapabilityDtoContentTypesEnumSerializer();
Serializer<AudioUploadCapabilityDtoOutputContentTypeEnum>
_$audioUploadCapabilityDtoOutputContentTypeEnumSerializer =
    _$AudioUploadCapabilityDtoOutputContentTypeEnumSerializer();

class _$AudioUploadCapabilityDtoVersionEnumSerializer
    implements PrimitiveSerializer<AudioUploadCapabilityDtoVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n1': 1,
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    1: 'n1',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AudioUploadCapabilityDtoVersionEnum,
  ];
  @override
  final String wireName = 'AudioUploadCapabilityDtoVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    AudioUploadCapabilityDtoVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AudioUploadCapabilityDtoVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AudioUploadCapabilityDtoVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AudioUploadCapabilityDtoContentTypesEnumSerializer
    implements PrimitiveSerializer<AudioUploadCapabilityDtoContentTypesEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'audioSlashMpeg': 'audio/mpeg',
    'audioSlashMp4': 'audio/mp4',
    'audioSlashWav': 'audio/wav',
    'audioSlashOgg': 'audio/ogg',
    'audioSlashFlac': 'audio/flac',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'audio/mpeg': 'audioSlashMpeg',
    'audio/mp4': 'audioSlashMp4',
    'audio/wav': 'audioSlashWav',
    'audio/ogg': 'audioSlashOgg',
    'audio/flac': 'audioSlashFlac',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AudioUploadCapabilityDtoContentTypesEnum,
  ];
  @override
  final String wireName = 'AudioUploadCapabilityDtoContentTypesEnum';

  @override
  Object serialize(
    Serializers serializers,
    AudioUploadCapabilityDtoContentTypesEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AudioUploadCapabilityDtoContentTypesEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AudioUploadCapabilityDtoContentTypesEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AudioUploadCapabilityDtoOutputContentTypeEnumSerializer
    implements
        PrimitiveSerializer<AudioUploadCapabilityDtoOutputContentTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'audioSlashMpeg': 'audio/mpeg',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'audio/mpeg': 'audioSlashMpeg',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AudioUploadCapabilityDtoOutputContentTypeEnum,
  ];
  @override
  final String wireName = 'AudioUploadCapabilityDtoOutputContentTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AudioUploadCapabilityDtoOutputContentTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AudioUploadCapabilityDtoOutputContentTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AudioUploadCapabilityDtoOutputContentTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AudioUploadCapabilityDto extends AudioUploadCapabilityDto {
  @override
  final AudioUploadCapabilityDtoVersionEnum version;
  @override
  final num maxBytes;
  @override
  final num maxDurationMs;
  @override
  final BuiltList<AudioUploadCapabilityDtoContentTypesEnum> contentTypes;
  @override
  final AudioUploadCapabilityDtoOutputContentTypeEnum outputContentType;

  factory _$AudioUploadCapabilityDto([
    void Function(AudioUploadCapabilityDtoBuilder)? updates,
  ]) => (AudioUploadCapabilityDtoBuilder()..update(updates))._build();

  _$AudioUploadCapabilityDto._({
    required this.version,
    required this.maxBytes,
    required this.maxDurationMs,
    required this.contentTypes,
    required this.outputContentType,
  }) : super._();
  @override
  AudioUploadCapabilityDto rebuild(
    void Function(AudioUploadCapabilityDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AudioUploadCapabilityDtoBuilder toBuilder() =>
      AudioUploadCapabilityDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AudioUploadCapabilityDto &&
        version == other.version &&
        maxBytes == other.maxBytes &&
        maxDurationMs == other.maxDurationMs &&
        contentTypes == other.contentTypes &&
        outputContentType == other.outputContentType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, maxBytes.hashCode);
    _$hash = $jc(_$hash, maxDurationMs.hashCode);
    _$hash = $jc(_$hash, contentTypes.hashCode);
    _$hash = $jc(_$hash, outputContentType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AudioUploadCapabilityDto')
          ..add('version', version)
          ..add('maxBytes', maxBytes)
          ..add('maxDurationMs', maxDurationMs)
          ..add('contentTypes', contentTypes)
          ..add('outputContentType', outputContentType))
        .toString();
  }
}

class AudioUploadCapabilityDtoBuilder
    implements
        Builder<AudioUploadCapabilityDto, AudioUploadCapabilityDtoBuilder> {
  _$AudioUploadCapabilityDto? _$v;

  AudioUploadCapabilityDtoVersionEnum? _version;
  AudioUploadCapabilityDtoVersionEnum? get version => _$this._version;
  set version(AudioUploadCapabilityDtoVersionEnum? version) =>
      _$this._version = version;

  num? _maxBytes;
  num? get maxBytes => _$this._maxBytes;
  set maxBytes(num? maxBytes) => _$this._maxBytes = maxBytes;

  num? _maxDurationMs;
  num? get maxDurationMs => _$this._maxDurationMs;
  set maxDurationMs(num? maxDurationMs) =>
      _$this._maxDurationMs = maxDurationMs;

  ListBuilder<AudioUploadCapabilityDtoContentTypesEnum>? _contentTypes;
  ListBuilder<AudioUploadCapabilityDtoContentTypesEnum> get contentTypes =>
      _$this._contentTypes ??=
          ListBuilder<AudioUploadCapabilityDtoContentTypesEnum>();
  set contentTypes(
    ListBuilder<AudioUploadCapabilityDtoContentTypesEnum>? contentTypes,
  ) => _$this._contentTypes = contentTypes;

  AudioUploadCapabilityDtoOutputContentTypeEnum? _outputContentType;
  AudioUploadCapabilityDtoOutputContentTypeEnum? get outputContentType =>
      _$this._outputContentType;
  set outputContentType(
    AudioUploadCapabilityDtoOutputContentTypeEnum? outputContentType,
  ) => _$this._outputContentType = outputContentType;

  AudioUploadCapabilityDtoBuilder() {
    AudioUploadCapabilityDto._defaults(this);
  }

  AudioUploadCapabilityDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _maxBytes = $v.maxBytes;
      _maxDurationMs = $v.maxDurationMs;
      _contentTypes = $v.contentTypes.toBuilder();
      _outputContentType = $v.outputContentType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AudioUploadCapabilityDto other) {
    _$v = other as _$AudioUploadCapabilityDto;
  }

  @override
  void update(void Function(AudioUploadCapabilityDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AudioUploadCapabilityDto build() => _build();

  _$AudioUploadCapabilityDto _build() {
    _$AudioUploadCapabilityDto _$result;
    try {
      _$result =
          _$v ??
          _$AudioUploadCapabilityDto._(
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'AudioUploadCapabilityDto',
              'version',
            ),
            maxBytes: BuiltValueNullFieldError.checkNotNull(
              maxBytes,
              r'AudioUploadCapabilityDto',
              'maxBytes',
            ),
            maxDurationMs: BuiltValueNullFieldError.checkNotNull(
              maxDurationMs,
              r'AudioUploadCapabilityDto',
              'maxDurationMs',
            ),
            contentTypes: contentTypes.build(),
            outputContentType: BuiltValueNullFieldError.checkNotNull(
              outputContentType,
              r'AudioUploadCapabilityDto',
              'outputContentType',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'contentTypes';
        contentTypes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AudioUploadCapabilityDto',
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
