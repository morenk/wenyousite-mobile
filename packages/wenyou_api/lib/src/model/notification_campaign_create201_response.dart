//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/notification_campaign_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_campaign_create201_response.g.dart';

/// NotificationCampaignCreate201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class NotificationCampaignCreate201Response implements ApiSuccessEnvelope, Built<NotificationCampaignCreate201Response, NotificationCampaignCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  NotificationCampaignResponseDto get data;

  NotificationCampaignCreate201Response._();

  factory NotificationCampaignCreate201Response([void updates(NotificationCampaignCreate201ResponseBuilder b)]) = _$NotificationCampaignCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationCampaignCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationCampaignCreate201Response> get serializer => _$NotificationCampaignCreate201ResponseSerializer();
}

class _$NotificationCampaignCreate201ResponseSerializer implements PrimitiveSerializer<NotificationCampaignCreate201Response> {
  @override
  final Iterable<Type> types = const [NotificationCampaignCreate201Response, _$NotificationCampaignCreate201Response];

  @override
  final String wireName = r'NotificationCampaignCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationCampaignCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(NotificationCampaignResponseDto),
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
    NotificationCampaignCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationCampaignCreate201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationCampaignResponseDto),
          ) as NotificationCampaignResponseDto;
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
  NotificationCampaignCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationCampaignCreate201ResponseBuilder();
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

class NotificationCampaignCreate201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const NotificationCampaignCreate201ResponseCodeEnum number0 = _$notificationCampaignCreate201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const NotificationCampaignCreate201ResponseCodeEnum unknownDefaultOpenApi = _$notificationCampaignCreate201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<NotificationCampaignCreate201ResponseCodeEnum> get serializer => _$notificationCampaignCreate201ResponseCodeEnumSerializer;

  const NotificationCampaignCreate201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<NotificationCampaignCreate201ResponseCodeEnum> get values => _$notificationCampaignCreate201ResponseCodeEnumValues;
  static NotificationCampaignCreate201ResponseCodeEnum valueOf(String name) => _$notificationCampaignCreate201ResponseCodeEnumValueOf(name);
}
