//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moment_sticker_response_dto.g.dart';

/// MomentStickerResponseDto
///
/// Properties:
/// * [id]
/// * [url]
/// * [thumbnailUrl]
/// * [mediumUrl]
/// * [width]
/// * [height]
/// * [animated]
/// * [frameCount]
/// * [durationMs]
@BuiltValue()
abstract class MomentStickerResponseDto implements Built<MomentStickerResponseDto, MomentStickerResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'thumbnailUrl')
  String get thumbnailUrl;

  @BuiltValueField(wireName: r'mediumUrl')
  String get mediumUrl;

  @BuiltValueField(wireName: r'width')
  num? get width;

  @BuiltValueField(wireName: r'height')
  num? get height;

  @BuiltValueField(wireName: r'animated')
  bool get animated;

  @BuiltValueField(wireName: r'frameCount')
  num get frameCount;

  @BuiltValueField(wireName: r'durationMs')
  num get durationMs;

  MomentStickerResponseDto._();

  factory MomentStickerResponseDto([void updates(MomentStickerResponseDtoBuilder b)]) = _$MomentStickerResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentStickerResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentStickerResponseDto> get serializer => _$MomentStickerResponseDtoSerializer();
}

class _$MomentStickerResponseDtoSerializer implements PrimitiveSerializer<MomentStickerResponseDto> {
  @override
  final Iterable<Type> types = const [MomentStickerResponseDto, _$MomentStickerResponseDto];

  @override
  final String wireName = r'MomentStickerResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentStickerResponseDto object, {
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
    yield r'mediumUrl';
    yield serializers.serialize(
      object.mediumUrl,
      specifiedType: const FullType(String),
    );
    yield r'width';
    yield object.width == null ? null : serializers.serialize(
      object.width,
      specifiedType: const FullType.nullable(num),
    );
    yield r'height';
    yield object.height == null ? null : serializers.serialize(
      object.height,
      specifiedType: const FullType.nullable(num),
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
    MomentStickerResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentStickerResponseDtoBuilder result,
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
        case r'mediumUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediumUrl = valueDes;
          break;
        case r'width':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.width = valueDes;
          break;
        case r'height':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
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
  MomentStickerResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentStickerResponseDtoBuilder();
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
