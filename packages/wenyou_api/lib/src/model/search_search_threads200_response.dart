//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/search_thread_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_search_threads200_response.g.dart';

/// SearchSearchThreads200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class SearchSearchThreads200Response implements ApiPaginatedSuccessEnvelope, Built<SearchSearchThreads200Response, SearchSearchThreads200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<SearchThreadResponseDto> get data;

  SearchSearchThreads200Response._();

  factory SearchSearchThreads200Response([void updates(SearchSearchThreads200ResponseBuilder b)]) = _$SearchSearchThreads200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchSearchThreads200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchSearchThreads200Response> get serializer => _$SearchSearchThreads200ResponseSerializer();
}

class _$SearchSearchThreads200ResponseSerializer implements PrimitiveSerializer<SearchSearchThreads200Response> {
  @override
  final Iterable<Type> types = const [SearchSearchThreads200Response, _$SearchSearchThreads200Response];

  @override
  final String wireName = r'SearchSearchThreads200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchSearchThreads200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(SearchThreadResponseDto)]),
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
    SearchSearchThreads200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchSearchThreads200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(SearchThreadResponseDto)]),
          ) as BuiltList<SearchThreadResponseDto>;
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
  SearchSearchThreads200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchSearchThreads200ResponseBuilder();
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

class SearchSearchThreads200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SearchSearchThreads200ResponseCodeEnum number0 = _$searchSearchThreads200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SearchSearchThreads200ResponseCodeEnum unknownDefaultOpenApi = _$searchSearchThreads200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SearchSearchThreads200ResponseCodeEnum> get serializer => _$searchSearchThreads200ResponseCodeEnumSerializer;

  const SearchSearchThreads200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SearchSearchThreads200ResponseCodeEnum> get values => _$searchSearchThreads200ResponseCodeEnumValues;
  static SearchSearchThreads200ResponseCodeEnum valueOf(String name) => _$searchSearchThreads200ResponseCodeEnumValueOf(name);
}
