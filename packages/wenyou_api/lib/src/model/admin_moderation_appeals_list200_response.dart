//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/moderation_appeal_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_moderation_appeals_list200_response.g.dart';

/// AdminModerationAppealsList200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class AdminModerationAppealsList200Response implements ApiPaginatedSuccessEnvelope, Built<AdminModerationAppealsList200Response, AdminModerationAppealsList200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ModerationAppealResponseDto> get data;

  AdminModerationAppealsList200Response._();

  factory AdminModerationAppealsList200Response([void updates(AdminModerationAppealsList200ResponseBuilder b)]) = _$AdminModerationAppealsList200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminModerationAppealsList200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminModerationAppealsList200Response> get serializer => _$AdminModerationAppealsList200ResponseSerializer();
}

class _$AdminModerationAppealsList200ResponseSerializer implements PrimitiveSerializer<AdminModerationAppealsList200Response> {
  @override
  final Iterable<Type> types = const [AdminModerationAppealsList200Response, _$AdminModerationAppealsList200Response];

  @override
  final String wireName = r'AdminModerationAppealsList200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminModerationAppealsList200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(ModerationAppealResponseDto)]),
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
    AdminModerationAppealsList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminModerationAppealsList200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(ModerationAppealResponseDto)]),
          ) as BuiltList<ModerationAppealResponseDto>;
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
  AdminModerationAppealsList200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminModerationAppealsList200ResponseBuilder();
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

class AdminModerationAppealsList200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminModerationAppealsList200ResponseCodeEnum number0 = _$adminModerationAppealsList200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminModerationAppealsList200ResponseCodeEnum unknownDefaultOpenApi = _$adminModerationAppealsList200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminModerationAppealsList200ResponseCodeEnum> get serializer => _$adminModerationAppealsList200ResponseCodeEnumSerializer;

  const AdminModerationAppealsList200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminModerationAppealsList200ResponseCodeEnum> get values => _$adminModerationAppealsList200ResponseCodeEnumValues;
  static AdminModerationAppealsList200ResponseCodeEnum valueOf(String name) => _$adminModerationAppealsList200ResponseCodeEnumValueOf(name);
}
