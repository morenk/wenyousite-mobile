//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/notification_campaign_response_dto.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_campaign_list200_response.g.dart';

/// NotificationCampaignList200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class NotificationCampaignList200Response implements ApiPaginatedSuccessEnvelope, Built<NotificationCampaignList200Response, NotificationCampaignList200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<NotificationCampaignResponseDto> get data;

  NotificationCampaignList200Response._();

  factory NotificationCampaignList200Response([void updates(NotificationCampaignList200ResponseBuilder b)]) = _$NotificationCampaignList200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationCampaignList200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationCampaignList200Response> get serializer => _$NotificationCampaignList200ResponseSerializer();
}

class _$NotificationCampaignList200ResponseSerializer implements PrimitiveSerializer<NotificationCampaignList200Response> {
  @override
  final Iterable<Type> types = const [NotificationCampaignList200Response, _$NotificationCampaignList200Response];

  @override
  final String wireName = r'NotificationCampaignList200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationCampaignList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
    );
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(NotificationCampaignResponseDto)]),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(ApiPaginationMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationCampaignList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationCampaignList200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
          ) as ApiSuccessEnvelopeCodeEnum;
          result.code = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(NotificationCampaignResponseDto)]),
          ) as BuiltList<NotificationCampaignResponseDto>;
          result.data.replace(valueDes);
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiPaginationMeta),
          ) as ApiPaginationMeta;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationCampaignList200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationCampaignList200ResponseBuilder();
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

class NotificationCampaignList200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const NotificationCampaignList200ResponseCodeEnum number0 = _$notificationCampaignList200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const NotificationCampaignList200ResponseCodeEnum unknownDefaultOpenApi = _$notificationCampaignList200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<NotificationCampaignList200ResponseCodeEnum> get serializer => _$notificationCampaignList200ResponseCodeEnumSerializer;

  const NotificationCampaignList200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<NotificationCampaignList200ResponseCodeEnum> get values => _$notificationCampaignList200ResponseCodeEnumValues;
  static NotificationCampaignList200ResponseCodeEnum valueOf(String name) => _$notificationCampaignList200ResponseCodeEnumValueOf(name);
}
