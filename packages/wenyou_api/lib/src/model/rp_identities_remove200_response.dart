//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/rp_identity_state_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rp_identities_remove200_response.g.dart';

/// RpIdentitiesRemove200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class RpIdentitiesRemove200Response implements ApiSuccessEnvelope, Built<RpIdentitiesRemove200Response, RpIdentitiesRemove200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  RpIdentityStateDto get data;

  RpIdentitiesRemove200Response._();

  factory RpIdentitiesRemove200Response([void updates(RpIdentitiesRemove200ResponseBuilder b)]) = _$RpIdentitiesRemove200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RpIdentitiesRemove200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RpIdentitiesRemove200Response> get serializer => _$RpIdentitiesRemove200ResponseSerializer();
}

class _$RpIdentitiesRemove200ResponseSerializer implements PrimitiveSerializer<RpIdentitiesRemove200Response> {
  @override
  final Iterable<Type> types = const [RpIdentitiesRemove200Response, _$RpIdentitiesRemove200Response];

  @override
  final String wireName = r'RpIdentitiesRemove200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RpIdentitiesRemove200Response object, {
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
    RpIdentitiesRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RpIdentitiesRemove200ResponseBuilder result,
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
  RpIdentitiesRemove200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RpIdentitiesRemove200ResponseBuilder();
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

class RpIdentitiesRemove200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const RpIdentitiesRemove200ResponseCodeEnum number0 = _$rpIdentitiesRemove200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const RpIdentitiesRemove200ResponseCodeEnum unknownDefaultOpenApi = _$rpIdentitiesRemove200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<RpIdentitiesRemove200ResponseCodeEnum> get serializer => _$rpIdentitiesRemove200ResponseCodeEnumSerializer;

  const RpIdentitiesRemove200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<RpIdentitiesRemove200ResponseCodeEnum> get values => _$rpIdentitiesRemove200ResponseCodeEnumValues;
  static RpIdentitiesRemove200ResponseCodeEnum valueOf(String name) => _$rpIdentitiesRemove200ResponseCodeEnumValueOf(name);
}
