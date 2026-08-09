//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_audit_log_response_dto.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_moderation_list_audit_logs200_response.g.dart';

/// AdminModerationListAuditLogs200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class AdminModerationListAuditLogs200Response implements ApiPaginatedSuccessEnvelope, Built<AdminModerationListAuditLogs200Response, AdminModerationListAuditLogs200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<AdminAuditLogResponseDto> get data;

  AdminModerationListAuditLogs200Response._();

  factory AdminModerationListAuditLogs200Response([void updates(AdminModerationListAuditLogs200ResponseBuilder b)]) = _$AdminModerationListAuditLogs200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminModerationListAuditLogs200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminModerationListAuditLogs200Response> get serializer => _$AdminModerationListAuditLogs200ResponseSerializer();
}

class _$AdminModerationListAuditLogs200ResponseSerializer implements PrimitiveSerializer<AdminModerationListAuditLogs200Response> {
  @override
  final Iterable<Type> types = const [AdminModerationListAuditLogs200Response, _$AdminModerationListAuditLogs200Response];

  @override
  final String wireName = r'AdminModerationListAuditLogs200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminModerationListAuditLogs200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(AdminAuditLogResponseDto)]),
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
    AdminModerationListAuditLogs200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminModerationListAuditLogs200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(AdminAuditLogResponseDto)]),
          ) as BuiltList<AdminAuditLogResponseDto>;
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
  AdminModerationListAuditLogs200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminModerationListAuditLogs200ResponseBuilder();
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

class AdminModerationListAuditLogs200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminModerationListAuditLogs200ResponseCodeEnum number0 = _$adminModerationListAuditLogs200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminModerationListAuditLogs200ResponseCodeEnum unknownDefaultOpenApi = _$adminModerationListAuditLogs200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminModerationListAuditLogs200ResponseCodeEnum> get serializer => _$adminModerationListAuditLogs200ResponseCodeEnumSerializer;

  const AdminModerationListAuditLogs200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminModerationListAuditLogs200ResponseCodeEnum> get values => _$adminModerationListAuditLogs200ResponseCodeEnumValues;
  static AdminModerationListAuditLogs200ResponseCodeEnum valueOf(String name) => _$adminModerationListAuditLogs200ResponseCodeEnumValueOf(name);
}
