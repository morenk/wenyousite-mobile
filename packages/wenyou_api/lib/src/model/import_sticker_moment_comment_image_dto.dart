//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'import_sticker_moment_comment_image_dto.g.dart';

/// ImportStickerMomentCommentImageDto
///
/// Properties:
/// * [momentCommentId] - 当前用户可访问动态中的评论 ID
/// * [mediaId] - 动态评论图片的媒体 ID
/// * [clientRequestId] - 导入幂等键
@BuiltValue()
abstract class ImportStickerMomentCommentImageDto implements Built<ImportStickerMomentCommentImageDto, ImportStickerMomentCommentImageDtoBuilder> {
  /// 当前用户可访问动态中的评论 ID
  @BuiltValueField(wireName: r'momentCommentId')
  String get momentCommentId;

  /// 动态评论图片的媒体 ID
  @BuiltValueField(wireName: r'mediaId')
  String get mediaId;

  /// 导入幂等键
  @BuiltValueField(wireName: r'clientRequestId')
  String get clientRequestId;

  ImportStickerMomentCommentImageDto._();

  factory ImportStickerMomentCommentImageDto([void updates(ImportStickerMomentCommentImageDtoBuilder b)]) = _$ImportStickerMomentCommentImageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ImportStickerMomentCommentImageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ImportStickerMomentCommentImageDto> get serializer => _$ImportStickerMomentCommentImageDtoSerializer();
}

class _$ImportStickerMomentCommentImageDtoSerializer implements PrimitiveSerializer<ImportStickerMomentCommentImageDto> {
  @override
  final Iterable<Type> types = const [ImportStickerMomentCommentImageDto, _$ImportStickerMomentCommentImageDto];

  @override
  final String wireName = r'ImportStickerMomentCommentImageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ImportStickerMomentCommentImageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'momentCommentId';
    yield serializers.serialize(
      object.momentCommentId,
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
    ImportStickerMomentCommentImageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ImportStickerMomentCommentImageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'momentCommentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.momentCommentId = valueDes;
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
  ImportStickerMomentCommentImageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ImportStickerMomentCommentImageDtoBuilder();
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
