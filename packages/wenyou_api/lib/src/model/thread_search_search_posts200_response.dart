//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/search_post_response_dto.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_search_search_posts200_response.g.dart';

/// ThreadSearchSearchPosts200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class ThreadSearchSearchPosts200Response implements ApiPaginatedSuccessEnvelope, Built<ThreadSearchSearchPosts200Response, ThreadSearchSearchPosts200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<SearchPostResponseDto> get data;

  ThreadSearchSearchPosts200Response._();

  factory ThreadSearchSearchPosts200Response([void updates(ThreadSearchSearchPosts200ResponseBuilder b)]) = _$ThreadSearchSearchPosts200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadSearchSearchPosts200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadSearchSearchPosts200Response> get serializer => _$ThreadSearchSearchPosts200ResponseSerializer();
}

class _$ThreadSearchSearchPosts200ResponseSerializer implements PrimitiveSerializer<ThreadSearchSearchPosts200Response> {
  @override
  final Iterable<Type> types = const [ThreadSearchSearchPosts200Response, _$ThreadSearchSearchPosts200Response];

  @override
  final String wireName = r'ThreadSearchSearchPosts200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadSearchSearchPosts200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
    );
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(SearchPostResponseDto)]),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(ApiPaginationMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadSearchSearchPosts200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadSearchSearchPosts200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
          ) as ApiSuccessEnvelopeCodeEnum;
          result.code = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SearchPostResponseDto)]),
          ) as BuiltList<SearchPostResponseDto>;
          result.data.replace(valueDes);
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiPaginationMeta),
          ) as ApiPaginationMeta;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadSearchSearchPosts200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadSearchSearchPosts200ResponseBuilder();
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

class ThreadSearchSearchPosts200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadSearchSearchPosts200ResponseCodeEnum number0 = _$threadSearchSearchPosts200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadSearchSearchPosts200ResponseCodeEnum unknownDefaultOpenApi = _$threadSearchSearchPosts200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadSearchSearchPosts200ResponseCodeEnum> get serializer => _$threadSearchSearchPosts200ResponseCodeEnumSerializer;

  const ThreadSearchSearchPosts200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadSearchSearchPosts200ResponseCodeEnum> get values => _$threadSearchSearchPosts200ResponseCodeEnumValues;
  static ThreadSearchSearchPosts200ResponseCodeEnum valueOf(String name) => _$threadSearchSearchPosts200ResponseCodeEnumValueOf(name);
}
