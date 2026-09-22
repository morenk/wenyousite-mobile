//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/gallery_image_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'gallery_page_dto.g.dart';

/// GalleryPageDto
///
/// Properties:
/// * [items]
/// * [previousCursor]
/// * [nextCursor]
/// * [anchorItemId]
@BuiltValue()
abstract class GalleryPageDto implements Built<GalleryPageDto, GalleryPageDtoBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<GalleryImageDto> get items;

  @BuiltValueField(wireName: r'previousCursor')
  String? get previousCursor;

  @BuiltValueField(wireName: r'nextCursor')
  String? get nextCursor;

  @BuiltValueField(wireName: r'anchorItemId')
  String? get anchorItemId;

  GalleryPageDto._();

  factory GalleryPageDto([void updates(GalleryPageDtoBuilder b)]) = _$GalleryPageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GalleryPageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GalleryPageDto> get serializer => _$GalleryPageDtoSerializer();
}

class _$GalleryPageDtoSerializer implements PrimitiveSerializer<GalleryPageDto> {
  @override
  final Iterable<Type> types = const [GalleryPageDto, _$GalleryPageDto];

  @override
  final String wireName = r'GalleryPageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GalleryPageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(GalleryImageDto)]),
    );
    yield r'previousCursor';
    yield object.previousCursor == null ? null : serializers.serialize(
      object.previousCursor,
      specifiedType: const FullType.nullable(String),
    );
    yield r'nextCursor';
    yield object.nextCursor == null ? null : serializers.serialize(
      object.nextCursor,
      specifiedType: const FullType.nullable(String),
    );
    yield r'anchorItemId';
    yield object.anchorItemId == null ? null : serializers.serialize(
      object.anchorItemId,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GalleryPageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GalleryPageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GalleryImageDto)]),
          ) as BuiltList<GalleryImageDto>;
          result.items.replace(valueDes);
          break;
        case r'previousCursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.previousCursor = valueDes;
          break;
        case r'nextCursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        case r'anchorItemId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.anchorItemId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GalleryPageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GalleryPageDtoBuilder();
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
