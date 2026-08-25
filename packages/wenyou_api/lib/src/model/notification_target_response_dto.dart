//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_target_response_dto.g.dart';

/// NotificationTargetResponseDto
///
/// Properties:
/// * [kind]
/// * [state] - 目标当前状态；只有 ACTIVE 可以导航
/// * [threadId]
/// * [postId]
/// * [momentId]
/// * [momentCommentId]
/// * [userId]
@BuiltValue()
abstract class NotificationTargetResponseDto implements Built<NotificationTargetResponseDto, NotificationTargetResponseDtoBuilder> {
  @BuiltValueField(wireName: r'kind')
  NotificationTargetResponseDtoKindEnum get kind;
  // enum kindEnum {  post,  thread,  moment,  user,  none,  };

  /// 目标当前状态；只有 ACTIVE 可以导航
  @BuiltValueField(wireName: r'state')
  NotificationTargetResponseDtoStateEnum get state;
  // enum stateEnum {  ACTIVE,  CONTENT_DELETED,  USER_DEACTIVATED,  NO_TARGET,  };

  @BuiltValueField(wireName: r'threadId')
  String? get threadId;

  @BuiltValueField(wireName: r'postId')
  String? get postId;

  @BuiltValueField(wireName: r'momentId')
  String? get momentId;

  @BuiltValueField(wireName: r'momentCommentId')
  String? get momentCommentId;

  @BuiltValueField(wireName: r'userId')
  String? get userId;

  NotificationTargetResponseDto._();

  factory NotificationTargetResponseDto([void updates(NotificationTargetResponseDtoBuilder b)]) = _$NotificationTargetResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationTargetResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationTargetResponseDto> get serializer => _$NotificationTargetResponseDtoSerializer();
}

class _$NotificationTargetResponseDtoSerializer implements PrimitiveSerializer<NotificationTargetResponseDto> {
  @override
  final Iterable<Type> types = const [NotificationTargetResponseDto, _$NotificationTargetResponseDto];

  @override
  final String wireName = r'NotificationTargetResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationTargetResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(NotificationTargetResponseDtoKindEnum),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(NotificationTargetResponseDtoStateEnum),
    );
    yield r'threadId';
    yield object.threadId == null ? null : serializers.serialize(
      object.threadId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'postId';
    yield object.postId == null ? null : serializers.serialize(
      object.postId,
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
    yield r'userId';
    yield object.userId == null ? null : serializers.serialize(
      object.userId,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationTargetResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationTargetResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationTargetResponseDtoKindEnum),
          ) as NotificationTargetResponseDtoKindEnum;
          result.kind = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationTargetResponseDtoStateEnum),
          ) as NotificationTargetResponseDtoStateEnum;
          result.state = valueDes;
          break;
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.threadId = valueDes;
          break;
        case r'postId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.postId = valueDes;
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
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.userId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationTargetResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationTargetResponseDtoBuilder();
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

class NotificationTargetResponseDtoKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'post')
  static const NotificationTargetResponseDtoKindEnum post = _$notificationTargetResponseDtoKindEnum_post;
  @BuiltValueEnumConst(wireName: r'thread')
  static const NotificationTargetResponseDtoKindEnum thread = _$notificationTargetResponseDtoKindEnum_thread;
  @BuiltValueEnumConst(wireName: r'moment')
  static const NotificationTargetResponseDtoKindEnum moment = _$notificationTargetResponseDtoKindEnum_moment;
  @BuiltValueEnumConst(wireName: r'user')
  static const NotificationTargetResponseDtoKindEnum user = _$notificationTargetResponseDtoKindEnum_user;
  @BuiltValueEnumConst(wireName: r'none')
  static const NotificationTargetResponseDtoKindEnum none = _$notificationTargetResponseDtoKindEnum_none;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const NotificationTargetResponseDtoKindEnum unknownDefaultOpenApi = _$notificationTargetResponseDtoKindEnum_unknownDefaultOpenApi;

  static Serializer<NotificationTargetResponseDtoKindEnum> get serializer => _$notificationTargetResponseDtoKindEnumSerializer;

  const NotificationTargetResponseDtoKindEnum._(String name): super(name);

  static BuiltSet<NotificationTargetResponseDtoKindEnum> get values => _$notificationTargetResponseDtoKindEnumValues;
  static NotificationTargetResponseDtoKindEnum valueOf(String name) => _$notificationTargetResponseDtoKindEnumValueOf(name);
}

class NotificationTargetResponseDtoStateEnum extends EnumClass {

  /// 目标当前状态；只有 ACTIVE 可以导航
  @BuiltValueEnumConst(wireName: r'ACTIVE')
  static const NotificationTargetResponseDtoStateEnum ACTIVE = _$notificationTargetResponseDtoStateEnum_ACTIVE;
  /// 目标当前状态；只有 ACTIVE 可以导航
  @BuiltValueEnumConst(wireName: r'CONTENT_DELETED')
  static const NotificationTargetResponseDtoStateEnum CONTENT_DELETED = _$notificationTargetResponseDtoStateEnum_CONTENT_DELETED;
  /// 目标当前状态；只有 ACTIVE 可以导航
  @BuiltValueEnumConst(wireName: r'USER_DEACTIVATED')
  static const NotificationTargetResponseDtoStateEnum USER_DEACTIVATED = _$notificationTargetResponseDtoStateEnum_USER_DEACTIVATED;
  /// 目标当前状态；只有 ACTIVE 可以导航
  @BuiltValueEnumConst(wireName: r'NO_TARGET')
  static const NotificationTargetResponseDtoStateEnum NO_TARGET = _$notificationTargetResponseDtoStateEnum_NO_TARGET;
  /// 目标当前状态；只有 ACTIVE 可以导航
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const NotificationTargetResponseDtoStateEnum unknownDefaultOpenApi = _$notificationTargetResponseDtoStateEnum_unknownDefaultOpenApi;

  static Serializer<NotificationTargetResponseDtoStateEnum> get serializer => _$notificationTargetResponseDtoStateEnumSerializer;

  const NotificationTargetResponseDtoStateEnum._(String name): super(name);

  static BuiltSet<NotificationTargetResponseDtoStateEnum> get values => _$notificationTargetResponseDtoStateEnumValues;
  static NotificationTargetResponseDtoStateEnum valueOf(String name) => _$notificationTargetResponseDtoStateEnumValueOf(name);
}
