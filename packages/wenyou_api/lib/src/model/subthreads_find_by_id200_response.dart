//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/subthread_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subthreads_find_by_id200_response.g.dart';

/// SubthreadsFindById200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class SubthreadsFindById200Response implements ApiSuccessEnvelope, Built<SubthreadsFindById200Response, SubthreadsFindById200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  SubthreadResponseDto get data;

  SubthreadsFindById200Response._();

  factory SubthreadsFindById200Response([void updates(SubthreadsFindById200ResponseBuilder b)]) = _$SubthreadsFindById200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubthreadsFindById200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubthreadsFindById200Response> get serializer => _$SubthreadsFindById200ResponseSerializer();
}

class _$SubthreadsFindById200ResponseSerializer implements PrimitiveSerializer<SubthreadsFindById200Response> {
  @override
  final Iterable<Type> types = const [SubthreadsFindById200Response, _$SubthreadsFindById200Response];

  @override
  final String wireName = r'SubthreadsFindById200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubthreadsFindById200Response object, {
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
    SubthreadsFindById200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubthreadsFindById200ResponseBuilder result,
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
  SubthreadsFindById200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubthreadsFindById200ResponseBuilder();
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

class SubthreadsFindById200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SubthreadsFindById200ResponseCodeEnum number0 = _$subthreadsFindById200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SubthreadsFindById200ResponseCodeEnum unknownDefaultOpenApi = _$subthreadsFindById200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SubthreadsFindById200ResponseCodeEnum> get serializer => _$subthreadsFindById200ResponseCodeEnumSerializer;

  const SubthreadsFindById200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SubthreadsFindById200ResponseCodeEnum> get values => _$subthreadsFindById200ResponseCodeEnumValues;
  static SubthreadsFindById200ResponseCodeEnum valueOf(String name) => _$subthreadsFindById200ResponseCodeEnumValueOf(name);
}
