//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/media_display_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'gallery_image_dto.g.dart';

/// GalleryImageDto
///
/// Properties:
/// * [id]
/// * [sourceId]
/// * [sourceVersion]
/// * [imageIndex]
/// * [imageCount]
/// * [mediaId]
/// * [url]
/// * [display]
/// * [width]
/// * [height]
/// * [animated]
/// * [threadId]
/// * [subthreadId]
/// * [parentPostId]
/// * [momentId]
/// * [parentCommentId]
/// * [floorNumber]
@BuiltValue()
abstract class GalleryImageDto implements Built<GalleryImageDto, GalleryImageDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'sourceId')
  String get sourceId;

  @BuiltValueField(wireName: r'sourceVersion')
  num get sourceVersion;

  @BuiltValueField(wireName: r'imageIndex')
  num get imageIndex;

  @BuiltValueField(wireName: r'imageCount')
  num get imageCount;

  @BuiltValueField(wireName: r'mediaId')
  String? get mediaId;

  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'display')
  MediaDisplayResponseDto? get display;

  @BuiltValueField(wireName: r'width')
  num? get width;

  @BuiltValueField(wireName: r'height')
  num? get height;

  @BuiltValueField(wireName: r'animated')
  bool get animated;

  @BuiltValueField(wireName: r'threadId')
  String? get threadId;

  @BuiltValueField(wireName: r'subthreadId')
  String? get subthreadId;

  @BuiltValueField(wireName: r'parentPostId')
  String? get parentPostId;

  @BuiltValueField(wireName: r'momentId')
  String? get momentId;

  @BuiltValueField(wireName: r'parentCommentId')
  String? get parentCommentId;

  @BuiltValueField(wireName: r'floorNumber')
  num? get floorNumber;

  GalleryImageDto._();

  factory GalleryImageDto([void updates(GalleryImageDtoBuilder b)]) = _$GalleryImageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GalleryImageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GalleryImageDto> get serializer => _$GalleryImageDtoSerializer();
}

class _$GalleryImageDtoSerializer implements PrimitiveSerializer<GalleryImageDto> {
  @override
  final Iterable<Type> types = const [GalleryImageDto, _$GalleryImageDto];

  @override
  final String wireName = r'GalleryImageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GalleryImageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'sourceId';
    yield serializers.serialize(
      object.sourceId,
      specifiedType: const FullType(String),
    );
    yield r'sourceVersion';
    yield serializers.serialize(
      object.sourceVersion,
      specifiedType: const FullType(num),
    );
    yield r'imageIndex';
    yield serializers.serialize(
      object.imageIndex,
      specifiedType: const FullType(num),
    );
    yield r'imageCount';
    yield serializers.serialize(
      object.imageCount,
      specifiedType: const FullType(num),
    );
    yield r'mediaId';
    yield object.mediaId == null ? null : serializers.serialize(
      object.mediaId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'display';
    yield object.display == null ? null : serializers.serialize(
      object.display,
      specifiedType: const FullType.nullable(MediaDisplayResponseDto),
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
    yield r'threadId';
    yield object.threadId == null ? null : serializers.serialize(
      object.threadId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'subthreadId';
    yield object.subthreadId == null ? null : serializers.serialize(
      object.subthreadId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'parentPostId';
    yield object.parentPostId == null ? null : serializers.serialize(
      object.parentPostId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'momentId';
    yield object.momentId == null ? null : serializers.serialize(
      object.momentId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'parentCommentId';
    yield object.parentCommentId == null ? null : serializers.serialize(
      object.parentCommentId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'floorNumber';
    yield object.floorNumber == null ? null : serializers.serialize(
      object.floorNumber,
      specifiedType: const FullType.nullable(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GalleryImageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GalleryImageDtoBuilder result,
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
        case r'sourceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceId = valueDes;
          break;
        case r'sourceVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.sourceVersion = valueDes;
          break;
        case r'imageIndex':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.imageIndex = valueDes;
          break;
        case r'imageCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.imageCount = valueDes;
          break;
        case r'mediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mediaId = valueDes;
          break;
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'display':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MediaDisplayResponseDto),
          ) as MediaDisplayResponseDto?;
          if (valueDes == null) continue;
          result.display.replace(valueDes);
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
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.threadId = valueDes;
          break;
        case r'subthreadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.subthreadId = valueDes;
          break;
        case r'parentPostId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentPostId = valueDes;
          break;
        case r'momentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.momentId = valueDes;
          break;
        case r'parentCommentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentCommentId = valueDes;
          break;
        case r'floorNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.floorNumber = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GalleryImageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GalleryImageDtoBuilder();
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
