//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_category_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_taxonomy_list_categories200_response.g.dart';

/// AdminTaxonomyListCategories200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTaxonomyListCategories200Response implements ApiSuccessEnvelope, Built<AdminTaxonomyListCategories200Response, AdminTaxonomyListCategories200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ThreadCategoryResponseDto> get data;

  AdminTaxonomyListCategories200Response._();

  factory AdminTaxonomyListCategories200Response([void updates(AdminTaxonomyListCategories200ResponseBuilder b)]) = _$AdminTaxonomyListCategories200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTaxonomyListCategories200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTaxonomyListCategories200Response> get serializer => _$AdminTaxonomyListCategories200ResponseSerializer();
}

class _$AdminTaxonomyListCategories200ResponseSerializer implements PrimitiveSerializer<AdminTaxonomyListCategories200Response> {
  @override
  final Iterable<Type> types = const [AdminTaxonomyListCategories200Response, _$AdminTaxonomyListCategories200Response];

  @override
  final String wireName = r'AdminTaxonomyListCategories200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTaxonomyListCategories200Response object, {
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
    AdminTaxonomyListCategories200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTaxonomyListCategories200ResponseBuilder result,
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
  AdminTaxonomyListCategories200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTaxonomyListCategories200ResponseBuilder();
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

class AdminTaxonomyListCategories200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTaxonomyListCategories200ResponseCodeEnum number0 = _$adminTaxonomyListCategories200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTaxonomyListCategories200ResponseCodeEnum unknownDefaultOpenApi = _$adminTaxonomyListCategories200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTaxonomyListCategories200ResponseCodeEnum> get serializer => _$adminTaxonomyListCategories200ResponseCodeEnumSerializer;

  const AdminTaxonomyListCategories200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTaxonomyListCategories200ResponseCodeEnum> get values => _$adminTaxonomyListCategories200ResponseCodeEnumValues;
  static AdminTaxonomyListCategories200ResponseCodeEnum valueOf(String name) => _$adminTaxonomyListCategories200ResponseCodeEnumValueOf(name);
}
