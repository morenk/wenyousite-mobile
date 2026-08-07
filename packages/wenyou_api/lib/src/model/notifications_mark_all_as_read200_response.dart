//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notifications_mark_all_as_read200_response.g.dart';

/// NotificationsMarkAllAsRead200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class NotificationsMarkAllAsRead200Response implements ApiSuccessEnvelope, Built<NotificationsMarkAllAsRead200Response, NotificationsMarkAllAsRead200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  NotificationsMarkAllAsRead200Response._();

  factory NotificationsMarkAllAsRead200Response([void updates(NotificationsMarkAllAsRead200ResponseBuilder b)]) = _$NotificationsMarkAllAsRead200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationsMarkAllAsRead200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationsMarkAllAsRead200Response> get serializer => _$NotificationsMarkAllAsRead200ResponseSerializer();
}

class _$NotificationsMarkAllAsRead200ResponseSerializer implements PrimitiveSerializer<NotificationsMarkAllAsRead200Response> {
  @override
  final Iterable<Type> types = const [NotificationsMarkAllAsRead200Response, _$NotificationsMarkAllAsRead200Response];

  @override
  final String wireName = r'NotificationsMarkAllAsRead200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationsMarkAllAsRead200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MessageResponseDto),
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
    NotificationsMarkAllAsRead200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationsMarkAllAsRead200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MessageResponseDto),
          ) as MessageResponseDto;
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
  NotificationsMarkAllAsRead200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationsMarkAllAsRead200ResponseBuilder();
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

class NotificationsMarkAllAsRead200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const NotificationsMarkAllAsRead200ResponseCodeEnum number0 = _$notificationsMarkAllAsRead200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const NotificationsMarkAllAsRead200ResponseCodeEnum unknownDefaultOpenApi = _$notificationsMarkAllAsRead200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<NotificationsMarkAllAsRead200ResponseCodeEnum> get serializer => _$notificationsMarkAllAsRead200ResponseCodeEnumSerializer;

  const NotificationsMarkAllAsRead200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<NotificationsMarkAllAsRead200ResponseCodeEnum> get values => _$notificationsMarkAllAsRead200ResponseCodeEnumValues;
  static NotificationsMarkAllAsRead200ResponseCodeEnum valueOf(String name) => _$notificationsMarkAllAsRead200ResponseCodeEnumValueOf(name);
}
