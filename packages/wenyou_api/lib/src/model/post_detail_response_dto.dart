//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/dice_roll_response_dto.dart';
import 'package:wenyou_api/src/model/post_count_response_dto.dart';
import 'package:wenyou_api/src/model/post_thread_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/parent_post_response_dto.dart';
import 'package:wenyou_api/src/model/post_subthread_response_dto.dart';
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_detail_response_dto.g.dart';

/// PostDetailResponseDto
///
/// Properties:
/// * [id]
/// * [threadId]
/// * [subthreadId]
/// * [authorId]
/// * [kind]
/// * [floorNumber]
/// * [parentPostId]
/// * [replyToPostId]
/// * [clientRequestId] - 客户端创建请求幂等键；正文帖和旧客户端帖子为 null
/// * [content] - Markdown 正文
/// * [diceRolls] - 服务端生成的正式骰子结果；客户端按 nodeId 映射到正文位置
/// * [version] - 乐观锁版本
/// * [createdAt]
/// * [updatedAt]
/// * [deletedAt]
/// * [author]
/// * [thread]
/// * [subthread]
/// * [parentPost]
/// * [count]
@BuiltValue()
abstract class PostDetailResponseDto implements Built<PostDetailResponseDto, PostDetailResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  @BuiltValueField(wireName: r'subthreadId')
  String get subthreadId;

  @BuiltValueField(wireName: r'authorId')
  String get authorId;

  @BuiltValueField(wireName: r'kind')
  PostDetailResponseDtoKindEnum get kind;
  // enum kindEnum {  BODY,  FLOOR,  };

  @BuiltValueField(wireName: r'floorNumber')
  num? get floorNumber;

  @BuiltValueField(wireName: r'parentPostId')
  String? get parentPostId;

  @BuiltValueField(wireName: r'replyToPostId')
  String? get replyToPostId;

  /// 客户端创建请求幂等键；正文帖和旧客户端帖子为 null
  @BuiltValueField(wireName: r'clientRequestId')
  String? get clientRequestId;

  /// Markdown 正文
  @BuiltValueField(wireName: r'content')
  String get content;

  /// 服务端生成的正式骰子结果；客户端按 nodeId 映射到正文位置
  @BuiltValueField(wireName: r'diceRolls')
  BuiltList<DiceRollResponseDto> get diceRolls;

  /// 乐观锁版本
  @BuiltValueField(wireName: r'version')
  num get version;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'author')
  PostAuthorResponseDto get author;

  @BuiltValueField(wireName: r'thread')
  PostThreadResponseDto get thread;

  @BuiltValueField(wireName: r'subthread')
  PostSubthreadResponseDto get subthread;

  @BuiltValueField(wireName: r'parentPost')
  ParentPostResponseDto? get parentPost;

  @BuiltValueField(wireName: r'_count')
  PostCountResponseDto get count;

  PostDetailResponseDto._();

  factory PostDetailResponseDto([void updates(PostDetailResponseDtoBuilder b)]) = _$PostDetailResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostDetailResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostDetailResponseDto> get serializer => _$PostDetailResponseDtoSerializer();
}

class _$PostDetailResponseDtoSerializer implements PrimitiveSerializer<PostDetailResponseDto> {
  @override
  final Iterable<Type> types = const [PostDetailResponseDto, _$PostDetailResponseDto];

  @override
  final String wireName = r'PostDetailResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostDetailResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'threadId';
    yield serializers.serialize(
      object.threadId,
      specifiedType: const FullType(String),
    );
    yield r'subthreadId';
    yield serializers.serialize(
      object.subthreadId,
      specifiedType: const FullType(String),
    );
    yield r'authorId';
    yield serializers.serialize(
      object.authorId,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(PostDetailResponseDtoKindEnum),
    );
    yield r'floorNumber';
    yield object.floorNumber == null ? null : serializers.serialize(
      object.floorNumber,
      specifiedType: const FullType.nullable(num),
    );
    yield r'parentPostId';
    yield object.parentPostId == null ? null : serializers.serialize(
      object.parentPostId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'replyToPostId';
    yield object.replyToPostId == null ? null : serializers.serialize(
      object.replyToPostId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'clientRequestId';
    yield object.clientRequestId == null ? null : serializers.serialize(
      object.clientRequestId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'diceRolls';
    yield serializers.serialize(
      object.diceRolls,
      specifiedType: const FullType(BuiltList, [FullType(DiceRollResponseDto)]),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'deletedAt';
    yield object.deletedAt == null ? null : serializers.serialize(
      object.deletedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'author';
    yield serializers.serialize(
      object.author,
      specifiedType: const FullType(PostAuthorResponseDto),
    );
    yield r'thread';
    yield serializers.serialize(
      object.thread,
      specifiedType: const FullType(PostThreadResponseDto),
    );
    yield r'subthread';
    yield serializers.serialize(
      object.subthread,
      specifiedType: const FullType(PostSubthreadResponseDto),
    );
    yield r'parentPost';
    yield object.parentPost == null ? null : serializers.serialize(
      object.parentPost,
      specifiedType: const FullType.nullable(ParentPostResponseDto),
    );
    yield r'_count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(PostCountResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostDetailResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostDetailResponseDtoBuilder result,
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
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.threadId = valueDes;
          break;
        case r'subthreadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.subthreadId = valueDes;
          break;
        case r'authorId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.authorId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostDetailResponseDtoKindEnum),
          ) as PostDetailResponseDtoKindEnum;
          result.kind = valueDes;
          break;
        case r'floorNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.floorNumber = valueDes;
          break;
        case r'parentPostId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentPostId = valueDes;
          break;
        case r'replyToPostId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.replyToPostId = valueDes;
          break;
        case r'clientRequestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.clientRequestId = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'diceRolls':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DiceRollResponseDto)]),
          ) as BuiltList<DiceRollResponseDto>;
          result.diceRolls.replace(valueDes);
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'deletedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        case r'author':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostAuthorResponseDto),
          ) as PostAuthorResponseDto;
          result.author.replace(valueDes);
          break;
        case r'thread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostThreadResponseDto),
          ) as PostThreadResponseDto;
          result.thread.replace(valueDes);
          break;
        case r'subthread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostSubthreadResponseDto),
          ) as PostSubthreadResponseDto;
          result.subthread.replace(valueDes);
          break;
        case r'parentPost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ParentPostResponseDto),
          ) as ParentPostResponseDto?;
          if (valueDes == null) continue;
          result.parentPost.replace(valueDes);
          break;
        case r'_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostCountResponseDto),
          ) as PostCountResponseDto;
          result.count.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostDetailResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostDetailResponseDtoBuilder();
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

class PostDetailResponseDtoKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'BODY')
  static const PostDetailResponseDtoKindEnum BODY = _$postDetailResponseDtoKindEnum_BODY;
  @BuiltValueEnumConst(wireName: r'FLOOR')
  static const PostDetailResponseDtoKindEnum FLOOR = _$postDetailResponseDtoKindEnum_FLOOR;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const PostDetailResponseDtoKindEnum unknownDefaultOpenApi = _$postDetailResponseDtoKindEnum_unknownDefaultOpenApi;

  static Serializer<PostDetailResponseDtoKindEnum> get serializer => _$postDetailResponseDtoKindEnumSerializer;

  const PostDetailResponseDtoKindEnum._(String name): super(name);

  static BuiltSet<PostDetailResponseDtoKindEnum> get values => _$postDetailResponseDtoKindEnumValues;
  static PostDetailResponseDtoKindEnum valueOf(String name) => _$postDetailResponseDtoKindEnumValueOf(name);
}
