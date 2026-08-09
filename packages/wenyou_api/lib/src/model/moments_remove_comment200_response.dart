//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/moment_delete_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_remove_comment200_response.g.dart';

/// MomentsRemoveComment200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsRemoveComment200Response implements ApiSuccessEnvelope, Built<MomentsRemoveComment200Response, MomentsRemoveComment200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MomentDeleteResponseDto get data;

  MomentsRemoveComment200Response._();

  factory MomentsRemoveComment200Response([void updates(MomentsRemoveComment200ResponseBuilder b)]) = _$MomentsRemoveComment200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsRemoveComment200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsRemoveComment200Response> get serializer => _$MomentsRemoveComment200ResponseSerializer();
}

class _$MomentsRemoveComment200ResponseSerializer implements PrimitiveSerializer<MomentsRemoveComment200Response> {
  @override
  final Iterable<Type> types = const [MomentsRemoveComment200Response, _$MomentsRemoveComment200Response];

  @override
  final String wireName = r'MomentsRemoveComment200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsRemoveComment200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MomentDeleteResponseDto),
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
    MomentsRemoveComment200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsRemoveComment200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MomentDeleteResponseDto),
          ) as MomentDeleteResponseDto;
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
  MomentsRemoveComment200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsRemoveComment200ResponseBuilder();
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

class MomentsRemoveComment200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsRemoveComment200ResponseCodeEnum number0 = _$momentsRemoveComment200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsRemoveComment200ResponseCodeEnum unknownDefaultOpenApi = _$momentsRemoveComment200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsRemoveComment200ResponseCodeEnum> get serializer => _$momentsRemoveComment200ResponseCodeEnumSerializer;

  const MomentsRemoveComment200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsRemoveComment200ResponseCodeEnum> get values => _$momentsRemoveComment200ResponseCodeEnumValues;
  static MomentsRemoveComment200ResponseCodeEnum valueOf(String name) => _$momentsRemoveComment200ResponseCodeEnumValueOf(name);
}
