//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'audio_media_dto.g.dart';

/// AudioMediaDto
///
/// Properties:
/// * [sourceUrl] - 正文普通链接的精确固定 URL；保存继续保留此 URL
/// * [mediaId]
/// * [contentType]
/// * [size] - 规范播放副本字节数
/// * [durationMs]
@BuiltValue()
abstract class AudioMediaDto implements Built<AudioMediaDto, AudioMediaDtoBuilder> {
  /// 正文普通链接的精确固定 URL；保存继续保留此 URL
  @BuiltValueField(wireName: r'sourceUrl')
  String get sourceUrl;

  @BuiltValueField(wireName: r'mediaId')
  String get mediaId;

  @BuiltValueField(wireName: r'contentType')
  AudioMediaDtoContentTypeEnum get contentType;
  // enum contentTypeEnum {  audio/mpeg,  };

  /// 规范播放副本字节数
  @BuiltValueField(wireName: r'size')
  num get size;

  @BuiltValueField(wireName: r'durationMs')
  num get durationMs;

  AudioMediaDto._();

  factory AudioMediaDto([void updates(AudioMediaDtoBuilder b)]) = _$AudioMediaDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AudioMediaDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AudioMediaDto> get serializer => _$AudioMediaDtoSerializer();
}

class _$AudioMediaDtoSerializer implements PrimitiveSerializer<AudioMediaDto> {
  @override
  final Iterable<Type> types = const [AudioMediaDto, _$AudioMediaDto];

  @override
  final String wireName = r'AudioMediaDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AudioMediaDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sourceUrl';
    yield serializers.serialize(
      object.sourceUrl,
      specifiedType: const FullType(String),
    );
    yield r'mediaId';
    yield serializers.serialize(
      object.mediaId,
      specifiedType: const FullType(String),
    );
    yield r'contentType';
    yield serializers.serialize(
      object.contentType,
      specifiedType: const FullType(AudioMediaDtoContentTypeEnum),
    );
    yield r'size';
    yield serializers.serialize(
      object.size,
      specifiedType: const FullType(num),
    );
    yield r'durationMs';
    yield serializers.serialize(
      object.durationMs,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AudioMediaDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AudioMediaDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sourceUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceUrl = valueDes;
          break;
        case r'mediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaId = valueDes;
          break;
        case r'contentType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AudioMediaDtoContentTypeEnum),
          ) as AudioMediaDtoContentTypeEnum;
          result.contentType = valueDes;
          break;
        case r'size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.size = valueDes;
          break;
        case r'durationMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.durationMs = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AudioMediaDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AudioMediaDtoBuilder();
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

class AudioMediaDtoContentTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'audio/mpeg')
  static const AudioMediaDtoContentTypeEnum audioSlashMpeg = _$audioMediaDtoContentTypeEnum_audioSlashMpeg;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AudioMediaDtoContentTypeEnum unknownDefaultOpenApi = _$audioMediaDtoContentTypeEnum_unknownDefaultOpenApi;

  static Serializer<AudioMediaDtoContentTypeEnum> get serializer => _$audioMediaDtoContentTypeEnumSerializer;

  const AudioMediaDtoContentTypeEnum._(String name): super(name);

  static BuiltSet<AudioMediaDtoContentTypeEnum> get values => _$audioMediaDtoContentTypeEnumValues;
  static AudioMediaDtoContentTypeEnum valueOf(String name) => _$audioMediaDtoContentTypeEnumValueOf(name);
}
