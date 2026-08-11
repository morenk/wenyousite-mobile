//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_moment_comment_dto.g.dart';

/// CreateMomentCommentDto
///
/// Properties:
/// * [content] - 评论字串；可按 internal-reference v1 嵌入命名站内传送门；与图片或表情至少提供一项
/// * [mediaId] - 已完成处理且属于评论者的图片 ID；与 stickerAssetId 互斥
/// * [stickerAssetId] - 当前收藏夹中的表情资产 ID；与 mediaId 互斥
/// * [replyToCommentId] - 被回复评论 ID；服务端自动归并到所属主评论
/// * [clientRequestId] - 评论幂等键
@BuiltValue()
abstract class CreateMomentCommentDto implements Built<CreateMomentCommentDto, CreateMomentCommentDtoBuilder> {
  /// 评论字串；可按 internal-reference v1 嵌入命名站内传送门；与图片或表情至少提供一项
  @BuiltValueField(wireName: r'content')
  String? get content;

  /// 已完成处理且属于评论者的图片 ID；与 stickerAssetId 互斥
  @BuiltValueField(wireName: r'mediaId')
  String? get mediaId;

  /// 当前收藏夹中的表情资产 ID；与 mediaId 互斥
  @BuiltValueField(wireName: r'stickerAssetId')
  String? get stickerAssetId;

  /// 被回复评论 ID；服务端自动归并到所属主评论
  @BuiltValueField(wireName: r'replyToCommentId')
  String? get replyToCommentId;

  /// 评论幂等键
  @BuiltValueField(wireName: r'clientRequestId')
  String get clientRequestId;

  CreateMomentCommentDto._();

  factory CreateMomentCommentDto([void updates(CreateMomentCommentDtoBuilder b)]) = _$CreateMomentCommentDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateMomentCommentDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateMomentCommentDto> get serializer => _$CreateMomentCommentDtoSerializer();
}

class _$CreateMomentCommentDtoSerializer implements PrimitiveSerializer<CreateMomentCommentDto> {
  @override
  final Iterable<Type> types = const [CreateMomentCommentDto, _$CreateMomentCommentDto];

  @override
  final String wireName = r'CreateMomentCommentDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateMomentCommentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
    if (object.mediaId != null) {
      yield r'mediaId';
      yield serializers.serialize(
        object.mediaId,
        specifiedType: const FullType(String),
      );
    }
    if (object.stickerAssetId != null) {
      yield r'stickerAssetId';
      yield serializers.serialize(
        object.stickerAssetId,
        specifiedType: const FullType(String),
      );
    }
    if (object.replyToCommentId != null) {
      yield r'replyToCommentId';
      yield serializers.serialize(
        object.replyToCommentId,
        specifiedType: const FullType(String),
      );
    }
    yield r'clientRequestId';
    yield serializers.serialize(
      object.clientRequestId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateMomentCommentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateMomentCommentDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'mediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaId = valueDes;
          break;
        case r'stickerAssetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stickerAssetId = valueDes;
          break;
        case r'replyToCommentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.replyToCommentId = valueDes;
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
  CreateMomentCommentDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateMomentCommentDtoBuilder();
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
