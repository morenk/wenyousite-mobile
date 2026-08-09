//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/moment_delete_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_remove200_response.g.dart';

/// MomentsRemove200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsRemove200Response implements ApiSuccessEnvelope, Built<MomentsRemove200Response, MomentsRemove200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MomentDeleteResponseDto get data;

  MomentsRemove200Response._();

  factory MomentsRemove200Response([void updates(MomentsRemove200ResponseBuilder b)]) = _$MomentsRemove200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsRemove200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsRemove200Response> get serializer => _$MomentsRemove200ResponseSerializer();
}

class _$MomentsRemove200ResponseSerializer implements PrimitiveSerializer<MomentsRemove200Response> {
  @override
  final Iterable<Type> types = const [MomentsRemove200Response, _$MomentsRemove200Response];

  @override
  final String wireName = r'MomentsRemove200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsRemove200Response object, {
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
    MomentsRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsRemove200ResponseBuilder result,
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
  MomentsRemove200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsRemove200ResponseBuilder();
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

class MomentsRemove200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsRemove200ResponseCodeEnum number0 = _$momentsRemove200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsRemove200ResponseCodeEnum unknownDefaultOpenApi = _$momentsRemove200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsRemove200ResponseCodeEnum> get serializer => _$momentsRemove200ResponseCodeEnumSerializer;

  const MomentsRemove200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsRemove200ResponseCodeEnum> get values => _$momentsRemove200ResponseCodeEnumValues;
  static MomentsRemove200ResponseCodeEnum valueOf(String name) => _$momentsRemove200ResponseCodeEnumValueOf(name);
}
