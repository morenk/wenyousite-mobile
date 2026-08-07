//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/sticker_import_response_dto.dart';
import 'package:wenyou_api/src/model/user_sticker_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sticker_collection_response_dto.g.dart';

/// StickerCollectionResponseDto
///
/// Properties:
/// * [version]
/// * [limit]
/// * [items]
/// * [recent]
/// * [pendingImports]
@BuiltValue()
abstract class StickerCollectionResponseDto implements Built<StickerCollectionResponseDto, StickerCollectionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'version')
  num get version;

  @BuiltValueField(wireName: r'limit')
  num get limit;

  @BuiltValueField(wireName: r'items')
  BuiltList<UserStickerResponseDto> get items;

  @BuiltValueField(wireName: r'recent')
  BuiltList<UserStickerResponseDto> get recent;

  @BuiltValueField(wireName: r'pendingImports')
  BuiltList<StickerImportResponseDto> get pendingImports;

  StickerCollectionResponseDto._();

  factory StickerCollectionResponseDto([void updates(StickerCollectionResponseDtoBuilder b)]) = _$StickerCollectionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickerCollectionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickerCollectionResponseDto> get serializer => _$StickerCollectionResponseDtoSerializer();
}

class _$StickerCollectionResponseDtoSerializer implements PrimitiveSerializer<StickerCollectionResponseDto> {
  @override
  final Iterable<Type> types = const [StickerCollectionResponseDto, _$StickerCollectionResponseDto];

  @override
  final String wireName = r'StickerCollectionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickerCollectionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
    yield r'limit';
    yield serializers.serialize(
      object.limit,
      specifiedType: const FullType(num),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(UserStickerResponseDto)]),
    );
    yield r'recent';
    yield serializers.serialize(
      object.recent,
      specifiedType: const FullType(BuiltList, [FullType(UserStickerResponseDto)]),
    );
    yield r'pendingImports';
    yield serializers.serialize(
      object.pendingImports,
      specifiedType: const FullType(BuiltList, [FullType(StickerImportResponseDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StickerCollectionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickerCollectionResponseDtoBuilder result,
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
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.limit = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(UserStickerResponseDto)]),
          ) as BuiltList<UserStickerResponseDto>;
          result.items.replace(valueDes);
          break;
        case r'recent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(UserStickerResponseDto)]),
          ) as BuiltList<UserStickerResponseDto>;
          result.recent.replace(valueDes);
          break;
        case r'pendingImports':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(StickerImportResponseDto)]),
          ) as BuiltList<StickerImportResponseDto>;
          result.pendingImports.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StickerCollectionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickerCollectionResponseDtoBuilder();
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
