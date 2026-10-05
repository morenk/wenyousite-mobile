//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/rp_identity_state_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rp_identities_find200_response.g.dart';

/// RpIdentitiesFind200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class RpIdentitiesFind200Response implements ApiSuccessEnvelope, Built<RpIdentitiesFind200Response, RpIdentitiesFind200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  RpIdentityStateDto get data;

  RpIdentitiesFind200Response._();

  factory RpIdentitiesFind200Response([void updates(RpIdentitiesFind200ResponseBuilder b)]) = _$RpIdentitiesFind200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RpIdentitiesFind200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RpIdentitiesFind200Response> get serializer => _$RpIdentitiesFind200ResponseSerializer();
}

class _$RpIdentitiesFind200ResponseSerializer implements PrimitiveSerializer<RpIdentitiesFind200Response> {
  @override
  final Iterable<Type> types = const [RpIdentitiesFind200Response, _$RpIdentitiesFind200Response];

  @override
  final String wireName = r'RpIdentitiesFind200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RpIdentitiesFind200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(RpIdentityStateDto),
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
    RpIdentitiesFind200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RpIdentitiesFind200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RpIdentityStateDto),
          ) as RpIdentityStateDto;
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
  RpIdentitiesFind200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RpIdentitiesFind200ResponseBuilder();
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

class RpIdentitiesFind200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const RpIdentitiesFind200ResponseCodeEnum number0 = _$rpIdentitiesFind200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const RpIdentitiesFind200ResponseCodeEnum unknownDefaultOpenApi = _$rpIdentitiesFind200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<RpIdentitiesFind200ResponseCodeEnum> get serializer => _$rpIdentitiesFind200ResponseCodeEnumSerializer;

  const RpIdentitiesFind200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<RpIdentitiesFind200ResponseCodeEnum> get values => _$rpIdentitiesFind200ResponseCodeEnumValues;
  static RpIdentitiesFind200ResponseCodeEnum valueOf(String name) => _$rpIdentitiesFind200ResponseCodeEnumValueOf(name);
}
