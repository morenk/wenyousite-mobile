//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subscriptions_remove200_response.g.dart';

/// SubscriptionsRemove200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class SubscriptionsRemove200Response implements ApiSuccessEnvelope, Built<SubscriptionsRemove200Response, SubscriptionsRemove200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  SubscriptionsRemove200Response._();

  factory SubscriptionsRemove200Response([void updates(SubscriptionsRemove200ResponseBuilder b)]) = _$SubscriptionsRemove200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubscriptionsRemove200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubscriptionsRemove200Response> get serializer => _$SubscriptionsRemove200ResponseSerializer();
}

class _$SubscriptionsRemove200ResponseSerializer implements PrimitiveSerializer<SubscriptionsRemove200Response> {
  @override
  final Iterable<Type> types = const [SubscriptionsRemove200Response, _$SubscriptionsRemove200Response];

  @override
  final String wireName = r'SubscriptionsRemove200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubscriptionsRemove200Response object, {
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
    SubscriptionsRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubscriptionsRemove200ResponseBuilder result,
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
  SubscriptionsRemove200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubscriptionsRemove200ResponseBuilder();
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

class SubscriptionsRemove200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SubscriptionsRemove200ResponseCodeEnum number0 = _$subscriptionsRemove200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SubscriptionsRemove200ResponseCodeEnum unknownDefaultOpenApi = _$subscriptionsRemove200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SubscriptionsRemove200ResponseCodeEnum> get serializer => _$subscriptionsRemove200ResponseCodeEnumSerializer;

  const SubscriptionsRemove200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SubscriptionsRemove200ResponseCodeEnum> get values => _$subscriptionsRemove200ResponseCodeEnumValues;
  static SubscriptionsRemove200ResponseCodeEnum valueOf(String name) => _$subscriptionsRemove200ResponseCodeEnumValueOf(name);
}
