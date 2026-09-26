//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:wenyou_api/src/model/admin_mobile_release_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_mobile_releases_list200_response.g.dart';

/// AdminMobileReleasesList200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class AdminMobileReleasesList200Response implements ApiPaginatedSuccessEnvelope, Built<AdminMobileReleasesList200Response, AdminMobileReleasesList200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<AdminMobileReleaseDto> get data;

  AdminMobileReleasesList200Response._();

  factory AdminMobileReleasesList200Response([void updates(AdminMobileReleasesList200ResponseBuilder b)]) = _$AdminMobileReleasesList200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminMobileReleasesList200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminMobileReleasesList200Response> get serializer => _$AdminMobileReleasesList200ResponseSerializer();
}

class _$AdminMobileReleasesList200ResponseSerializer implements PrimitiveSerializer<AdminMobileReleasesList200Response> {
  @override
  final Iterable<Type> types = const [AdminMobileReleasesList200Response, _$AdminMobileReleasesList200Response];

  @override
  final String wireName = r'AdminMobileReleasesList200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminMobileReleasesList200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(AdminMobileReleaseDto)]),
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
    AdminMobileReleasesList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminMobileReleasesList200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(AdminMobileReleaseDto)]),
          ) as BuiltList<AdminMobileReleaseDto>;
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
  AdminMobileReleasesList200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminMobileReleasesList200ResponseBuilder();
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

class AdminMobileReleasesList200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminMobileReleasesList200ResponseCodeEnum number0 = _$adminMobileReleasesList200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminMobileReleasesList200ResponseCodeEnum unknownDefaultOpenApi = _$adminMobileReleasesList200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminMobileReleasesList200ResponseCodeEnum> get serializer => _$adminMobileReleasesList200ResponseCodeEnumSerializer;

  const AdminMobileReleasesList200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminMobileReleasesList200ResponseCodeEnum> get values => _$adminMobileReleasesList200ResponseCodeEnumValues;
  static AdminMobileReleasesList200ResponseCodeEnum valueOf(String name) => _$adminMobileReleasesList200ResponseCodeEnumValueOf(name);
}
