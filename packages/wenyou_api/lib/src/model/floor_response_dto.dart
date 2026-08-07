//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/dice_roll_response_dto.dart';
import 'package:wenyou_api/src/model/post_count_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/reply_response_dto.dart';
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'floor_response_dto.g.dart';

/// FloorResponseDto
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
/// * [count]
/// * [replies]
@BuiltValue()
abstract class FloorResponseDto implements Built<FloorResponseDto, FloorResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  @BuiltValueField(wireName: r'subthreadId')
  String get subthreadId;

  @BuiltValueField(wireName: r'authorId')
  String get authorId;

  @BuiltValueField(wireName: r'kind')
  FloorResponseDtoKindEnum get kind;
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

  @BuiltValueField(wireName: r'_count')
  PostCountResponseDto get count;

  @BuiltValueField(wireName: r'replies')
  BuiltList<ReplyResponseDto> get replies;

  FloorResponseDto._();

  factory FloorResponseDto([void updates(FloorResponseDtoBuilder b)]) = _$FloorResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FloorResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FloorResponseDto> get serializer => _$FloorResponseDtoSerializer();
}

class _$FloorResponseDtoSerializer implements PrimitiveSerializer<FloorResponseDto> {
  @override
  final Iterable<Type> types = const [FloorResponseDto, _$FloorResponseDto];

  @override
  final String wireName = r'FloorResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FloorResponseDto object, {
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
      specifiedType: const FullType(FloorResponseDtoKindEnum),
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
    yield r'_count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(PostCountResponseDto),
    );
    yield r'replies';
    yield serializers.serialize(
      object.replies,
      specifiedType: const FullType(BuiltList, [FullType(ReplyResponseDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FloorResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FloorResponseDtoBuilder result,
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
            specifiedType: const FullType(FloorResponseDtoKindEnum),
          ) as FloorResponseDtoKindEnum;
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
        case r'_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostCountResponseDto),
          ) as PostCountResponseDto;
          result.count.replace(valueDes);
          break;
        case r'replies':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ReplyResponseDto)]),
          ) as BuiltList<ReplyResponseDto>;
          result.replies.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FloorResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FloorResponseDtoBuilder();
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

class FloorResponseDtoKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'BODY')
  static const FloorResponseDtoKindEnum BODY = _$floorResponseDtoKindEnum_BODY;
  @BuiltValueEnumConst(wireName: r'FLOOR')
  static const FloorResponseDtoKindEnum FLOOR = _$floorResponseDtoKindEnum_FLOOR;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FloorResponseDtoKindEnum unknownDefaultOpenApi = _$floorResponseDtoKindEnum_unknownDefaultOpenApi;

  static Serializer<FloorResponseDtoKindEnum> get serializer => _$floorResponseDtoKindEnumSerializer;

  const FloorResponseDtoKindEnum._(String name): super(name);

  static BuiltSet<FloorResponseDtoKindEnum> get values => _$floorResponseDtoKindEnumValues;
  static FloorResponseDtoKindEnum valueOf(String name) => _$floorResponseDtoKindEnumValueOf(name);
}
