//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_message_media_response_dto.g.dart';

/// DirectMessageMediaResponseDto
///
/// Properties:
/// * [id]
/// * [url]
/// * [thumbnailUrl]
/// * [mediumUrl]
/// * [contentType]
/// * [width]
/// * [height]
@BuiltValue()
abstract class DirectMessageMediaResponseDto implements Built<DirectMessageMediaResponseDto, DirectMessageMediaResponseDtoBuilder> {
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

  DirectMessageMediaResponseDto._();

  factory DirectMessageMediaResponseDto([void updates(DirectMessageMediaResponseDtoBuilder b)]) = _$DirectMessageMediaResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectMessageMediaResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectMessageMediaResponseDto> get serializer => _$DirectMessageMediaResponseDtoSerializer();
}

class _$DirectMessageMediaResponseDtoSerializer implements PrimitiveSerializer<DirectMessageMediaResponseDto> {
  @override
  final Iterable<Type> types = const [DirectMessageMediaResponseDto, _$DirectMessageMediaResponseDto];

  @override
  final String wireName = r'DirectMessageMediaResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectMessageMediaResponseDto object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    DirectMessageMediaResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectMessageMediaResponseDtoBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DirectMessageMediaResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectMessageMediaResponseDtoBuilder();
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
