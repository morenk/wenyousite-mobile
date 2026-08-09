//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/notification_post_response_dto.dart';
import 'package:wenyou_api/src/model/notification_target_response_dto.dart';
import 'package:wenyou_api/src/model/notification_moment_response_dto.dart';
import 'package:wenyou_api/src/model/notification_thread_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/notification_from_user_response_dto.dart';
import 'package:wenyou_api/src/model/notification_moment_comment_response_dto.dart';
import 'package:wenyou_api/src/model/notification_payload_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_response_dto.g.dart';

/// NotificationResponseDto
///
/// Properties:
/// * [id]
/// * [userId]
/// * [type]
/// * [content]
/// * [payload]
/// * [target]
/// * [postId]
/// * [threadId]
/// * [momentId]
/// * [momentCommentId]
/// * [fromUserId]
/// * [eventKey]
/// * [isRead]
/// * [createdAt]
/// * [post]
/// * [thread]
/// * [moment]
/// * [momentComment]
/// * [fromUser]
@BuiltValue()
abstract class NotificationResponseDto implements Built<NotificationResponseDto, NotificationResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'type')
  NotificationResponseDtoTypeEnum get type;
  // enum typeEnum {  reply,  mention,  new_floor,  subthread_created,  new_post,  thread_created,  follow,  like,  tip,  level_up,  system,  };

  @BuiltValueField(wireName: r'content')
  String? get content;

  @BuiltValueField(wireName: r'payload')
  NotificationPayloadResponseDto? get payload;

  @BuiltValueField(wireName: r'target')
  NotificationTargetResponseDto get target;

  @BuiltValueField(wireName: r'postId')
  String? get postId;

  @BuiltValueField(wireName: r'threadId')
  String? get threadId;

  @BuiltValueField(wireName: r'momentId')
  String? get momentId;

  @BuiltValueField(wireName: r'momentCommentId')
  String? get momentCommentId;

  @BuiltValueField(wireName: r'fromUserId')
  String? get fromUserId;

  @BuiltValueField(wireName: r'eventKey')
  String get eventKey;

  @BuiltValueField(wireName: r'isRead')
  bool get isRead;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'post')
  NotificationPostResponseDto? get post;

  @BuiltValueField(wireName: r'thread')
  NotificationThreadResponseDto? get thread;

  @BuiltValueField(wireName: r'moment')
  NotificationMomentResponseDto? get moment;

  @BuiltValueField(wireName: r'momentComment')
  NotificationMomentCommentResponseDto? get momentComment;

  @BuiltValueField(wireName: r'fromUser')
  NotificationFromUserResponseDto? get fromUser;

  NotificationResponseDto._();

  factory NotificationResponseDto([void updates(NotificationResponseDtoBuilder b)]) = _$NotificationResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationResponseDto> get serializer => _$NotificationResponseDtoSerializer();
}

class _$NotificationResponseDtoSerializer implements PrimitiveSerializer<NotificationResponseDto> {
  @override
  final Iterable<Type> types = const [NotificationResponseDto, _$NotificationResponseDto];

  @override
  final String wireName = r'NotificationResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(NotificationResponseDtoTypeEnum),
    );
    yield r'content';
    yield object.content == null ? null : serializers.serialize(
      object.content,
      specifiedType: const FullType.nullable(String),
    );
    yield r'payload';
    yield object.payload == null ? null : serializers.serialize(
      object.payload,
      specifiedType: const FullType.nullable(NotificationPayloadResponseDto),
    );
    yield r'target';
    yield serializers.serialize(
      object.target,
      specifiedType: const FullType(NotificationTargetResponseDto),
    );
    yield r'postId';
    yield object.postId == null ? null : serializers.serialize(
      object.postId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'threadId';
    yield object.threadId == null ? null : serializers.serialize(
      object.threadId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'momentId';
    yield object.momentId == null ? null : serializers.serialize(
      object.momentId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'momentCommentId';
    yield object.momentCommentId == null ? null : serializers.serialize(
      object.momentCommentId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'fromUserId';
    yield object.fromUserId == null ? null : serializers.serialize(
      object.fromUserId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'eventKey';
    yield serializers.serialize(
      object.eventKey,
      specifiedType: const FullType(String),
    );
    yield r'isRead';
    yield serializers.serialize(
      object.isRead,
      specifiedType: const FullType(bool),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'post';
    yield object.post == null ? null : serializers.serialize(
      object.post,
      specifiedType: const FullType.nullable(NotificationPostResponseDto),
    );
    yield r'thread';
    yield object.thread == null ? null : serializers.serialize(
      object.thread,
      specifiedType: const FullType.nullable(NotificationThreadResponseDto),
    );
    yield r'moment';
    yield object.moment == null ? null : serializers.serialize(
      object.moment,
      specifiedType: const FullType.nullable(NotificationMomentResponseDto),
    );
    yield r'momentComment';
    yield object.momentComment == null ? null : serializers.serialize(
      object.momentComment,
      specifiedType: const FullType.nullable(NotificationMomentCommentResponseDto),
    );
    yield r'fromUser';
    yield object.fromUser == null ? null : serializers.serialize(
      object.fromUser,
      specifiedType: const FullType.nullable(NotificationFromUserResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationResponseDtoBuilder result,
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
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationResponseDtoTypeEnum),
          ) as NotificationResponseDtoTypeEnum;
          result.type = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.content = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(NotificationPayloadResponseDto),
          ) as NotificationPayloadResponseDto?;
          if (valueDes == null) continue;
          result.payload.replace(valueDes);
          break;
        case r'target':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationTargetResponseDto),
          ) as NotificationTargetResponseDto;
          result.target.replace(valueDes);
          break;
        case r'postId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.postId = valueDes;
          break;
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.threadId = valueDes;
          break;
        case r'momentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.momentId = valueDes;
          break;
        case r'momentCommentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.momentCommentId = valueDes;
          break;
        case r'fromUserId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fromUserId = valueDes;
          break;
        case r'eventKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.eventKey = valueDes;
          break;
        case r'isRead':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isRead = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'post':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(NotificationPostResponseDto),
          ) as NotificationPostResponseDto?;
          if (valueDes == null) continue;
          result.post.replace(valueDes);
          break;
        case r'thread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(NotificationThreadResponseDto),
          ) as NotificationThreadResponseDto?;
          if (valueDes == null) continue;
          result.thread.replace(valueDes);
          break;
        case r'moment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(NotificationMomentResponseDto),
          ) as NotificationMomentResponseDto?;
          if (valueDes == null) continue;
          result.moment.replace(valueDes);
          break;
        case r'momentComment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(NotificationMomentCommentResponseDto),
          ) as NotificationMomentCommentResponseDto?;
          if (valueDes == null) continue;
          result.momentComment.replace(valueDes);
          break;
        case r'fromUser':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(NotificationFromUserResponseDto),
          ) as NotificationFromUserResponseDto?;
          if (valueDes == null) continue;
          result.fromUser.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationResponseDtoBuilder();
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

class NotificationResponseDtoTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'reply')
  static const NotificationResponseDtoTypeEnum reply = _$notificationResponseDtoTypeEnum_reply;
  @BuiltValueEnumConst(wireName: r'mention')
  static const NotificationResponseDtoTypeEnum mention = _$notificationResponseDtoTypeEnum_mention;
  @BuiltValueEnumConst(wireName: r'new_floor')
  static const NotificationResponseDtoTypeEnum newFloor = _$notificationResponseDtoTypeEnum_newFloor;
  @BuiltValueEnumConst(wireName: r'subthread_created')
  static const NotificationResponseDtoTypeEnum subthreadCreated = _$notificationResponseDtoTypeEnum_subthreadCreated;
  @BuiltValueEnumConst(wireName: r'new_post')
  static const NotificationResponseDtoTypeEnum newPost = _$notificationResponseDtoTypeEnum_newPost;
  @BuiltValueEnumConst(wireName: r'thread_created')
  static const NotificationResponseDtoTypeEnum threadCreated = _$notificationResponseDtoTypeEnum_threadCreated;
  @BuiltValueEnumConst(wireName: r'follow')
  static const NotificationResponseDtoTypeEnum follow = _$notificationResponseDtoTypeEnum_follow;
  @BuiltValueEnumConst(wireName: r'like')
  static const NotificationResponseDtoTypeEnum like = _$notificationResponseDtoTypeEnum_like;
  @BuiltValueEnumConst(wireName: r'tip')
  static const NotificationResponseDtoTypeEnum tip = _$notificationResponseDtoTypeEnum_tip;
  @BuiltValueEnumConst(wireName: r'level_up')
  static const NotificationResponseDtoTypeEnum levelUp = _$notificationResponseDtoTypeEnum_levelUp;
  @BuiltValueEnumConst(wireName: r'system')
  static const NotificationResponseDtoTypeEnum system = _$notificationResponseDtoTypeEnum_system;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const NotificationResponseDtoTypeEnum unknownDefaultOpenApi = _$notificationResponseDtoTypeEnum_unknownDefaultOpenApi;

  static Serializer<NotificationResponseDtoTypeEnum> get serializer => _$notificationResponseDtoTypeEnumSerializer;

  const NotificationResponseDtoTypeEnum._(String name): super(name);

  static BuiltSet<NotificationResponseDtoTypeEnum> get values => _$notificationResponseDtoTypeEnumValues;
  static NotificationResponseDtoTypeEnum valueOf(String name) => _$notificationResponseDtoTypeEnumValueOf(name);
}
