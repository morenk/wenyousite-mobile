//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reorder_stickers_dto.g.dart';

/// ReorderStickersDto
///
/// Properties:
/// * [version] - GET /stickers 返回的收藏夹版本
/// * [favoriteIds]
@BuiltValue()
abstract class ReorderStickersDto implements Built<ReorderStickersDto, ReorderStickersDtoBuilder> {
  /// GET /stickers 返回的收藏夹版本
  @BuiltValueField(wireName: r'version')
  num get version;

  @BuiltValueField(wireName: r'favoriteIds')
  BuiltList<String> get favoriteIds;

  ReorderStickersDto._();

  factory ReorderStickersDto([void updates(ReorderStickersDtoBuilder b)]) = _$ReorderStickersDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReorderStickersDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReorderStickersDto> get serializer => _$ReorderStickersDtoSerializer();
}

class _$ReorderStickersDtoSerializer implements PrimitiveSerializer<ReorderStickersDto> {
  @override
  final Iterable<Type> types = const [ReorderStickersDto, _$ReorderStickersDto];

  @override
  final String wireName = r'ReorderStickersDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReorderStickersDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
    yield r'favoriteIds';
    yield serializers.serialize(
      object.favoriteIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReorderStickersDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReorderStickersDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        case r'favoriteIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.favoriteIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReorderStickersDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReorderStickersDtoBuilder();
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
