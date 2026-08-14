//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_hidden_content_response_dto.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_moderation_list_hidden_content200_response.g.dart';

/// AdminModerationListHiddenContent200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class AdminModerationListHiddenContent200Response implements ApiPaginatedSuccessEnvelope, Built<AdminModerationListHiddenContent200Response, AdminModerationListHiddenContent200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<AdminHiddenContentResponseDto> get data;

  AdminModerationListHiddenContent200Response._();

  factory AdminModerationListHiddenContent200Response([void updates(AdminModerationListHiddenContent200ResponseBuilder b)]) = _$AdminModerationListHiddenContent200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminModerationListHiddenContent200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminModerationListHiddenContent200Response> get serializer => _$AdminModerationListHiddenContent200ResponseSerializer();
}

class _$AdminModerationListHiddenContent200ResponseSerializer implements PrimitiveSerializer<AdminModerationListHiddenContent200Response> {
  @override
  final Iterable<Type> types = const [AdminModerationListHiddenContent200Response, _$AdminModerationListHiddenContent200Response];

  @override
  final String wireName = r'AdminModerationListHiddenContent200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminModerationListHiddenContent200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(AdminHiddenContentResponseDto)]),
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
    AdminModerationListHiddenContent200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminModerationListHiddenContent200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(AdminHiddenContentResponseDto)]),
          ) as BuiltList<AdminHiddenContentResponseDto>;
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
  AdminModerationListHiddenContent200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminModerationListHiddenContent200ResponseBuilder();
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

class AdminModerationListHiddenContent200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminModerationListHiddenContent200ResponseCodeEnum number0 = _$adminModerationListHiddenContent200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminModerationListHiddenContent200ResponseCodeEnum unknownDefaultOpenApi = _$adminModerationListHiddenContent200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminModerationListHiddenContent200ResponseCodeEnum> get serializer => _$adminModerationListHiddenContent200ResponseCodeEnumSerializer;

  const AdminModerationListHiddenContent200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminModerationListHiddenContent200ResponseCodeEnum> get values => _$adminModerationListHiddenContent200ResponseCodeEnumValues;
  static AdminModerationListHiddenContent200ResponseCodeEnum valueOf(String name) => _$adminModerationListHiddenContent200ResponseCodeEnumValueOf(name);
}
