//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/tag_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tags_create200_response.g.dart';

/// TagsCreate200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class TagsCreate200Response implements ApiSuccessEnvelope, Built<TagsCreate200Response, TagsCreate200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  TagResponseDto get data;

  TagsCreate200Response._();

  factory TagsCreate200Response([void updates(TagsCreate200ResponseBuilder b)]) = _$TagsCreate200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TagsCreate200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TagsCreate200Response> get serializer => _$TagsCreate200ResponseSerializer();
}

class _$TagsCreate200ResponseSerializer implements PrimitiveSerializer<TagsCreate200Response> {
  @override
  final Iterable<Type> types = const [TagsCreate200Response, _$TagsCreate200Response];

  @override
  final String wireName = r'TagsCreate200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TagsCreate200Response object, {
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
    TagsCreate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TagsCreate200ResponseBuilder result,
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
  TagsCreate200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TagsCreate200ResponseBuilder();
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

class TagsCreate200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const TagsCreate200ResponseCodeEnum number0 = _$tagsCreate200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const TagsCreate200ResponseCodeEnum unknownDefaultOpenApi = _$tagsCreate200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<TagsCreate200ResponseCodeEnum> get serializer => _$tagsCreate200ResponseCodeEnumSerializer;

  const TagsCreate200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<TagsCreate200ResponseCodeEnum> get values => _$tagsCreate200ResponseCodeEnumValues;
  static TagsCreate200ResponseCodeEnum valueOf(String name) => _$tagsCreate200ResponseCodeEnumValueOf(name);
}
