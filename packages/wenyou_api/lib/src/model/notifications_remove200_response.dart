//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notifications_remove200_response.g.dart';

/// NotificationsRemove200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class NotificationsRemove200Response implements ApiSuccessEnvelope, Built<NotificationsRemove200Response, NotificationsRemove200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  NotificationsRemove200Response._();

  factory NotificationsRemove200Response([void updates(NotificationsRemove200ResponseBuilder b)]) = _$NotificationsRemove200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationsRemove200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationsRemove200Response> get serializer => _$NotificationsRemove200ResponseSerializer();
}

class _$NotificationsRemove200ResponseSerializer implements PrimitiveSerializer<NotificationsRemove200Response> {
  @override
  final Iterable<Type> types = const [NotificationsRemove200Response, _$NotificationsRemove200Response];

  @override
  final String wireName = r'NotificationsRemove200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationsRemove200Response object, {
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
    NotificationsRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationsRemove200ResponseBuilder result,
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
  NotificationsRemove200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationsRemove200ResponseBuilder();
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

class NotificationsRemove200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const NotificationsRemove200ResponseCodeEnum number0 = _$notificationsRemove200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const NotificationsRemove200ResponseCodeEnum unknownDefaultOpenApi = _$notificationsRemove200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<NotificationsRemove200ResponseCodeEnum> get serializer => _$notificationsRemove200ResponseCodeEnumSerializer;

  const NotificationsRemove200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<NotificationsRemove200ResponseCodeEnum> get values => _$notificationsRemove200ResponseCodeEnumValues;
  static NotificationsRemove200ResponseCodeEnum valueOf(String name) => _$notificationsRemove200ResponseCodeEnumValueOf(name);
}
