//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/direct_message_preview_response_dto.dart';
import 'package:wenyou_api/src/model/direct_message_user_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_conversation_response_dto.g.dart';

/// DirectConversationResponseDto
///
/// Properties:
/// * [id]
/// * [status]
/// * [requestDirection]
/// * [otherUser]
/// * [lastMessage]
/// * [unreadCount]
/// * [archivedAt]
/// * [lastMessageAt]
/// * [createdAt]
/// * [canSend]
/// * [canAccept]
/// * [canDecline]
/// * [isBlocked]
@BuiltValue()
abstract class DirectConversationResponseDto implements Built<DirectConversationResponseDto, DirectConversationResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  DirectConversationResponseDtoStatusEnum get status;
  // enum statusEnum {  PENDING,  ACCEPTED,  DECLINED,  CANCELED,  };

  @BuiltValueField(wireName: r'requestDirection')
  DirectConversationResponseDtoRequestDirectionEnum get requestDirection;
  // enum requestDirectionEnum {  NONE,  INCOMING,  OUTGOING,  };

  @BuiltValueField(wireName: r'otherUser')
  DirectMessageUserResponseDto get otherUser;

  @BuiltValueField(wireName: r'lastMessage')
  DirectMessagePreviewResponseDto? get lastMessage;

  @BuiltValueField(wireName: r'unreadCount')
  num get unreadCount;

  @BuiltValueField(wireName: r'archivedAt')
  DateTime? get archivedAt;

  @BuiltValueField(wireName: r'lastMessageAt')
  DateTime? get lastMessageAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'canSend')
  bool get canSend;

  @BuiltValueField(wireName: r'canAccept')
  bool get canAccept;

  @BuiltValueField(wireName: r'canDecline')
  bool get canDecline;

  @BuiltValueField(wireName: r'isBlocked')
  bool get isBlocked;

  DirectConversationResponseDto._();

  factory DirectConversationResponseDto([void updates(DirectConversationResponseDtoBuilder b)]) = _$DirectConversationResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectConversationResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectConversationResponseDto> get serializer => _$DirectConversationResponseDtoSerializer();
}

class _$DirectConversationResponseDtoSerializer implements PrimitiveSerializer<DirectConversationResponseDto> {
  @override
  final Iterable<Type> types = const [DirectConversationResponseDto, _$DirectConversationResponseDto];

  @override
  final String wireName = r'DirectConversationResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectConversationResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DirectConversationResponseDtoStatusEnum),
    );
    yield r'requestDirection';
    yield serializers.serialize(
      object.requestDirection,
      specifiedType: const FullType(DirectConversationResponseDtoRequestDirectionEnum),
    );
    yield r'otherUser';
    yield serializers.serialize(
      object.otherUser,
      specifiedType: const FullType(DirectMessageUserResponseDto),
    );
    yield r'lastMessage';
    yield object.lastMessage == null ? null : serializers.serialize(
      object.lastMessage,
      specifiedType: const FullType.nullable(DirectMessagePreviewResponseDto),
    );
    yield r'unreadCount';
    yield serializers.serialize(
      object.unreadCount,
      specifiedType: const FullType(num),
    );
    yield r'archivedAt';
    yield object.archivedAt == null ? null : serializers.serialize(
      object.archivedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'lastMessageAt';
    yield object.lastMessageAt == null ? null : serializers.serialize(
      object.lastMessageAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'canSend';
    yield serializers.serialize(
      object.canSend,
      specifiedType: const FullType(bool),
    );
    yield r'canAccept';
    yield serializers.serialize(
      object.canAccept,
      specifiedType: const FullType(bool),
    );
    yield r'canDecline';
    yield serializers.serialize(
      object.canDecline,
      specifiedType: const FullType(bool),
    );
    yield r'isBlocked';
    yield serializers.serialize(
      object.isBlocked,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DirectConversationResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectConversationResponseDtoBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DirectConversationResponseDtoStatusEnum),
          ) as DirectConversationResponseDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'requestDirection':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DirectConversationResponseDtoRequestDirectionEnum),
          ) as DirectConversationResponseDtoRequestDirectionEnum;
          result.requestDirection = valueDes;
          break;
        case r'otherUser':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DirectMessageUserResponseDto),
          ) as DirectMessageUserResponseDto;
          result.otherUser.replace(valueDes);
          break;
        case r'lastMessage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DirectMessagePreviewResponseDto),
          ) as DirectMessagePreviewResponseDto?;
          if (valueDes == null) continue;
          result.lastMessage.replace(valueDes);
          break;
        case r'unreadCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.unreadCount = valueDes;
          break;
        case r'archivedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.archivedAt = valueDes;
          break;
        case r'lastMessageAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastMessageAt = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'canSend':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canSend = valueDes;
          break;
        case r'canAccept':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canAccept = valueDes;
          break;
        case r'canDecline':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canDecline = valueDes;
          break;
        case r'isBlocked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isBlocked = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DirectConversationResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectConversationResponseDtoBuilder();
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

class DirectConversationResponseDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PENDING')
  static const DirectConversationResponseDtoStatusEnum PENDING = _$directConversationResponseDtoStatusEnum_PENDING;
  @BuiltValueEnumConst(wireName: r'ACCEPTED')
  static const DirectConversationResponseDtoStatusEnum ACCEPTED = _$directConversationResponseDtoStatusEnum_ACCEPTED;
  @BuiltValueEnumConst(wireName: r'DECLINED')
  static const DirectConversationResponseDtoStatusEnum DECLINED = _$directConversationResponseDtoStatusEnum_DECLINED;
  @BuiltValueEnumConst(wireName: r'CANCELED')
  static const DirectConversationResponseDtoStatusEnum CANCELED = _$directConversationResponseDtoStatusEnum_CANCELED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DirectConversationResponseDtoStatusEnum unknownDefaultOpenApi = _$directConversationResponseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<DirectConversationResponseDtoStatusEnum> get serializer => _$directConversationResponseDtoStatusEnumSerializer;

  const DirectConversationResponseDtoStatusEnum._(String name): super(name);

  static BuiltSet<DirectConversationResponseDtoStatusEnum> get values => _$directConversationResponseDtoStatusEnumValues;
  static DirectConversationResponseDtoStatusEnum valueOf(String name) => _$directConversationResponseDtoStatusEnumValueOf(name);
}

class DirectConversationResponseDtoRequestDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'NONE')
  static const DirectConversationResponseDtoRequestDirectionEnum NONE = _$directConversationResponseDtoRequestDirectionEnum_NONE;
  @BuiltValueEnumConst(wireName: r'INCOMING')
  static const DirectConversationResponseDtoRequestDirectionEnum INCOMING = _$directConversationResponseDtoRequestDirectionEnum_INCOMING;
  @BuiltValueEnumConst(wireName: r'OUTGOING')
  static const DirectConversationResponseDtoRequestDirectionEnum OUTGOING = _$directConversationResponseDtoRequestDirectionEnum_OUTGOING;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DirectConversationResponseDtoRequestDirectionEnum unknownDefaultOpenApi = _$directConversationResponseDtoRequestDirectionEnum_unknownDefaultOpenApi;

  static Serializer<DirectConversationResponseDtoRequestDirectionEnum> get serializer => _$directConversationResponseDtoRequestDirectionEnumSerializer;

  const DirectConversationResponseDtoRequestDirectionEnum._(String name): super(name);

  static BuiltSet<DirectConversationResponseDtoRequestDirectionEnum> get values => _$directConversationResponseDtoRequestDirectionEnumValues;
  static DirectConversationResponseDtoRequestDirectionEnum valueOf(String name) => _$directConversationResponseDtoRequestDirectionEnumValueOf(name);
}
