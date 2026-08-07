//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notifications_set_read_status200_response.g.dart';

/// NotificationsSetReadStatus200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class NotificationsSetReadStatus200Response implements ApiSuccessEnvelope, Built<NotificationsSetReadStatus200Response, NotificationsSetReadStatus200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  NotificationsSetReadStatus200Response._();

  factory NotificationsSetReadStatus200Response([void updates(NotificationsSetReadStatus200ResponseBuilder b)]) = _$NotificationsSetReadStatus200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationsSetReadStatus200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationsSetReadStatus200Response> get serializer => _$NotificationsSetReadStatus200ResponseSerializer();
}

class _$NotificationsSetReadStatus200ResponseSerializer implements PrimitiveSerializer<NotificationsSetReadStatus200Response> {
  @override
  final Iterable<Type> types = const [NotificationsSetReadStatus200Response, _$NotificationsSetReadStatus200Response];

  @override
  final String wireName = r'NotificationsSetReadStatus200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationsSetReadStatus200Response object, {
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
    NotificationsSetReadStatus200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationsSetReadStatus200ResponseBuilder result,
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
  NotificationsSetReadStatus200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationsSetReadStatus200ResponseBuilder();
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

class NotificationsSetReadStatus200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const NotificationsSetReadStatus200ResponseCodeEnum number0 = _$notificationsSetReadStatus200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const NotificationsSetReadStatus200ResponseCodeEnum unknownDefaultOpenApi = _$notificationsSetReadStatus200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<NotificationsSetReadStatus200ResponseCodeEnum> get serializer => _$notificationsSetReadStatus200ResponseCodeEnumSerializer;

  const NotificationsSetReadStatus200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<NotificationsSetReadStatus200ResponseCodeEnum> get values => _$notificationsSetReadStatus200ResponseCodeEnumValues;
  static NotificationsSetReadStatus200ResponseCodeEnum valueOf(String name) => _$notificationsSetReadStatus200ResponseCodeEnumValueOf(name);
}
