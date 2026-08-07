//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/subthread_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subthreads_find_all200_response.g.dart';

/// SubthreadsFindAll200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class SubthreadsFindAll200Response implements ApiSuccessEnvelope, Built<SubthreadsFindAll200Response, SubthreadsFindAll200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<SubthreadResponseDto> get data;

  SubthreadsFindAll200Response._();

  factory SubthreadsFindAll200Response([void updates(SubthreadsFindAll200ResponseBuilder b)]) = _$SubthreadsFindAll200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubthreadsFindAll200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubthreadsFindAll200Response> get serializer => _$SubthreadsFindAll200ResponseSerializer();
}

class _$SubthreadsFindAll200ResponseSerializer implements PrimitiveSerializer<SubthreadsFindAll200Response> {
  @override
  final Iterable<Type> types = const [SubthreadsFindAll200Response, _$SubthreadsFindAll200Response];

  @override
  final String wireName = r'SubthreadsFindAll200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubthreadsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(SubthreadResponseDto)]),
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
    SubthreadsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubthreadsFindAll200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SubthreadResponseDto)]),
          ) as BuiltList<SubthreadResponseDto>;
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
  SubthreadsFindAll200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubthreadsFindAll200ResponseBuilder();
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

class SubthreadsFindAll200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SubthreadsFindAll200ResponseCodeEnum number0 = _$subthreadsFindAll200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SubthreadsFindAll200ResponseCodeEnum unknownDefaultOpenApi = _$subthreadsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SubthreadsFindAll200ResponseCodeEnum> get serializer => _$subthreadsFindAll200ResponseCodeEnumSerializer;

  const SubthreadsFindAll200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SubthreadsFindAll200ResponseCodeEnum> get values => _$subthreadsFindAll200ResponseCodeEnumValues;
  static SubthreadsFindAll200ResponseCodeEnum valueOf(String name) => _$subthreadsFindAll200ResponseCodeEnumValueOf(name);
}
