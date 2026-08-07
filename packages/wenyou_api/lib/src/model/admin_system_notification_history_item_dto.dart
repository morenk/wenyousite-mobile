//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_notification_user_response_dto.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_system_notification_history_item_dto.g.dart';

/// AdminSystemNotificationHistoryItemDto
///
/// Properties:
/// * [id]
/// * [userId]
/// * [content]
/// * [payload]
/// * [threadId]
/// * [isRead]
/// * [createdAt]
/// * [user]
@BuiltValue()
abstract class AdminSystemNotificationHistoryItemDto implements Built<AdminSystemNotificationHistoryItemDto, AdminSystemNotificationHistoryItemDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'content')
  String? get content;

  @BuiltValueField(wireName: r'payload')
  BuiltMap<String, JsonObject?>? get payload;

  @BuiltValueField(wireName: r'threadId')
  String? get threadId;

  @BuiltValueField(wireName: r'isRead')
  bool get isRead;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'user')
  AdminNotificationUserResponseDto get user;

  AdminSystemNotificationHistoryItemDto._();

  factory AdminSystemNotificationHistoryItemDto([void updates(AdminSystemNotificationHistoryItemDtoBuilder b)]) = _$AdminSystemNotificationHistoryItemDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminSystemNotificationHistoryItemDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminSystemNotificationHistoryItemDto> get serializer => _$AdminSystemNotificationHistoryItemDtoSerializer();
}

class _$AdminSystemNotificationHistoryItemDtoSerializer implements PrimitiveSerializer<AdminSystemNotificationHistoryItemDto> {
  @override
  final Iterable<Type> types = const [AdminSystemNotificationHistoryItemDto, _$AdminSystemNotificationHistoryItemDto];

  @override
  final String wireName = r'AdminSystemNotificationHistoryItemDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminSystemNotificationHistoryItemDto object, {
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
    yield r'content';
    yield object.content == null ? null : serializers.serialize(
      object.content,
      specifiedType: const FullType.nullable(String),
    );
    yield r'payload';
    yield object.payload == null ? null : serializers.serialize(
      object.payload,
      specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'threadId';
    yield object.threadId == null ? null : serializers.serialize(
      object.threadId,
      specifiedType: const FullType.nullable(String),
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
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(AdminNotificationUserResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminSystemNotificationHistoryItemDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminSystemNotificationHistoryItemDtoBuilder result,
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
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.payload.replace(valueDes);
          break;
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.threadId = valueDes;
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
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminNotificationUserResponseDto),
          ) as AdminNotificationUserResponseDto;
          result.user.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminSystemNotificationHistoryItemDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminSystemNotificationHistoryItemDtoBuilder();
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
