//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:wenyou_api/src/model/moment_search_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_search_moments200_response.g.dart';

/// SearchSearchMoments200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class SearchSearchMoments200Response implements ApiPaginatedSuccessEnvelope, Built<SearchSearchMoments200Response, SearchSearchMoments200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<MomentSearchResponseDto> get data;

  SearchSearchMoments200Response._();

  factory SearchSearchMoments200Response([void updates(SearchSearchMoments200ResponseBuilder b)]) = _$SearchSearchMoments200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchSearchMoments200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchSearchMoments200Response> get serializer => _$SearchSearchMoments200ResponseSerializer();
}

class _$SearchSearchMoments200ResponseSerializer implements PrimitiveSerializer<SearchSearchMoments200Response> {
  @override
  final Iterable<Type> types = const [SearchSearchMoments200Response, _$SearchSearchMoments200Response];

  @override
  final String wireName = r'SearchSearchMoments200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchSearchMoments200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(MomentSearchResponseDto)]),
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
    SearchSearchMoments200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchSearchMoments200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(MomentSearchResponseDto)]),
          ) as BuiltList<MomentSearchResponseDto>;
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
  SearchSearchMoments200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchSearchMoments200ResponseBuilder();
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

class SearchSearchMoments200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SearchSearchMoments200ResponseCodeEnum number0 = _$searchSearchMoments200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SearchSearchMoments200ResponseCodeEnum unknownDefaultOpenApi = _$searchSearchMoments200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SearchSearchMoments200ResponseCodeEnum> get serializer => _$searchSearchMoments200ResponseCodeEnumSerializer;

  const SearchSearchMoments200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SearchSearchMoments200ResponseCodeEnum> get values => _$searchSearchMoments200ResponseCodeEnumValues;
  static SearchSearchMoments200ResponseCodeEnum valueOf(String name) => _$searchSearchMoments200ResponseCodeEnumValueOf(name);
}
