//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sticker_asset_response_dto.g.dart';

/// StickerAssetResponseDto
///
/// Properties:
/// * [id]
/// * [url]
/// * [thumbnailUrl]
/// * [width]
/// * [height]
/// * [animated]
/// * [frameCount]
/// * [durationMs]
@BuiltValue()
abstract class StickerAssetResponseDto implements Built<StickerAssetResponseDto, StickerAssetResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'thumbnailUrl')
  String get thumbnailUrl;

  @BuiltValueField(wireName: r'width')
  num get width;

  @BuiltValueField(wireName: r'height')
  num get height;

  @BuiltValueField(wireName: r'animated')
  bool get animated;

  @BuiltValueField(wireName: r'frameCount')
  num get frameCount;

  @BuiltValueField(wireName: r'durationMs')
  num get durationMs;

  StickerAssetResponseDto._();

  factory StickerAssetResponseDto([void updates(StickerAssetResponseDtoBuilder b)]) = _$StickerAssetResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickerAssetResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickerAssetResponseDto> get serializer => _$StickerAssetResponseDtoSerializer();
}

class _$StickerAssetResponseDtoSerializer implements PrimitiveSerializer<StickerAssetResponseDto> {
  @override
  final Iterable<Type> types = const [StickerAssetResponseDto, _$StickerAssetResponseDto];

  @override
  final String wireName = r'StickerAssetResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickerAssetResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'thumbnailUrl';
    yield serializers.serialize(
      object.thumbnailUrl,
      specifiedType: const FullType(String),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    StickerAssetResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickerAssetResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'thumbnailUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.thumbnailUrl = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StickerAssetResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickerAssetResponseDtoBuilder();
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
