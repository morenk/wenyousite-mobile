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

part 'search_search_posts200_response.g.dart';

/// SearchSearchPosts200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class SearchSearchPosts200Response implements ApiPaginatedSuccessEnvelope, Built<SearchSearchPosts200Response, SearchSearchPosts200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<SearchPostResponseDto> get data;

  SearchSearchPosts200Response._();

  factory SearchSearchPosts200Response([void updates(SearchSearchPosts200ResponseBuilder b)]) = _$SearchSearchPosts200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchSearchPosts200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchSearchPosts200Response> get serializer => _$SearchSearchPosts200ResponseSerializer();
}

class _$SearchSearchPosts200ResponseSerializer implements PrimitiveSerializer<SearchSearchPosts200Response> {
  @override
  final Iterable<Type> types = const [SearchSearchPosts200Response, _$SearchSearchPosts200Response];

  @override
  final String wireName = r'SearchSearchPosts200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchSearchPosts200Response object, {
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
    SearchSearchPosts200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchSearchPosts200ResponseBuilder result,
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
  SearchSearchPosts200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchSearchPosts200ResponseBuilder();
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

class SearchSearchPosts200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SearchSearchPosts200ResponseCodeEnum number0 = _$searchSearchPosts200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SearchSearchPosts200ResponseCodeEnum unknownDefaultOpenApi = _$searchSearchPosts200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SearchSearchPosts200ResponseCodeEnum> get serializer => _$searchSearchPosts200ResponseCodeEnumSerializer;

  const SearchSearchPosts200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SearchSearchPosts200ResponseCodeEnum> get values => _$searchSearchPosts200ResponseCodeEnumValues;
  static SearchSearchPosts200ResponseCodeEnum valueOf(String name) => _$searchSearchPosts200ResponseCodeEnumValueOf(name);
}
