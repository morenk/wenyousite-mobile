//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/tag_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tags_get_by_id200_response.g.dart';

/// TagsGetById200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class TagsGetById200Response implements ApiSuccessEnvelope, Built<TagsGetById200Response, TagsGetById200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  TagResponseDto get data;

  TagsGetById200Response._();

  factory TagsGetById200Response([void updates(TagsGetById200ResponseBuilder b)]) = _$TagsGetById200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TagsGetById200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TagsGetById200Response> get serializer => _$TagsGetById200ResponseSerializer();
}

class _$TagsGetById200ResponseSerializer implements PrimitiveSerializer<TagsGetById200Response> {
  @override
  final Iterable<Type> types = const [TagsGetById200Response, _$TagsGetById200Response];

  @override
  final String wireName = r'TagsGetById200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TagsGetById200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(TagResponseDto),
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
    TagsGetById200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TagsGetById200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TagResponseDto),
          ) as TagResponseDto;
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
  TagsGetById200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TagsGetById200ResponseBuilder();
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

class TagsGetById200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const TagsGetById200ResponseCodeEnum number0 = _$tagsGetById200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const TagsGetById200ResponseCodeEnum unknownDefaultOpenApi = _$tagsGetById200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<TagsGetById200ResponseCodeEnum> get serializer => _$tagsGetById200ResponseCodeEnumSerializer;

  const TagsGetById200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<TagsGetById200ResponseCodeEnum> get values => _$tagsGetById200ResponseCodeEnumValues;
  static TagsGetById200ResponseCodeEnum valueOf(String name) => _$tagsGetById200ResponseCodeEnumValueOf(name);
}
