//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/moment_detail_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_update200_response.g.dart';

/// MomentsUpdate200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsUpdate200Response implements ApiSuccessEnvelope, Built<MomentsUpdate200Response, MomentsUpdate200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MomentDetailResponseDto get data;

  MomentsUpdate200Response._();

  factory MomentsUpdate200Response([void updates(MomentsUpdate200ResponseBuilder b)]) = _$MomentsUpdate200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsUpdate200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsUpdate200Response> get serializer => _$MomentsUpdate200ResponseSerializer();
}

class _$MomentsUpdate200ResponseSerializer implements PrimitiveSerializer<MomentsUpdate200Response> {
  @override
  final Iterable<Type> types = const [MomentsUpdate200Response, _$MomentsUpdate200Response];

  @override
  final String wireName = r'MomentsUpdate200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsUpdate200Response object, {
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
    MomentsUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsUpdate200ResponseBuilder result,
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
  MomentsUpdate200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsUpdate200ResponseBuilder();
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

class MomentsUpdate200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsUpdate200ResponseCodeEnum number0 = _$momentsUpdate200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsUpdate200ResponseCodeEnum unknownDefaultOpenApi = _$momentsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsUpdate200ResponseCodeEnum> get serializer => _$momentsUpdate200ResponseCodeEnumSerializer;

  const MomentsUpdate200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsUpdate200ResponseCodeEnum> get values => _$momentsUpdate200ResponseCodeEnumValues;
  static MomentsUpdate200ResponseCodeEnum valueOf(String name) => _$momentsUpdate200ResponseCodeEnumValueOf(name);
}
