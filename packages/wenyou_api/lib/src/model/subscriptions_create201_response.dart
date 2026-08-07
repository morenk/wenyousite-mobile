//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/subscription_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subscriptions_create201_response.g.dart';

/// SubscriptionsCreate201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class SubscriptionsCreate201Response implements ApiSuccessEnvelope, Built<SubscriptionsCreate201Response, SubscriptionsCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  SubscriptionResponseDto get data;

  SubscriptionsCreate201Response._();

  factory SubscriptionsCreate201Response([void updates(SubscriptionsCreate201ResponseBuilder b)]) = _$SubscriptionsCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubscriptionsCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubscriptionsCreate201Response> get serializer => _$SubscriptionsCreate201ResponseSerializer();
}

class _$SubscriptionsCreate201ResponseSerializer implements PrimitiveSerializer<SubscriptionsCreate201Response> {
  @override
  final Iterable<Type> types = const [SubscriptionsCreate201Response, _$SubscriptionsCreate201Response];

  @override
  final String wireName = r'SubscriptionsCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubscriptionsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(SubscriptionResponseDto),
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
    SubscriptionsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubscriptionsCreate201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SubscriptionResponseDto),
          ) as SubscriptionResponseDto;
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
  SubscriptionsCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubscriptionsCreate201ResponseBuilder();
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

class SubscriptionsCreate201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SubscriptionsCreate201ResponseCodeEnum number0 = _$subscriptionsCreate201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SubscriptionsCreate201ResponseCodeEnum unknownDefaultOpenApi = _$subscriptionsCreate201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SubscriptionsCreate201ResponseCodeEnum> get serializer => _$subscriptionsCreate201ResponseCodeEnumSerializer;

  const SubscriptionsCreate201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SubscriptionsCreate201ResponseCodeEnum> get values => _$subscriptionsCreate201ResponseCodeEnumValues;
  static SubscriptionsCreate201ResponseCodeEnum valueOf(String name) => _$subscriptionsCreate201ResponseCodeEnumValueOf(name);
}
