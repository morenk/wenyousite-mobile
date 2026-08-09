//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/moment_media_response_dto.dart';
import 'package:wenyou_api/src/model/moment_sticker_response_dto.dart';
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:wenyou_api/src/model/moment_reply_target_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moment_comment_response_dto.g.dart';

/// MomentCommentResponseDto
///
/// Properties:
/// * [id]
/// * [momentId]
/// * [author]
/// * [content] - 图片/表情评论可为空字符串；删除后为 null
/// * [media] - 每条评论最多一张普通图片
/// * [sticker] - 每条评论最多一个表情；与 media 互斥
/// * [parentCommentId] - 楼中楼统一指向主评论
/// * [replyToComment]
/// * [deleted]
/// * [canDelete]
/// * [createdAt]
@BuiltValue()
abstract class MomentCommentResponseDto implements Built<MomentCommentResponseDto, MomentCommentResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'momentId')
  String get momentId;

  @BuiltValueField(wireName: r'author')
  PostAuthorResponseDto get author;

  /// 图片/表情评论可为空字符串；删除后为 null
  @BuiltValueField(wireName: r'content')
  String? get content;

  /// 每条评论最多一张普通图片
  @BuiltValueField(wireName: r'media')
  MomentMediaResponseDto? get media;

  /// 每条评论最多一个表情；与 media 互斥
  @BuiltValueField(wireName: r'sticker')
  MomentStickerResponseDto? get sticker;

  /// 楼中楼统一指向主评论
  @BuiltValueField(wireName: r'parentCommentId')
  String? get parentCommentId;

  @BuiltValueField(wireName: r'replyToComment')
  MomentReplyTargetResponseDto? get replyToComment;

  @BuiltValueField(wireName: r'deleted')
  bool get deleted;

  @BuiltValueField(wireName: r'canDelete')
  bool get canDelete;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  MomentCommentResponseDto._();

  factory MomentCommentResponseDto([void updates(MomentCommentResponseDtoBuilder b)]) = _$MomentCommentResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentCommentResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentCommentResponseDto> get serializer => _$MomentCommentResponseDtoSerializer();
}

class _$MomentCommentResponseDtoSerializer implements PrimitiveSerializer<MomentCommentResponseDto> {
  @override
  final Iterable<Type> types = const [MomentCommentResponseDto, _$MomentCommentResponseDto];

  @override
  final String wireName = r'MomentCommentResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentCommentResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'momentId';
    yield serializers.serialize(
      object.momentId,
      specifiedType: const FullType(String),
    );
    yield r'author';
    yield serializers.serialize(
      object.author,
      specifiedType: const FullType(PostAuthorResponseDto),
    );
    yield r'content';
    yield object.content == null ? null : serializers.serialize(
      object.content,
      specifiedType: const FullType.nullable(String),
    );
    yield r'media';
    yield object.media == null ? null : serializers.serialize(
      object.media,
      specifiedType: const FullType.nullable(MomentMediaResponseDto),
    );
    yield r'sticker';
    yield object.sticker == null ? null : serializers.serialize(
      object.sticker,
      specifiedType: const FullType.nullable(MomentStickerResponseDto),
    );
    yield r'parentCommentId';
    yield object.parentCommentId == null ? null : serializers.serialize(
      object.parentCommentId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'replyToComment';
    yield object.replyToComment == null ? null : serializers.serialize(
      object.replyToComment,
      specifiedType: const FullType.nullable(MomentReplyTargetResponseDto),
    );
    yield r'deleted';
    yield serializers.serialize(
      object.deleted,
      specifiedType: const FullType(bool),
    );
    yield r'canDelete';
    yield serializers.serialize(
      object.canDelete,
      specifiedType: const FullType(bool),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MomentCommentResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentCommentResponseDtoBuilder result,
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
        case r'momentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.momentId = valueDes;
          break;
        case r'author':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostAuthorResponseDto),
          ) as PostAuthorResponseDto;
          result.author.replace(valueDes);
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.content = valueDes;
          break;
        case r'media':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MomentMediaResponseDto),
          ) as MomentMediaResponseDto?;
          if (valueDes == null) continue;
          result.media.replace(valueDes);
          break;
        case r'sticker':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MomentStickerResponseDto),
          ) as MomentStickerResponseDto?;
          if (valueDes == null) continue;
          result.sticker.replace(valueDes);
          break;
        case r'parentCommentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentCommentId = valueDes;
          break;
        case r'replyToComment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MomentReplyTargetResponseDto),
          ) as MomentReplyTargetResponseDto?;
          if (valueDes == null) continue;
          result.replyToComment.replace(valueDes);
          break;
        case r'deleted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.deleted = valueDes;
          break;
        case r'canDelete':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canDelete = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MomentCommentResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentCommentResponseDtoBuilder();
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
