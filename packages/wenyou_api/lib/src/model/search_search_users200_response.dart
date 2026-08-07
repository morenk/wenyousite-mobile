//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/search_user_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_search_users200_response.g.dart';

/// SearchSearchUsers200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class SearchSearchUsers200Response implements ApiSuccessEnvelope, Built<SearchSearchUsers200Response, SearchSearchUsers200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<SearchUserResponseDto> get data;

  SearchSearchUsers200Response._();

  factory SearchSearchUsers200Response([void updates(SearchSearchUsers200ResponseBuilder b)]) = _$SearchSearchUsers200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchSearchUsers200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchSearchUsers200Response> get serializer => _$SearchSearchUsers200ResponseSerializer();
}

class _$SearchSearchUsers200ResponseSerializer implements PrimitiveSerializer<SearchSearchUsers200Response> {
  @override
  final Iterable<Type> types = const [SearchSearchUsers200Response, _$SearchSearchUsers200Response];

  @override
  final String wireName = r'SearchSearchUsers200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchSearchUsers200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(SearchUserResponseDto)]),
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
    SearchSearchUsers200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchSearchUsers200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SearchUserResponseDto)]),
          ) as BuiltList<SearchUserResponseDto>;
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
  SearchSearchUsers200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchSearchUsers200ResponseBuilder();
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

class SearchSearchUsers200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SearchSearchUsers200ResponseCodeEnum number0 = _$searchSearchUsers200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SearchSearchUsers200ResponseCodeEnum unknownDefaultOpenApi = _$searchSearchUsers200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SearchSearchUsers200ResponseCodeEnum> get serializer => _$searchSearchUsers200ResponseCodeEnumSerializer;

  const SearchSearchUsers200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SearchSearchUsers200ResponseCodeEnum> get values => _$searchSearchUsers200ResponseCodeEnumValues;
  static SearchSearchUsers200ResponseCodeEnum valueOf(String name) => _$searchSearchUsers200ResponseCodeEnumValueOf(name);
}
