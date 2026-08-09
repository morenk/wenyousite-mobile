//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/admin_user_moderation_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_moderation_list_users200_response.g.dart';

/// AdminModerationListUsers200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class AdminModerationListUsers200Response implements ApiPaginatedSuccessEnvelope, Built<AdminModerationListUsers200Response, AdminModerationListUsers200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<AdminUserModerationResponseDto> get data;

  AdminModerationListUsers200Response._();

  factory AdminModerationListUsers200Response([void updates(AdminModerationListUsers200ResponseBuilder b)]) = _$AdminModerationListUsers200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminModerationListUsers200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminModerationListUsers200Response> get serializer => _$AdminModerationListUsers200ResponseSerializer();
}

class _$AdminModerationListUsers200ResponseSerializer implements PrimitiveSerializer<AdminModerationListUsers200Response> {
  @override
  final Iterable<Type> types = const [AdminModerationListUsers200Response, _$AdminModerationListUsers200Response];

  @override
  final String wireName = r'AdminModerationListUsers200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminModerationListUsers200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(AdminUserModerationResponseDto)]),
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
    AdminModerationListUsers200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminModerationListUsers200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(AdminUserModerationResponseDto)]),
          ) as BuiltList<AdminUserModerationResponseDto>;
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
  AdminModerationListUsers200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminModerationListUsers200ResponseBuilder();
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

class AdminModerationListUsers200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminModerationListUsers200ResponseCodeEnum number0 = _$adminModerationListUsers200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminModerationListUsers200ResponseCodeEnum unknownDefaultOpenApi = _$adminModerationListUsers200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminModerationListUsers200ResponseCodeEnum> get serializer => _$adminModerationListUsers200ResponseCodeEnumSerializer;

  const AdminModerationListUsers200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminModerationListUsers200ResponseCodeEnum> get values => _$adminModerationListUsers200ResponseCodeEnumValues;
  static AdminModerationListUsers200ResponseCodeEnum valueOf(String name) => _$adminModerationListUsers200ResponseCodeEnumValueOf(name);
}
