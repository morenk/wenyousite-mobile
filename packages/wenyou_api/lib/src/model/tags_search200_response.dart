//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/tag_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tags_search200_response.g.dart';

/// TagsSearch200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class TagsSearch200Response implements ApiSuccessEnvelope, Built<TagsSearch200Response, TagsSearch200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<TagResponseDto> get data;

  TagsSearch200Response._();

  factory TagsSearch200Response([void updates(TagsSearch200ResponseBuilder b)]) = _$TagsSearch200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TagsSearch200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TagsSearch200Response> get serializer => _$TagsSearch200ResponseSerializer();
}

class _$TagsSearch200ResponseSerializer implements PrimitiveSerializer<TagsSearch200Response> {
  @override
  final Iterable<Type> types = const [TagsSearch200Response, _$TagsSearch200Response];

  @override
  final String wireName = r'TagsSearch200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TagsSearch200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(TagResponseDto)]),
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
    TagsSearch200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TagsSearch200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TagResponseDto)]),
          ) as BuiltList<TagResponseDto>;
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
  TagsSearch200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TagsSearch200ResponseBuilder();
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

class TagsSearch200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const TagsSearch200ResponseCodeEnum number0 = _$tagsSearch200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const TagsSearch200ResponseCodeEnum unknownDefaultOpenApi = _$tagsSearch200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<TagsSearch200ResponseCodeEnum> get serializer => _$tagsSearch200ResponseCodeEnumSerializer;

  const TagsSearch200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<TagsSearch200ResponseCodeEnum> get values => _$tagsSearch200ResponseCodeEnumValues;
  static TagsSearch200ResponseCodeEnum valueOf(String name) => _$tagsSearch200ResponseCodeEnumValueOf(name);
}
