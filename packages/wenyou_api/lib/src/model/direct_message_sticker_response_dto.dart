//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_message_sticker_response_dto.g.dart';

/// DirectMessageStickerResponseDto
///
/// Properties:
/// * [id]
/// * [url]
/// * [thumbnailUrl]
/// * [mediumUrl]
/// * [contentType]
/// * [width]
/// * [height]
/// * [animated]
/// * [frameCount]
/// * [durationMs]
@BuiltValue()
abstract class DirectMessageStickerResponseDto implements Built<DirectMessageStickerResponseDto, DirectMessageStickerResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'thumbnailUrl')
  String? get thumbnailUrl;

  @BuiltValueField(wireName: r'mediumUrl')
  String? get mediumUrl;

  @BuiltValueField(wireName: r'contentType')
  String? get contentType;

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

  DirectMessageStickerResponseDto._();

  factory DirectMessageStickerResponseDto([void updates(DirectMessageStickerResponseDtoBuilder b)]) = _$DirectMessageStickerResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectMessageStickerResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectMessageStickerResponseDto> get serializer => _$DirectMessageStickerResponseDtoSerializer();
}

class _$DirectMessageStickerResponseDtoSerializer implements PrimitiveSerializer<DirectMessageStickerResponseDto> {
  @override
  final Iterable<Type> types = const [DirectMessageStickerResponseDto, _$DirectMessageStickerResponseDto];

  @override
  final String wireName = r'DirectMessageStickerResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectMessageStickerResponseDto object, {
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
    yield object.thumbnailUrl == null ? null : serializers.serialize(
      object.thumbnailUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'mediumUrl';
    yield object.mediumUrl == null ? null : serializers.serialize(
      object.mediumUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'contentType';
    yield object.contentType == null ? null : serializers.serialize(
      object.contentType,
      specifiedType: const FullType.nullable(String),
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
    DirectMessageStickerResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectMessageStickerResponseDtoBuilder result,
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.thumbnailUrl = valueDes;
          break;
        case r'mediumUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mediumUrl = valueDes;
          break;
        case r'contentType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.contentType = valueDes;
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
  DirectMessageStickerResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectMessageStickerResponseDtoBuilder();
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
