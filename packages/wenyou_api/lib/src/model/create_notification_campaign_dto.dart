//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/notification_audience_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_notification_campaign_dto.g.dart';

/// CreateNotificationCampaignDto
///
/// Properties:
/// * [title]
/// * [content]
/// * [scheduledAt]
/// * [audience]
/// * [destinationType]
/// * [destinationId]
@BuiltValue()
abstract class CreateNotificationCampaignDto implements Built<CreateNotificationCampaignDto, CreateNotificationCampaignDtoBuilder> {
  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'scheduledAt')
  DateTime get scheduledAt;

  @BuiltValueField(wireName: r'audience')
  NotificationAudienceDto? get audience;

  @BuiltValueField(wireName: r'destinationType')
  CreateNotificationCampaignDtoDestinationTypeEnum? get destinationType;
  // enum destinationTypeEnum {  THREAD,  };

  @BuiltValueField(wireName: r'destinationId')
  String? get destinationId;

  CreateNotificationCampaignDto._();

  factory CreateNotificationCampaignDto([void updates(CreateNotificationCampaignDtoBuilder b)]) = _$CreateNotificationCampaignDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateNotificationCampaignDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateNotificationCampaignDto> get serializer => _$CreateNotificationCampaignDtoSerializer();
}

class _$CreateNotificationCampaignDtoSerializer implements PrimitiveSerializer<CreateNotificationCampaignDto> {
  @override
  final Iterable<Type> types = const [CreateNotificationCampaignDto, _$CreateNotificationCampaignDto];

  @override
  final String wireName = r'CreateNotificationCampaignDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateNotificationCampaignDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'scheduledAt';
    yield serializers.serialize(
      object.scheduledAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.audience != null) {
      yield r'audience';
      yield serializers.serialize(
        object.audience,
        specifiedType: const FullType(NotificationAudienceDto),
      );
    }
    if (object.destinationType != null) {
      yield r'destinationType';
      yield serializers.serialize(
        object.destinationType,
        specifiedType: const FullType(CreateNotificationCampaignDtoDestinationTypeEnum),
      );
    }
    if (object.destinationId != null) {
      yield r'destinationId';
      yield serializers.serialize(
        object.destinationId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateNotificationCampaignDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateNotificationCampaignDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'scheduledAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.scheduledAt = valueDes;
          break;
        case r'audience':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationAudienceDto),
          ) as NotificationAudienceDto;
          result.audience.replace(valueDes);
          break;
        case r'destinationType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateNotificationCampaignDtoDestinationTypeEnum),
          ) as CreateNotificationCampaignDtoDestinationTypeEnum;
          result.destinationType = valueDes;
          break;
        case r'destinationId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.destinationId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateNotificationCampaignDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateNotificationCampaignDtoBuilder();
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

class CreateNotificationCampaignDtoDestinationTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'THREAD')
  static const CreateNotificationCampaignDtoDestinationTypeEnum THREAD = _$createNotificationCampaignDtoDestinationTypeEnum_THREAD;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CreateNotificationCampaignDtoDestinationTypeEnum unknownDefaultOpenApi = _$createNotificationCampaignDtoDestinationTypeEnum_unknownDefaultOpenApi;

  static Serializer<CreateNotificationCampaignDtoDestinationTypeEnum> get serializer => _$createNotificationCampaignDtoDestinationTypeEnumSerializer;

  const CreateNotificationCampaignDtoDestinationTypeEnum._(String name): super(name);

  static BuiltSet<CreateNotificationCampaignDtoDestinationTypeEnum> get values => _$createNotificationCampaignDtoDestinationTypeEnumValues;
  static CreateNotificationCampaignDtoDestinationTypeEnum valueOf(String name) => _$createNotificationCampaignDtoDestinationTypeEnumValueOf(name);
}
