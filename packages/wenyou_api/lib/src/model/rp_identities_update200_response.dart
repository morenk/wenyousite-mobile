//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/rp_identity_state_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rp_identities_update200_response.g.dart';

/// RpIdentitiesUpdate200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class RpIdentitiesUpdate200Response implements ApiSuccessEnvelope, Built<RpIdentitiesUpdate200Response, RpIdentitiesUpdate200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  RpIdentityStateDto get data;

  RpIdentitiesUpdate200Response._();

  factory RpIdentitiesUpdate200Response([void updates(RpIdentitiesUpdate200ResponseBuilder b)]) = _$RpIdentitiesUpdate200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RpIdentitiesUpdate200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RpIdentitiesUpdate200Response> get serializer => _$RpIdentitiesUpdate200ResponseSerializer();
}

class _$RpIdentitiesUpdate200ResponseSerializer implements PrimitiveSerializer<RpIdentitiesUpdate200Response> {
  @override
  final Iterable<Type> types = const [RpIdentitiesUpdate200Response, _$RpIdentitiesUpdate200Response];

  @override
  final String wireName = r'RpIdentitiesUpdate200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RpIdentitiesUpdate200Response object, {
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
    RpIdentitiesUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RpIdentitiesUpdate200ResponseBuilder result,
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
  RpIdentitiesUpdate200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RpIdentitiesUpdate200ResponseBuilder();
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

class RpIdentitiesUpdate200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const RpIdentitiesUpdate200ResponseCodeEnum number0 = _$rpIdentitiesUpdate200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const RpIdentitiesUpdate200ResponseCodeEnum unknownDefaultOpenApi = _$rpIdentitiesUpdate200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<RpIdentitiesUpdate200ResponseCodeEnum> get serializer => _$rpIdentitiesUpdate200ResponseCodeEnumSerializer;

  const RpIdentitiesUpdate200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<RpIdentitiesUpdate200ResponseCodeEnum> get values => _$rpIdentitiesUpdate200ResponseCodeEnumValues;
  static RpIdentitiesUpdate200ResponseCodeEnum valueOf(String name) => _$rpIdentitiesUpdate200ResponseCodeEnumValueOf(name);
}
