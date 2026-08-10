//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_campaign_response_dto.g.dart';

/// NotificationCampaignResponseDto
///
/// Properties:
/// * [id]
/// * [title]
/// * [content]
/// * [status]
/// * [scheduledAt]
/// * [estimatedCount]
/// * [recipientCount]
/// * [audienceRole]
/// * [createdBy]
/// * [createdAt]
@BuiltValue()
abstract class NotificationCampaignResponseDto implements Built<NotificationCampaignResponseDto, NotificationCampaignResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'status')
  NotificationCampaignResponseDtoStatusEnum get status;
  // enum statusEnum {  SCHEDULED,  SENDING,  SENT,  CANCELED,  FAILED,  };

  @BuiltValueField(wireName: r'scheduledAt')
  DateTime get scheduledAt;

  @BuiltValueField(wireName: r'estimatedCount')
  num get estimatedCount;

  @BuiltValueField(wireName: r'recipientCount')
  num get recipientCount;

  @BuiltValueField(wireName: r'audienceRole')
  NotificationCampaignResponseDtoAudienceRoleEnum? get audienceRole;
  // enum audienceRoleEnum {  USER,  ADMIN,  SUPER_ADMIN,  };

  @BuiltValueField(wireName: r'createdBy')
  BuiltMap<String, JsonObject?>? get createdBy;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  NotificationCampaignResponseDto._();

  factory NotificationCampaignResponseDto([void updates(NotificationCampaignResponseDtoBuilder b)]) = _$NotificationCampaignResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationCampaignResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationCampaignResponseDto> get serializer => _$NotificationCampaignResponseDtoSerializer();
}

class _$NotificationCampaignResponseDtoSerializer implements PrimitiveSerializer<NotificationCampaignResponseDto> {
  @override
  final Iterable<Type> types = const [NotificationCampaignResponseDto, _$NotificationCampaignResponseDto];

  @override
  final String wireName = r'NotificationCampaignResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationCampaignResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(NotificationCampaignResponseDtoStatusEnum),
    );
    yield r'scheduledAt';
    yield serializers.serialize(
      object.scheduledAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'estimatedCount';
    yield serializers.serialize(
      object.estimatedCount,
      specifiedType: const FullType(num),
    );
    yield r'recipientCount';
    yield serializers.serialize(
      object.recipientCount,
      specifiedType: const FullType(num),
    );
    if (object.audienceRole != null) {
      yield r'audienceRole';
      yield serializers.serialize(
        object.audienceRole,
        specifiedType: const FullType(NotificationCampaignResponseDtoAudienceRoleEnum),
      );
    }
    if (object.createdBy != null) {
      yield r'createdBy';
      yield serializers.serialize(
        object.createdBy,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationCampaignResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationCampaignResponseDtoBuilder result,
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
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationCampaignResponseDtoStatusEnum),
          ) as NotificationCampaignResponseDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'scheduledAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.scheduledAt = valueDes;
          break;
        case r'estimatedCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.estimatedCount = valueDes;
          break;
        case r'recipientCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.recipientCount = valueDes;
          break;
        case r'audienceRole':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationCampaignResponseDtoAudienceRoleEnum),
          ) as NotificationCampaignResponseDtoAudienceRoleEnum;
          result.audienceRole = valueDes;
          break;
        case r'createdBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.createdBy.replace(valueDes);
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
  NotificationCampaignResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationCampaignResponseDtoBuilder();
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

class NotificationCampaignResponseDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SCHEDULED')
  static const NotificationCampaignResponseDtoStatusEnum SCHEDULED = _$notificationCampaignResponseDtoStatusEnum_SCHEDULED;
  @BuiltValueEnumConst(wireName: r'SENDING')
  static const NotificationCampaignResponseDtoStatusEnum SENDING = _$notificationCampaignResponseDtoStatusEnum_SENDING;
  @BuiltValueEnumConst(wireName: r'SENT')
  static const NotificationCampaignResponseDtoStatusEnum SENT = _$notificationCampaignResponseDtoStatusEnum_SENT;
  @BuiltValueEnumConst(wireName: r'CANCELED')
  static const NotificationCampaignResponseDtoStatusEnum CANCELED = _$notificationCampaignResponseDtoStatusEnum_CANCELED;
  @BuiltValueEnumConst(wireName: r'FAILED')
  static const NotificationCampaignResponseDtoStatusEnum FAILED = _$notificationCampaignResponseDtoStatusEnum_FAILED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const NotificationCampaignResponseDtoStatusEnum unknownDefaultOpenApi = _$notificationCampaignResponseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<NotificationCampaignResponseDtoStatusEnum> get serializer => _$notificationCampaignResponseDtoStatusEnumSerializer;

  const NotificationCampaignResponseDtoStatusEnum._(String name): super(name);

  static BuiltSet<NotificationCampaignResponseDtoStatusEnum> get values => _$notificationCampaignResponseDtoStatusEnumValues;
  static NotificationCampaignResponseDtoStatusEnum valueOf(String name) => _$notificationCampaignResponseDtoStatusEnumValueOf(name);
}

class NotificationCampaignResponseDtoAudienceRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const NotificationCampaignResponseDtoAudienceRoleEnum USER = _$notificationCampaignResponseDtoAudienceRoleEnum_USER;
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const NotificationCampaignResponseDtoAudienceRoleEnum ADMIN = _$notificationCampaignResponseDtoAudienceRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN')
  static const NotificationCampaignResponseDtoAudienceRoleEnum SUPER_ADMIN = _$notificationCampaignResponseDtoAudienceRoleEnum_SUPER_ADMIN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const NotificationCampaignResponseDtoAudienceRoleEnum unknownDefaultOpenApi = _$notificationCampaignResponseDtoAudienceRoleEnum_unknownDefaultOpenApi;

  static Serializer<NotificationCampaignResponseDtoAudienceRoleEnum> get serializer => _$notificationCampaignResponseDtoAudienceRoleEnumSerializer;

  const NotificationCampaignResponseDtoAudienceRoleEnum._(String name): super(name);

  static BuiltSet<NotificationCampaignResponseDtoAudienceRoleEnum> get values => _$notificationCampaignResponseDtoAudienceRoleEnumValues;
  static NotificationCampaignResponseDtoAudienceRoleEnum valueOf(String name) => _$notificationCampaignResponseDtoAudienceRoleEnumValueOf(name);
}
