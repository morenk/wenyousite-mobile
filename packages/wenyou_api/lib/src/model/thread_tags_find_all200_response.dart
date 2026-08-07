//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_tag_relation_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_tags_find_all200_response.g.dart';

/// ThreadTagsFindAll200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadTagsFindAll200Response implements ApiSuccessEnvelope, Built<ThreadTagsFindAll200Response, ThreadTagsFindAll200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ThreadTagRelationResponseDto> get data;

  ThreadTagsFindAll200Response._();

  factory ThreadTagsFindAll200Response([void updates(ThreadTagsFindAll200ResponseBuilder b)]) = _$ThreadTagsFindAll200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadTagsFindAll200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadTagsFindAll200Response> get serializer => _$ThreadTagsFindAll200ResponseSerializer();
}

class _$ThreadTagsFindAll200ResponseSerializer implements PrimitiveSerializer<ThreadTagsFindAll200Response> {
  @override
  final Iterable<Type> types = const [ThreadTagsFindAll200Response, _$ThreadTagsFindAll200Response];

  @override
  final String wireName = r'ThreadTagsFindAll200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadTagsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(ThreadTagRelationResponseDto)]),
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
    ThreadTagsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadTagsFindAll200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ThreadTagRelationResponseDto)]),
          ) as BuiltList<ThreadTagRelationResponseDto>;
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
  ThreadTagsFindAll200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadTagsFindAll200ResponseBuilder();
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

class ThreadTagsFindAll200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadTagsFindAll200ResponseCodeEnum number0 = _$threadTagsFindAll200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadTagsFindAll200ResponseCodeEnum unknownDefaultOpenApi = _$threadTagsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadTagsFindAll200ResponseCodeEnum> get serializer => _$threadTagsFindAll200ResponseCodeEnumSerializer;

  const ThreadTagsFindAll200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadTagsFindAll200ResponseCodeEnum> get values => _$threadTagsFindAll200ResponseCodeEnumValues;
  static ThreadTagsFindAll200ResponseCodeEnum valueOf(String name) => _$threadTagsFindAll200ResponseCodeEnumValueOf(name);
}
