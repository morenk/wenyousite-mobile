//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:wenyou_api/src/model/user_condition_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'send_system_notification_dto.g.dart';

/// SendSystemNotificationDto
///
/// Properties:
/// * [content] - 通知正文
/// * [payload] - 结构化数据（可选，供前端渲染）
/// * [recipientIds] - 接收者用户 ID 列表（手动指定，优先级高于条件筛选）
/// * [conditions] - 用户筛选条件（不指定则全站广播）
/// * [threadId] - 关联主题帖 ID（可选，前端跳转用）
@BuiltValue()
abstract class SendSystemNotificationDto implements Built<SendSystemNotificationDto, SendSystemNotificationDtoBuilder> {
  /// 通知正文
  @BuiltValueField(wireName: r'content')
  String get content;

  /// 结构化数据（可选，供前端渲染）
  @BuiltValueField(wireName: r'payload')
  JsonObject? get payload;

  /// 接收者用户 ID 列表（手动指定，优先级高于条件筛选）
  @BuiltValueField(wireName: r'recipientIds')
  BuiltList<String>? get recipientIds;

  /// 用户筛选条件（不指定则全站广播）
  @BuiltValueField(wireName: r'conditions')
  UserConditionDto? get conditions;

  /// 关联主题帖 ID（可选，前端跳转用）
  @BuiltValueField(wireName: r'threadId')
  String? get threadId;

  SendSystemNotificationDto._();

  factory SendSystemNotificationDto([void updates(SendSystemNotificationDtoBuilder b)]) = _$SendSystemNotificationDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SendSystemNotificationDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SendSystemNotificationDto> get serializer => _$SendSystemNotificationDtoSerializer();
}

class _$SendSystemNotificationDtoSerializer implements PrimitiveSerializer<SendSystemNotificationDto> {
  @override
  final Iterable<Type> types = const [SendSystemNotificationDto, _$SendSystemNotificationDto];

  @override
  final String wireName = r'SendSystemNotificationDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SendSystemNotificationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    if (object.payload != null) {
      yield r'payload';
      yield serializers.serialize(
        object.payload,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.recipientIds != null) {
      yield r'recipientIds';
      yield serializers.serialize(
        object.recipientIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.conditions != null) {
      yield r'conditions';
      yield serializers.serialize(
        object.conditions,
        specifiedType: const FullType(UserConditionDto),
      );
    }
    if (object.threadId != null) {
      yield r'threadId';
      yield serializers.serialize(
        object.threadId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SendSystemNotificationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SendSystemNotificationDtoBuilder result,
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
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.payload = valueDes;
          break;
        case r'recipientIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.recipientIds.replace(valueDes);
          break;
        case r'conditions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserConditionDto),
          ) as UserConditionDto;
          result.conditions.replace(valueDes);
          break;
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.threadId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SendSystemNotificationDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SendSystemNotificationDtoBuilder();
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
