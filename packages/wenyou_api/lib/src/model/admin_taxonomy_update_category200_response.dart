//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_category_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_taxonomy_update_category200_response.g.dart';

/// AdminTaxonomyUpdateCategory200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminTaxonomyUpdateCategory200Response implements ApiSuccessEnvelope, Built<AdminTaxonomyUpdateCategory200Response, AdminTaxonomyUpdateCategory200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadCategoryResponseDto get data;

  AdminTaxonomyUpdateCategory200Response._();

  factory AdminTaxonomyUpdateCategory200Response([void updates(AdminTaxonomyUpdateCategory200ResponseBuilder b)]) = _$AdminTaxonomyUpdateCategory200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTaxonomyUpdateCategory200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTaxonomyUpdateCategory200Response> get serializer => _$AdminTaxonomyUpdateCategory200ResponseSerializer();
}

class _$AdminTaxonomyUpdateCategory200ResponseSerializer implements PrimitiveSerializer<AdminTaxonomyUpdateCategory200Response> {
  @override
  final Iterable<Type> types = const [AdminTaxonomyUpdateCategory200Response, _$AdminTaxonomyUpdateCategory200Response];

  @override
  final String wireName = r'AdminTaxonomyUpdateCategory200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTaxonomyUpdateCategory200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ThreadCategoryResponseDto),
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
    AdminTaxonomyUpdateCategory200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTaxonomyUpdateCategory200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadCategoryResponseDto),
          ) as ThreadCategoryResponseDto;
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
  AdminTaxonomyUpdateCategory200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTaxonomyUpdateCategory200ResponseBuilder();
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

class AdminTaxonomyUpdateCategory200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminTaxonomyUpdateCategory200ResponseCodeEnum number0 = _$adminTaxonomyUpdateCategory200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminTaxonomyUpdateCategory200ResponseCodeEnum unknownDefaultOpenApi = _$adminTaxonomyUpdateCategory200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminTaxonomyUpdateCategory200ResponseCodeEnum> get serializer => _$adminTaxonomyUpdateCategory200ResponseCodeEnumSerializer;

  const AdminTaxonomyUpdateCategory200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminTaxonomyUpdateCategory200ResponseCodeEnum> get values => _$adminTaxonomyUpdateCategory200ResponseCodeEnumValues;
  static AdminTaxonomyUpdateCategory200ResponseCodeEnum valueOf(String name) => _$adminTaxonomyUpdateCategory200ResponseCodeEnumValueOf(name);
}
