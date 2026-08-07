//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subthreads_remove200_response.g.dart';

/// SubthreadsRemove200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class SubthreadsRemove200Response implements ApiSuccessEnvelope, Built<SubthreadsRemove200Response, SubthreadsRemove200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  SubthreadsRemove200Response._();

  factory SubthreadsRemove200Response([void updates(SubthreadsRemove200ResponseBuilder b)]) = _$SubthreadsRemove200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubthreadsRemove200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubthreadsRemove200Response> get serializer => _$SubthreadsRemove200ResponseSerializer();
}

class _$SubthreadsRemove200ResponseSerializer implements PrimitiveSerializer<SubthreadsRemove200Response> {
  @override
  final Iterable<Type> types = const [SubthreadsRemove200Response, _$SubthreadsRemove200Response];

  @override
  final String wireName = r'SubthreadsRemove200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubthreadsRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MessageResponseDto),
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
    SubthreadsRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubthreadsRemove200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MessageResponseDto),
          ) as MessageResponseDto;
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
  SubthreadsRemove200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubthreadsRemove200ResponseBuilder();
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

class SubthreadsRemove200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SubthreadsRemove200ResponseCodeEnum number0 = _$subthreadsRemove200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SubthreadsRemove200ResponseCodeEnum unknownDefaultOpenApi = _$subthreadsRemove200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SubthreadsRemove200ResponseCodeEnum> get serializer => _$subthreadsRemove200ResponseCodeEnumSerializer;

  const SubthreadsRemove200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SubthreadsRemove200ResponseCodeEnum> get values => _$subthreadsRemove200ResponseCodeEnumValues;
  static SubthreadsRemove200ResponseCodeEnum valueOf(String name) => _$subthreadsRemove200ResponseCodeEnumValueOf(name);
}
