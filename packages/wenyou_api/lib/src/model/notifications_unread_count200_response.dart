//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/unread_notification_count_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notifications_unread_count200_response.g.dart';

/// NotificationsUnreadCount200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class NotificationsUnreadCount200Response implements ApiSuccessEnvelope, Built<NotificationsUnreadCount200Response, NotificationsUnreadCount200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  UnreadNotificationCountResponseDto get data;

  NotificationsUnreadCount200Response._();

  factory NotificationsUnreadCount200Response([void updates(NotificationsUnreadCount200ResponseBuilder b)]) = _$NotificationsUnreadCount200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationsUnreadCount200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationsUnreadCount200Response> get serializer => _$NotificationsUnreadCount200ResponseSerializer();
}

class _$NotificationsUnreadCount200ResponseSerializer implements PrimitiveSerializer<NotificationsUnreadCount200Response> {
  @override
  final Iterable<Type> types = const [NotificationsUnreadCount200Response, _$NotificationsUnreadCount200Response];

  @override
  final String wireName = r'NotificationsUnreadCount200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationsUnreadCount200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(UnreadNotificationCountResponseDto),
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
    NotificationsUnreadCount200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationsUnreadCount200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UnreadNotificationCountResponseDto),
          ) as UnreadNotificationCountResponseDto;
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
  NotificationsUnreadCount200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationsUnreadCount200ResponseBuilder();
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

class NotificationsUnreadCount200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const NotificationsUnreadCount200ResponseCodeEnum number0 = _$notificationsUnreadCount200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const NotificationsUnreadCount200ResponseCodeEnum unknownDefaultOpenApi = _$notificationsUnreadCount200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<NotificationsUnreadCount200ResponseCodeEnum> get serializer => _$notificationsUnreadCount200ResponseCodeEnumSerializer;

  const NotificationsUnreadCount200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<NotificationsUnreadCount200ResponseCodeEnum> get values => _$notificationsUnreadCount200ResponseCodeEnumValues;
  static NotificationsUnreadCount200ResponseCodeEnum valueOf(String name) => _$notificationsUnreadCount200ResponseCodeEnumValueOf(name);
}
