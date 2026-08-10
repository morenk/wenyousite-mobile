//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_recipient_count_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_campaign_preview200_response.g.dart';

/// NotificationCampaignPreview200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class NotificationCampaignPreview200Response implements ApiSuccessEnvelope, Built<NotificationCampaignPreview200Response, NotificationCampaignPreview200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminRecipientCountResponseDto get data;

  NotificationCampaignPreview200Response._();

  factory NotificationCampaignPreview200Response([void updates(NotificationCampaignPreview200ResponseBuilder b)]) = _$NotificationCampaignPreview200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationCampaignPreview200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationCampaignPreview200Response> get serializer => _$NotificationCampaignPreview200ResponseSerializer();
}

class _$NotificationCampaignPreview200ResponseSerializer implements PrimitiveSerializer<NotificationCampaignPreview200Response> {
  @override
  final Iterable<Type> types = const [NotificationCampaignPreview200Response, _$NotificationCampaignPreview200Response];

  @override
  final String wireName = r'NotificationCampaignPreview200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationCampaignPreview200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminRecipientCountResponseDto),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationCampaignPreview200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationCampaignPreview200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminRecipientCountResponseDto),
          ) as AdminRecipientCountResponseDto;
          result.data.replace(valueDes);
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
          ) as ApiSuccessEnvelopeCodeEnum;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationCampaignPreview200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationCampaignPreview200ResponseBuilder();
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

class NotificationCampaignPreview200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const NotificationCampaignPreview200ResponseCodeEnum number0 = _$notificationCampaignPreview200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const NotificationCampaignPreview200ResponseCodeEnum unknownDefaultOpenApi = _$notificationCampaignPreview200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<NotificationCampaignPreview200ResponseCodeEnum> get serializer => _$notificationCampaignPreview200ResponseCodeEnumSerializer;

  const NotificationCampaignPreview200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<NotificationCampaignPreview200ResponseCodeEnum> get values => _$notificationCampaignPreview200ResponseCodeEnumValues;
  static NotificationCampaignPreview200ResponseCodeEnum valueOf(String name) => _$notificationCampaignPreview200ResponseCodeEnumValueOf(name);
}
