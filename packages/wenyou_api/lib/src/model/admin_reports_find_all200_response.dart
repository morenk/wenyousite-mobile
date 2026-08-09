//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_report_response_dto.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_reports_find_all200_response.g.dart';

/// AdminReportsFindAll200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class AdminReportsFindAll200Response implements ApiPaginatedSuccessEnvelope, Built<AdminReportsFindAll200Response, AdminReportsFindAll200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<AdminReportResponseDto> get data;

  AdminReportsFindAll200Response._();

  factory AdminReportsFindAll200Response([void updates(AdminReportsFindAll200ResponseBuilder b)]) = _$AdminReportsFindAll200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminReportsFindAll200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminReportsFindAll200Response> get serializer => _$AdminReportsFindAll200ResponseSerializer();
}

class _$AdminReportsFindAll200ResponseSerializer implements PrimitiveSerializer<AdminReportsFindAll200Response> {
  @override
  final Iterable<Type> types = const [AdminReportsFindAll200Response, _$AdminReportsFindAll200Response];

  @override
  final String wireName = r'AdminReportsFindAll200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminReportsFindAll200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(AdminReportResponseDto)]),
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
    AdminReportsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminReportsFindAll200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(AdminReportResponseDto)]),
          ) as BuiltList<AdminReportResponseDto>;
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
  AdminReportsFindAll200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminReportsFindAll200ResponseBuilder();
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

class AdminReportsFindAll200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminReportsFindAll200ResponseCodeEnum number0 = _$adminReportsFindAll200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminReportsFindAll200ResponseCodeEnum unknownDefaultOpenApi = _$adminReportsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminReportsFindAll200ResponseCodeEnum> get serializer => _$adminReportsFindAll200ResponseCodeEnumSerializer;

  const AdminReportsFindAll200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminReportsFindAll200ResponseCodeEnum> get values => _$adminReportsFindAll200ResponseCodeEnumValues;
  static AdminReportsFindAll200ResponseCodeEnum valueOf(String name) => _$adminReportsFindAll200ResponseCodeEnumValueOf(name);
}
