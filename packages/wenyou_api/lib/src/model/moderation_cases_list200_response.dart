//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/moderation_case_response_dto.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moderation_cases_list200_response.g.dart';

/// ModerationCasesList200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class ModerationCasesList200Response implements ApiPaginatedSuccessEnvelope, Built<ModerationCasesList200Response, ModerationCasesList200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ModerationCaseResponseDto> get data;

  ModerationCasesList200Response._();

  factory ModerationCasesList200Response([void updates(ModerationCasesList200ResponseBuilder b)]) = _$ModerationCasesList200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModerationCasesList200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModerationCasesList200Response> get serializer => _$ModerationCasesList200ResponseSerializer();
}

class _$ModerationCasesList200ResponseSerializer implements PrimitiveSerializer<ModerationCasesList200Response> {
  @override
  final Iterable<Type> types = const [ModerationCasesList200Response, _$ModerationCasesList200Response];

  @override
  final String wireName = r'ModerationCasesList200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModerationCasesList200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(ModerationCaseResponseDto)]),
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
    ModerationCasesList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ModerationCasesList200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(ModerationCaseResponseDto)]),
          ) as BuiltList<ModerationCaseResponseDto>;
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
  ModerationCasesList200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModerationCasesList200ResponseBuilder();
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

class ModerationCasesList200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ModerationCasesList200ResponseCodeEnum number0 = _$moderationCasesList200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ModerationCasesList200ResponseCodeEnum unknownDefaultOpenApi = _$moderationCasesList200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ModerationCasesList200ResponseCodeEnum> get serializer => _$moderationCasesList200ResponseCodeEnumSerializer;

  const ModerationCasesList200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ModerationCasesList200ResponseCodeEnum> get values => _$moderationCasesList200ResponseCodeEnumValues;
  static ModerationCasesList200ResponseCodeEnum valueOf(String name) => _$moderationCasesList200ResponseCodeEnumValueOf(name);
}
