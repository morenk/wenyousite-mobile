//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/rp_identity_state_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rp_identities_create201_response.g.dart';

/// RpIdentitiesCreate201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class RpIdentitiesCreate201Response implements ApiSuccessEnvelope, Built<RpIdentitiesCreate201Response, RpIdentitiesCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  RpIdentityStateDto get data;

  RpIdentitiesCreate201Response._();

  factory RpIdentitiesCreate201Response([void updates(RpIdentitiesCreate201ResponseBuilder b)]) = _$RpIdentitiesCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RpIdentitiesCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RpIdentitiesCreate201Response> get serializer => _$RpIdentitiesCreate201ResponseSerializer();
}

class _$RpIdentitiesCreate201ResponseSerializer implements PrimitiveSerializer<RpIdentitiesCreate201Response> {
  @override
  final Iterable<Type> types = const [RpIdentitiesCreate201Response, _$RpIdentitiesCreate201Response];

  @override
  final String wireName = r'RpIdentitiesCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RpIdentitiesCreate201Response object, {
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
    RpIdentitiesCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RpIdentitiesCreate201ResponseBuilder result,
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
  RpIdentitiesCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RpIdentitiesCreate201ResponseBuilder();
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

class RpIdentitiesCreate201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const RpIdentitiesCreate201ResponseCodeEnum number0 = _$rpIdentitiesCreate201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const RpIdentitiesCreate201ResponseCodeEnum unknownDefaultOpenApi = _$rpIdentitiesCreate201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<RpIdentitiesCreate201ResponseCodeEnum> get serializer => _$rpIdentitiesCreate201ResponseCodeEnumSerializer;

  const RpIdentitiesCreate201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<RpIdentitiesCreate201ResponseCodeEnum> get values => _$rpIdentitiesCreate201ResponseCodeEnumValues;
  static RpIdentitiesCreate201ResponseCodeEnum valueOf(String name) => _$rpIdentitiesCreate201ResponseCodeEnumValueOf(name);
}
