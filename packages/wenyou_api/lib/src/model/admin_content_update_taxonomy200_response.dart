//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_content_detail_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_content_update_taxonomy200_response.g.dart';

/// AdminContentUpdateTaxonomy200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminContentUpdateTaxonomy200Response implements ApiSuccessEnvelope, Built<AdminContentUpdateTaxonomy200Response, AdminContentUpdateTaxonomy200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminContentDetailResponseDto get data;

  AdminContentUpdateTaxonomy200Response._();

  factory AdminContentUpdateTaxonomy200Response([void updates(AdminContentUpdateTaxonomy200ResponseBuilder b)]) = _$AdminContentUpdateTaxonomy200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminContentUpdateTaxonomy200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminContentUpdateTaxonomy200Response> get serializer => _$AdminContentUpdateTaxonomy200ResponseSerializer();
}

class _$AdminContentUpdateTaxonomy200ResponseSerializer implements PrimitiveSerializer<AdminContentUpdateTaxonomy200Response> {
  @override
  final Iterable<Type> types = const [AdminContentUpdateTaxonomy200Response, _$AdminContentUpdateTaxonomy200Response];

  @override
  final String wireName = r'AdminContentUpdateTaxonomy200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminContentUpdateTaxonomy200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminContentDetailResponseDto),
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
    AdminContentUpdateTaxonomy200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminContentUpdateTaxonomy200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminContentDetailResponseDto),
          ) as AdminContentDetailResponseDto;
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
  AdminContentUpdateTaxonomy200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminContentUpdateTaxonomy200ResponseBuilder();
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

class AdminContentUpdateTaxonomy200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminContentUpdateTaxonomy200ResponseCodeEnum number0 = _$adminContentUpdateTaxonomy200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminContentUpdateTaxonomy200ResponseCodeEnum unknownDefaultOpenApi = _$adminContentUpdateTaxonomy200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminContentUpdateTaxonomy200ResponseCodeEnum> get serializer => _$adminContentUpdateTaxonomy200ResponseCodeEnumSerializer;

  const AdminContentUpdateTaxonomy200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminContentUpdateTaxonomy200ResponseCodeEnum> get values => _$adminContentUpdateTaxonomy200ResponseCodeEnumValues;
  static AdminContentUpdateTaxonomy200ResponseCodeEnum valueOf(String name) => _$adminContentUpdateTaxonomy200ResponseCodeEnumValueOf(name);
}
