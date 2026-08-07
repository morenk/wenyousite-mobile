//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/subthread_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subthreads_update200_response.g.dart';

/// SubthreadsUpdate200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class SubthreadsUpdate200Response implements ApiSuccessEnvelope, Built<SubthreadsUpdate200Response, SubthreadsUpdate200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  SubthreadResponseDto get data;

  SubthreadsUpdate200Response._();

  factory SubthreadsUpdate200Response([void updates(SubthreadsUpdate200ResponseBuilder b)]) = _$SubthreadsUpdate200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubthreadsUpdate200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubthreadsUpdate200Response> get serializer => _$SubthreadsUpdate200ResponseSerializer();
}

class _$SubthreadsUpdate200ResponseSerializer implements PrimitiveSerializer<SubthreadsUpdate200Response> {
  @override
  final Iterable<Type> types = const [SubthreadsUpdate200Response, _$SubthreadsUpdate200Response];

  @override
  final String wireName = r'SubthreadsUpdate200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubthreadsUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(SubthreadResponseDto),
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
    SubthreadsUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubthreadsUpdate200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SubthreadResponseDto),
          ) as SubthreadResponseDto;
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
  SubthreadsUpdate200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubthreadsUpdate200ResponseBuilder();
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

class SubthreadsUpdate200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SubthreadsUpdate200ResponseCodeEnum number0 = _$subthreadsUpdate200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SubthreadsUpdate200ResponseCodeEnum unknownDefaultOpenApi = _$subthreadsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SubthreadsUpdate200ResponseCodeEnum> get serializer => _$subthreadsUpdate200ResponseCodeEnumSerializer;

  const SubthreadsUpdate200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SubthreadsUpdate200ResponseCodeEnum> get values => _$subthreadsUpdate200ResponseCodeEnumValues;
  static SubthreadsUpdate200ResponseCodeEnum valueOf(String name) => _$subthreadsUpdate200ResponseCodeEnumValueOf(name);
}
