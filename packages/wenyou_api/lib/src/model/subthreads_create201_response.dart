//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/subthread_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subthreads_create201_response.g.dart';

/// SubthreadsCreate201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class SubthreadsCreate201Response implements ApiSuccessEnvelope, Built<SubthreadsCreate201Response, SubthreadsCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  SubthreadResponseDto get data;

  SubthreadsCreate201Response._();

  factory SubthreadsCreate201Response([void updates(SubthreadsCreate201ResponseBuilder b)]) = _$SubthreadsCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubthreadsCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubthreadsCreate201Response> get serializer => _$SubthreadsCreate201ResponseSerializer();
}

class _$SubthreadsCreate201ResponseSerializer implements PrimitiveSerializer<SubthreadsCreate201Response> {
  @override
  final Iterable<Type> types = const [SubthreadsCreate201Response, _$SubthreadsCreate201Response];

  @override
  final String wireName = r'SubthreadsCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubthreadsCreate201Response object, {
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
    SubthreadsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubthreadsCreate201ResponseBuilder result,
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
  SubthreadsCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubthreadsCreate201ResponseBuilder();
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

class SubthreadsCreate201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SubthreadsCreate201ResponseCodeEnum number0 = _$subthreadsCreate201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SubthreadsCreate201ResponseCodeEnum unknownDefaultOpenApi = _$subthreadsCreate201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SubthreadsCreate201ResponseCodeEnum> get serializer => _$subthreadsCreate201ResponseCodeEnumSerializer;

  const SubthreadsCreate201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SubthreadsCreate201ResponseCodeEnum> get values => _$subthreadsCreate201ResponseCodeEnumValues;
  static SubthreadsCreate201ResponseCodeEnum valueOf(String name) => _$subthreadsCreate201ResponseCodeEnumValueOf(name);
}
