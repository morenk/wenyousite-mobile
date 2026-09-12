//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'media_display_response_dto.g.dart';

/// MediaDisplayResponseDto
///
/// Properties:
/// * [url] - 可信完整展示资源；不得据来源 URL 猜测或改写扩展名
/// * [contentType]
/// * [width]
/// * [height]
/// * [bytes]
/// * [animated]
/// * [frameCount] - 静态图为 1；动画必须保留全部帧
/// * [durationMs] - 完整单轮时长；静态图为 0
/// * [loopCount] - 0 无限循环，1 播放一次；静态图固定 1
@BuiltValue()
abstract class MediaDisplayResponseDto implements Built<MediaDisplayResponseDto, MediaDisplayResponseDtoBuilder> {
  /// 可信完整展示资源；不得据来源 URL 猜测或改写扩展名
  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'contentType')
  MediaDisplayResponseDtoContentTypeEnum get contentType;
  // enum contentTypeEnum {  image/webp,  };

  @BuiltValueField(wireName: r'width')
  num get width;

  @BuiltValueField(wireName: r'height')
  num get height;

  @BuiltValueField(wireName: r'bytes')
  num get bytes;

  @BuiltValueField(wireName: r'animated')
  bool get animated;

  /// 静态图为 1；动画必须保留全部帧
  @BuiltValueField(wireName: r'frameCount')
  num get frameCount;

  /// 完整单轮时长；静态图为 0
  @BuiltValueField(wireName: r'durationMs')
  num get durationMs;

  /// 0 无限循环，1 播放一次；静态图固定 1
  @BuiltValueField(wireName: r'loopCount')
  num get loopCount;

  MediaDisplayResponseDto._();

  factory MediaDisplayResponseDto([void updates(MediaDisplayResponseDtoBuilder b)]) = _$MediaDisplayResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MediaDisplayResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MediaDisplayResponseDto> get serializer => _$MediaDisplayResponseDtoSerializer();
}

class _$MediaDisplayResponseDtoSerializer implements PrimitiveSerializer<MediaDisplayResponseDto> {
  @override
  final Iterable<Type> types = const [MediaDisplayResponseDto, _$MediaDisplayResponseDto];

  @override
  final String wireName = r'MediaDisplayResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MediaDisplayResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'contentType';
    yield serializers.serialize(
      object.contentType,
      specifiedType: const FullType(MediaDisplayResponseDtoContentTypeEnum),
    );
    yield r'width';
    yield serializers.serialize(
      object.width,
      specifiedType: const FullType(num),
    );
    yield r'height';
    yield serializers.serialize(
      object.height,
      specifiedType: const FullType(num),
    );
    yield r'bytes';
    yield serializers.serialize(
      object.bytes,
      specifiedType: const FullType(num),
    );
    yield r'animated';
    yield serializers.serialize(
      object.animated,
      specifiedType: const FullType(bool),
    );
    yield r'frameCount';
    yield serializers.serialize(
      object.frameCount,
      specifiedType: const FullType(num),
    );
    yield r'durationMs';
    yield serializers.serialize(
      object.durationMs,
      specifiedType: const FullType(num),
    );
    yield r'loopCount';
    yield serializers.serialize(
      object.loopCount,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MediaDisplayResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MediaDisplayResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'contentType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MediaDisplayResponseDtoContentTypeEnum),
          ) as MediaDisplayResponseDtoContentTypeEnum;
          result.contentType = valueDes;
          break;
        case r'width':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.width = valueDes;
          break;
        case r'height':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.height = valueDes;
          break;
        case r'bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.bytes = valueDes;
          break;
        case r'animated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.animated = valueDes;
          break;
        case r'frameCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.frameCount = valueDes;
          break;
        case r'durationMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.durationMs = valueDes;
          break;
        case r'loopCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.loopCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MediaDisplayResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MediaDisplayResponseDtoBuilder();
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

class MediaDisplayResponseDtoContentTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'image/webp')
  static const MediaDisplayResponseDtoContentTypeEnum imageSlashWebp = _$mediaDisplayResponseDtoContentTypeEnum_imageSlashWebp;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const MediaDisplayResponseDtoContentTypeEnum unknownDefaultOpenApi = _$mediaDisplayResponseDtoContentTypeEnum_unknownDefaultOpenApi;

  static Serializer<MediaDisplayResponseDtoContentTypeEnum> get serializer => _$mediaDisplayResponseDtoContentTypeEnumSerializer;

  const MediaDisplayResponseDtoContentTypeEnum._(String name): super(name);

  static BuiltSet<MediaDisplayResponseDtoContentTypeEnum> get values => _$mediaDisplayResponseDtoContentTypeEnumValues;
  static MediaDisplayResponseDtoContentTypeEnum valueOf(String name) => _$mediaDisplayResponseDtoContentTypeEnumValueOf(name);
}
