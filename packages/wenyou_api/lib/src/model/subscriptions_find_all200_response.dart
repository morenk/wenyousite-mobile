//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/subscription_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subscriptions_find_all200_response.g.dart';

/// SubscriptionsFindAll200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class SubscriptionsFindAll200Response implements ApiSuccessEnvelope, Built<SubscriptionsFindAll200Response, SubscriptionsFindAll200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<SubscriptionResponseDto> get data;

  SubscriptionsFindAll200Response._();

  factory SubscriptionsFindAll200Response([void updates(SubscriptionsFindAll200ResponseBuilder b)]) = _$SubscriptionsFindAll200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubscriptionsFindAll200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubscriptionsFindAll200Response> get serializer => _$SubscriptionsFindAll200ResponseSerializer();
}

class _$SubscriptionsFindAll200ResponseSerializer implements PrimitiveSerializer<SubscriptionsFindAll200Response> {
  @override
  final Iterable<Type> types = const [SubscriptionsFindAll200Response, _$SubscriptionsFindAll200Response];

  @override
  final String wireName = r'SubscriptionsFindAll200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubscriptionsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(SubscriptionResponseDto)]),
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
    SubscriptionsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubscriptionsFindAll200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SubscriptionResponseDto)]),
          ) as BuiltList<SubscriptionResponseDto>;
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
  SubscriptionsFindAll200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubscriptionsFindAll200ResponseBuilder();
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

class SubscriptionsFindAll200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SubscriptionsFindAll200ResponseCodeEnum number0 = _$subscriptionsFindAll200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SubscriptionsFindAll200ResponseCodeEnum unknownDefaultOpenApi = _$subscriptionsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SubscriptionsFindAll200ResponseCodeEnum> get serializer => _$subscriptionsFindAll200ResponseCodeEnumSerializer;

  const SubscriptionsFindAll200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SubscriptionsFindAll200ResponseCodeEnum> get values => _$subscriptionsFindAll200ResponseCodeEnumValues;
  static SubscriptionsFindAll200ResponseCodeEnum valueOf(String name) => _$subscriptionsFindAll200ResponseCodeEnumValueOf(name);
}
