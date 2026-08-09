//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_category_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_categories_list200_response.g.dart';

/// ThreadCategoriesList200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadCategoriesList200Response implements ApiSuccessEnvelope, Built<ThreadCategoriesList200Response, ThreadCategoriesList200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ThreadCategoryResponseDto> get data;

  ThreadCategoriesList200Response._();

  factory ThreadCategoriesList200Response([void updates(ThreadCategoriesList200ResponseBuilder b)]) = _$ThreadCategoriesList200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadCategoriesList200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadCategoriesList200Response> get serializer => _$ThreadCategoriesList200ResponseSerializer();
}

class _$ThreadCategoriesList200ResponseSerializer implements PrimitiveSerializer<ThreadCategoriesList200Response> {
  @override
  final Iterable<Type> types = const [ThreadCategoriesList200Response, _$ThreadCategoriesList200Response];

  @override
  final String wireName = r'ThreadCategoriesList200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadCategoriesList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(ThreadCategoryResponseDto)]),
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
    ThreadCategoriesList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadCategoriesList200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ThreadCategoryResponseDto)]),
          ) as BuiltList<ThreadCategoryResponseDto>;
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
  ThreadCategoriesList200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadCategoriesList200ResponseBuilder();
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

class ThreadCategoriesList200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadCategoriesList200ResponseCodeEnum number0 = _$threadCategoriesList200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadCategoriesList200ResponseCodeEnum unknownDefaultOpenApi = _$threadCategoriesList200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadCategoriesList200ResponseCodeEnum> get serializer => _$threadCategoriesList200ResponseCodeEnumSerializer;

  const ThreadCategoriesList200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadCategoriesList200ResponseCodeEnum> get values => _$threadCategoriesList200ResponseCodeEnumValues;
  static ThreadCategoriesList200ResponseCodeEnum valueOf(String name) => _$threadCategoriesList200ResponseCodeEnumValueOf(name);
}
