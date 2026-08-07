//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'import_sticker_post_image_dto.g.dart';

/// ImportStickerPostImageDto
///
/// Properties:
/// * [postId] - 当前用户可访问的帖子 ID
/// * [imageUrl] - 帖子正文中图片的完整 URL
/// * [clientRequestId] - 导入幂等键
@BuiltValue()
abstract class ImportStickerPostImageDto implements Built<ImportStickerPostImageDto, ImportStickerPostImageDtoBuilder> {
  /// 当前用户可访问的帖子 ID
  @BuiltValueField(wireName: r'postId')
  String get postId;

  /// 帖子正文中图片的完整 URL
  @BuiltValueField(wireName: r'imageUrl')
  String get imageUrl;

  /// 导入幂等键
  @BuiltValueField(wireName: r'clientRequestId')
  String get clientRequestId;

  ImportStickerPostImageDto._();

  factory ImportStickerPostImageDto([void updates(ImportStickerPostImageDtoBuilder b)]) = _$ImportStickerPostImageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ImportStickerPostImageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ImportStickerPostImageDto> get serializer => _$ImportStickerPostImageDtoSerializer();
}

class _$ImportStickerPostImageDtoSerializer implements PrimitiveSerializer<ImportStickerPostImageDto> {
  @override
  final Iterable<Type> types = const [ImportStickerPostImageDto, _$ImportStickerPostImageDto];

  @override
  final String wireName = r'ImportStickerPostImageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ImportStickerPostImageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'postId';
    yield serializers.serialize(
      object.postId,
      specifiedType: const FullType(String),
    );
    yield r'imageUrl';
    yield serializers.serialize(
      object.imageUrl,
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
    ImportStickerPostImageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ImportStickerPostImageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'postId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.postId = valueDes;
          break;
        case r'imageUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.imageUrl = valueDes;
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
  ImportStickerPostImageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ImportStickerPostImageDtoBuilder();
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
