//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/rp_identity_collection_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rp_identities_list200_response.g.dart';

/// RpIdentitiesList200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class RpIdentitiesList200Response implements ApiSuccessEnvelope, Built<RpIdentitiesList200Response, RpIdentitiesList200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  RpIdentityCollectionDto get data;

  RpIdentitiesList200Response._();

  factory RpIdentitiesList200Response([void updates(RpIdentitiesList200ResponseBuilder b)]) = _$RpIdentitiesList200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RpIdentitiesList200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RpIdentitiesList200Response> get serializer => _$RpIdentitiesList200ResponseSerializer();
}

class _$RpIdentitiesList200ResponseSerializer implements PrimitiveSerializer<RpIdentitiesList200Response> {
  @override
  final Iterable<Type> types = const [RpIdentitiesList200Response, _$RpIdentitiesList200Response];

  @override
  final String wireName = r'RpIdentitiesList200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RpIdentitiesList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(RpIdentityCollectionDto),
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
    RpIdentitiesList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RpIdentitiesList200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RpIdentityCollectionDto),
          ) as RpIdentityCollectionDto;
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
  RpIdentitiesList200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RpIdentitiesList200ResponseBuilder();
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

class RpIdentitiesList200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const RpIdentitiesList200ResponseCodeEnum number0 = _$rpIdentitiesList200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const RpIdentitiesList200ResponseCodeEnum unknownDefaultOpenApi = _$rpIdentitiesList200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<RpIdentitiesList200ResponseCodeEnum> get serializer => _$rpIdentitiesList200ResponseCodeEnumSerializer;

  const RpIdentitiesList200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<RpIdentitiesList200ResponseCodeEnum> get values => _$rpIdentitiesList200ResponseCodeEnumValues;
  static RpIdentitiesList200ResponseCodeEnum valueOf(String name) => _$rpIdentitiesList200ResponseCodeEnumValueOf(name);
}
