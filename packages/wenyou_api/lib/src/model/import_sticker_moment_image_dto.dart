//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'import_sticker_moment_image_dto.g.dart';

/// ImportStickerMomentImageDto
///
/// Properties:
/// * [momentId] - 当前用户可访问动态中的图片媒体 ID 所属动态
/// * [mediaId] - 动态图片的媒体 ID
/// * [clientRequestId] - 导入幂等键
@BuiltValue()
abstract class ImportStickerMomentImageDto implements Built<ImportStickerMomentImageDto, ImportStickerMomentImageDtoBuilder> {
  /// 当前用户可访问动态中的图片媒体 ID 所属动态
  @BuiltValueField(wireName: r'momentId')
  String get momentId;

  /// 动态图片的媒体 ID
  @BuiltValueField(wireName: r'mediaId')
  String get mediaId;

  /// 导入幂等键
  @BuiltValueField(wireName: r'clientRequestId')
  String get clientRequestId;

  ImportStickerMomentImageDto._();

  factory ImportStickerMomentImageDto([void updates(ImportStickerMomentImageDtoBuilder b)]) = _$ImportStickerMomentImageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ImportStickerMomentImageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ImportStickerMomentImageDto> get serializer => _$ImportStickerMomentImageDtoSerializer();
}

class _$ImportStickerMomentImageDtoSerializer implements PrimitiveSerializer<ImportStickerMomentImageDto> {
  @override
  final Iterable<Type> types = const [ImportStickerMomentImageDto, _$ImportStickerMomentImageDto];

  @override
  final String wireName = r'ImportStickerMomentImageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ImportStickerMomentImageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'momentId';
    yield serializers.serialize(
      object.momentId,
      specifiedType: const FullType(String),
    );
    yield r'mediaId';
    yield serializers.serialize(
      object.mediaId,
      specifiedType: const FullType(String),
    );
    yield r'clientRequestId';
    yield serializers.serialize(
      object.clientRequestId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ImportStickerMomentImageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ImportStickerMomentImageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'momentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.momentId = valueDes;
          break;
        case r'mediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaId = valueDes;
          break;
        case r'clientRequestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientRequestId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ImportStickerMomentImageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ImportStickerMomentImageDtoBuilder();
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
