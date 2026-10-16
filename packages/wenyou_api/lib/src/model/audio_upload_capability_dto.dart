//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'audio_upload_capability_dto.g.dart';

/// AudioUploadCapabilityDto
///
/// Properties:
/// * [version]
/// * [maxBytes]
/// * [maxDurationMs]
/// * [contentTypes]
/// * [outputContentType]
@BuiltValue()
abstract class AudioUploadCapabilityDto implements Built<AudioUploadCapabilityDto, AudioUploadCapabilityDtoBuilder> {
  @BuiltValueField(wireName: r'version')
  AudioUploadCapabilityDtoVersionEnum get version;
  // enum versionEnum {  1,  };

  @BuiltValueField(wireName: r'maxBytes')
  num get maxBytes;

  @BuiltValueField(wireName: r'maxDurationMs')
  num get maxDurationMs;

  @BuiltValueField(wireName: r'contentTypes')
  BuiltList<AudioUploadCapabilityDtoContentTypesEnum> get contentTypes;
  // enum contentTypesEnum {  audio/mpeg,  audio/mp4,  audio/wav,  audio/ogg,  audio/flac,  };

  @BuiltValueField(wireName: r'outputContentType')
  AudioUploadCapabilityDtoOutputContentTypeEnum get outputContentType;
  // enum outputContentTypeEnum {  audio/mpeg,  };

  AudioUploadCapabilityDto._();

  factory AudioUploadCapabilityDto([void updates(AudioUploadCapabilityDtoBuilder b)]) = _$AudioUploadCapabilityDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AudioUploadCapabilityDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AudioUploadCapabilityDto> get serializer => _$AudioUploadCapabilityDtoSerializer();
}

class _$AudioUploadCapabilityDtoSerializer implements PrimitiveSerializer<AudioUploadCapabilityDto> {
  @override
  final Iterable<Type> types = const [AudioUploadCapabilityDto, _$AudioUploadCapabilityDto];

  @override
  final String wireName = r'AudioUploadCapabilityDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AudioUploadCapabilityDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(AudioUploadCapabilityDtoVersionEnum),
    );
    yield r'maxBytes';
    yield serializers.serialize(
      object.maxBytes,
      specifiedType: const FullType(num),
    );
    yield r'maxDurationMs';
    yield serializers.serialize(
      object.maxDurationMs,
      specifiedType: const FullType(num),
    );
    yield r'contentTypes';
    yield serializers.serialize(
      object.contentTypes,
      specifiedType: const FullType(BuiltList, [FullType(AudioUploadCapabilityDtoContentTypesEnum)]),
    );
    yield r'outputContentType';
    yield serializers.serialize(
      object.outputContentType,
      specifiedType: const FullType(AudioUploadCapabilityDtoOutputContentTypeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AudioUploadCapabilityDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AudioUploadCapabilityDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AudioUploadCapabilityDtoVersionEnum),
          ) as AudioUploadCapabilityDtoVersionEnum;
          result.version = valueDes;
          break;
        case r'maxBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.maxBytes = valueDes;
          break;
        case r'maxDurationMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.maxDurationMs = valueDes;
          break;
        case r'contentTypes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AudioUploadCapabilityDtoContentTypesEnum)]),
          ) as BuiltList<AudioUploadCapabilityDtoContentTypesEnum>;
          result.contentTypes.replace(valueDes);
          break;
        case r'outputContentType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AudioUploadCapabilityDtoOutputContentTypeEnum),
          ) as AudioUploadCapabilityDtoOutputContentTypeEnum;
          result.outputContentType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AudioUploadCapabilityDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AudioUploadCapabilityDtoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class AudioUploadCapabilityDtoVersionEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 1)
  static const AudioUploadCapabilityDtoVersionEnum n1 = _$audioUploadCapabilityDtoVersionEnum_n1;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const AudioUploadCapabilityDtoVersionEnum unknownDefaultOpenApi = _$audioUploadCapabilityDtoVersionEnum_unknownDefaultOpenApi;

  static Serializer<AudioUploadCapabilityDtoVersionEnum> get serializer => _$audioUploadCapabilityDtoVersionEnumSerializer;

  const AudioUploadCapabilityDtoVersionEnum._(String name): super(name);

  static BuiltSet<AudioUploadCapabilityDtoVersionEnum> get values => _$audioUploadCapabilityDtoVersionEnumValues;
  static AudioUploadCapabilityDtoVersionEnum valueOf(String name) => _$audioUploadCapabilityDtoVersionEnumValueOf(name);
}

class AudioUploadCapabilityDtoContentTypesEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'audio/mpeg')
  static const AudioUploadCapabilityDtoContentTypesEnum audioSlashMpeg = _$audioUploadCapabilityDtoContentTypesEnum_audioSlashMpeg;
  @BuiltValueEnumConst(wireName: r'audio/mp4')
  static const AudioUploadCapabilityDtoContentTypesEnum audioSlashMp4 = _$audioUploadCapabilityDtoContentTypesEnum_audioSlashMp4;
  @BuiltValueEnumConst(wireName: r'audio/wav')
  static const AudioUploadCapabilityDtoContentTypesEnum audioSlashWav = _$audioUploadCapabilityDtoContentTypesEnum_audioSlashWav;
  @BuiltValueEnumConst(wireName: r'audio/ogg')
  static const AudioUploadCapabilityDtoContentTypesEnum audioSlashOgg = _$audioUploadCapabilityDtoContentTypesEnum_audioSlashOgg;
  @BuiltValueEnumConst(wireName: r'audio/flac')
  static const AudioUploadCapabilityDtoContentTypesEnum audioSlashFlac = _$audioUploadCapabilityDtoContentTypesEnum_audioSlashFlac;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AudioUploadCapabilityDtoContentTypesEnum unknownDefaultOpenApi = _$audioUploadCapabilityDtoContentTypesEnum_unknownDefaultOpenApi;

  static Serializer<AudioUploadCapabilityDtoContentTypesEnum> get serializer => _$audioUploadCapabilityDtoContentTypesEnumSerializer;

  const AudioUploadCapabilityDtoContentTypesEnum._(String name): super(name);

  static BuiltSet<AudioUploadCapabilityDtoContentTypesEnum> get values => _$audioUploadCapabilityDtoContentTypesEnumValues;
  static AudioUploadCapabilityDtoContentTypesEnum valueOf(String name) => _$audioUploadCapabilityDtoContentTypesEnumValueOf(name);
}

class AudioUploadCapabilityDtoOutputContentTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'audio/mpeg')
  static const AudioUploadCapabilityDtoOutputContentTypeEnum audioSlashMpeg = _$audioUploadCapabilityDtoOutputContentTypeEnum_audioSlashMpeg;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AudioUploadCapabilityDtoOutputContentTypeEnum unknownDefaultOpenApi = _$audioUploadCapabilityDtoOutputContentTypeEnum_unknownDefaultOpenApi;

  static Serializer<AudioUploadCapabilityDtoOutputContentTypeEnum> get serializer => _$audioUploadCapabilityDtoOutputContentTypeEnumSerializer;

  const AudioUploadCapabilityDtoOutputContentTypeEnum._(String name): super(name);

  static BuiltSet<AudioUploadCapabilityDtoOutputContentTypeEnum> get values => _$audioUploadCapabilityDtoOutputContentTypeEnumValues;
  static AudioUploadCapabilityDtoOutputContentTypeEnum valueOf(String name) => _$audioUploadCapabilityDtoOutputContentTypeEnumValueOf(name);
}
