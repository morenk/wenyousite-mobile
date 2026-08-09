//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/moment_detail_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_detail200_response.g.dart';

/// MomentsDetail200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsDetail200Response implements ApiSuccessEnvelope, Built<MomentsDetail200Response, MomentsDetail200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MomentDetailResponseDto get data;

  MomentsDetail200Response._();

  factory MomentsDetail200Response([void updates(MomentsDetail200ResponseBuilder b)]) = _$MomentsDetail200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsDetail200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsDetail200Response> get serializer => _$MomentsDetail200ResponseSerializer();
}

class _$MomentsDetail200ResponseSerializer implements PrimitiveSerializer<MomentsDetail200Response> {
  @override
  final Iterable<Type> types = const [MomentsDetail200Response, _$MomentsDetail200Response];

  @override
  final String wireName = r'MomentsDetail200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsDetail200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MomentDetailResponseDto),
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
    MomentsDetail200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsDetail200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MomentDetailResponseDto),
          ) as MomentDetailResponseDto;
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
  MomentsDetail200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsDetail200ResponseBuilder();
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

class MomentsDetail200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsDetail200ResponseCodeEnum number0 = _$momentsDetail200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsDetail200ResponseCodeEnum unknownDefaultOpenApi = _$momentsDetail200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsDetail200ResponseCodeEnum> get serializer => _$momentsDetail200ResponseCodeEnumSerializer;

  const MomentsDetail200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsDetail200ResponseCodeEnum> get values => _$momentsDetail200ResponseCodeEnumValues;
  static MomentsDetail200ResponseCodeEnum valueOf(String name) => _$momentsDetail200ResponseCodeEnumValueOf(name);
}
