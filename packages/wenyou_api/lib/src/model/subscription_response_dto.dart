//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/subscription_thread_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subscription_response_dto.g.dart';

/// SubscriptionResponseDto
///
/// Properties:
/// * [id]
/// * [userId]
/// * [threadId]
/// * [targetUserId]
/// * [type]
/// * [createdAt]
/// * [thread]
@BuiltValue()
abstract class SubscriptionResponseDto implements Built<SubscriptionResponseDto, SubscriptionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  @BuiltValueField(wireName: r'targetUserId')
  String? get targetUserId;

  @BuiltValueField(wireName: r'type')
  SubscriptionResponseDtoTypeEnum get type;
  // enum typeEnum {  THREAD,  USER,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'thread')
  SubscriptionThreadResponseDto get thread;

  SubscriptionResponseDto._();

  factory SubscriptionResponseDto([void updates(SubscriptionResponseDtoBuilder b)]) = _$SubscriptionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubscriptionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubscriptionResponseDto> get serializer => _$SubscriptionResponseDtoSerializer();
}

class _$SubscriptionResponseDtoSerializer implements PrimitiveSerializer<SubscriptionResponseDto> {
  @override
  final Iterable<Type> types = const [SubscriptionResponseDto, _$SubscriptionResponseDto];

  @override
  final String wireName = r'SubscriptionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubscriptionResponseDto object, {
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
    yield r'threadId';
    yield serializers.serialize(
      object.threadId,
      specifiedType: const FullType(String),
    );
    yield r'targetUserId';
    yield object.targetUserId == null ? null : serializers.serialize(
      object.targetUserId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(SubscriptionResponseDtoTypeEnum),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'thread';
    yield serializers.serialize(
      object.thread,
      specifiedType: const FullType(SubscriptionThreadResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SubscriptionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubscriptionResponseDtoBuilder result,
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
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.threadId = valueDes;
          break;
        case r'targetUserId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.targetUserId = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SubscriptionResponseDtoTypeEnum),
          ) as SubscriptionResponseDtoTypeEnum;
          result.type = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'thread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SubscriptionThreadResponseDto),
          ) as SubscriptionThreadResponseDto;
          result.thread.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SubscriptionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubscriptionResponseDtoBuilder();
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

class SubscriptionResponseDtoTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'THREAD')
  static const SubscriptionResponseDtoTypeEnum THREAD = _$subscriptionResponseDtoTypeEnum_THREAD;
  @BuiltValueEnumConst(wireName: r'USER')
  static const SubscriptionResponseDtoTypeEnum USER = _$subscriptionResponseDtoTypeEnum_USER;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const SubscriptionResponseDtoTypeEnum unknownDefaultOpenApi = _$subscriptionResponseDtoTypeEnum_unknownDefaultOpenApi;

  static Serializer<SubscriptionResponseDtoTypeEnum> get serializer => _$subscriptionResponseDtoTypeEnumSerializer;

  const SubscriptionResponseDtoTypeEnum._(String name): super(name);

  static BuiltSet<SubscriptionResponseDtoTypeEnum> get values => _$subscriptionResponseDtoTypeEnumValues;
  static SubscriptionResponseDtoTypeEnum valueOf(String name) => _$subscriptionResponseDtoTypeEnumValueOf(name);
}
