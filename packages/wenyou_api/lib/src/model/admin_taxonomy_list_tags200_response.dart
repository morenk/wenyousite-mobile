//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/tag_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_taxonomy_list_tags200_response.g.dart';

/// AdminTaxonomyListTags200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTaxonomyListTags200Response implements ApiSuccessEnvelope, Built<AdminTaxonomyListTags200Response, AdminTaxonomyListTags200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<TagResponseDto> get data;

  AdminTaxonomyListTags200Response._();

  factory AdminTaxonomyListTags200Response([void updates(AdminTaxonomyListTags200ResponseBuilder b)]) = _$AdminTaxonomyListTags200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTaxonomyListTags200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTaxonomyListTags200Response> get serializer => _$AdminTaxonomyListTags200ResponseSerializer();
}

class _$AdminTaxonomyListTags200ResponseSerializer implements PrimitiveSerializer<AdminTaxonomyListTags200Response> {
  @override
  final Iterable<Type> types = const [AdminTaxonomyListTags200Response, _$AdminTaxonomyListTags200Response];

  @override
  final String wireName = r'AdminTaxonomyListTags200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTaxonomyListTags200Response object, {
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
    AdminTaxonomyListTags200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTaxonomyListTags200ResponseBuilder result,
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
  AdminTaxonomyListTags200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTaxonomyListTags200ResponseBuilder();
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

class AdminTaxonomyListTags200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTaxonomyListTags200ResponseCodeEnum number0 = _$adminTaxonomyListTags200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTaxonomyListTags200ResponseCodeEnum unknownDefaultOpenApi = _$adminTaxonomyListTags200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTaxonomyListTags200ResponseCodeEnum> get serializer => _$adminTaxonomyListTags200ResponseCodeEnumSerializer;

  const AdminTaxonomyListTags200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTaxonomyListTags200ResponseCodeEnum> get values => _$adminTaxonomyListTags200ResponseCodeEnumValues;
  static AdminTaxonomyListTags200ResponseCodeEnum valueOf(String name) => _$adminTaxonomyListTags200ResponseCodeEnumValueOf(name);
}
