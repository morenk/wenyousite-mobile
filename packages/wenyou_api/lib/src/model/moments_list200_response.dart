//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/moment_card_response_dto.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_list200_response.g.dart';

/// MomentsList200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class MomentsList200Response implements ApiPaginatedSuccessEnvelope, Built<MomentsList200Response, MomentsList200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<MomentCardResponseDto> get data;

  MomentsList200Response._();

  factory MomentsList200Response([void updates(MomentsList200ResponseBuilder b)]) = _$MomentsList200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsList200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsList200Response> get serializer => _$MomentsList200ResponseSerializer();
}

class _$MomentsList200ResponseSerializer implements PrimitiveSerializer<MomentsList200Response> {
  @override
  final Iterable<Type> types = const [MomentsList200Response, _$MomentsList200Response];

  @override
  final String wireName = r'MomentsList200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsList200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(MomentCardResponseDto)]),
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
    MomentsList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsList200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(MomentCardResponseDto)]),
          ) as BuiltList<MomentCardResponseDto>;
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
  MomentsList200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsList200ResponseBuilder();
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

class MomentsList200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsList200ResponseCodeEnum number0 = _$momentsList200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsList200ResponseCodeEnum unknownDefaultOpenApi = _$momentsList200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsList200ResponseCodeEnum> get serializer => _$momentsList200ResponseCodeEnumSerializer;

  const MomentsList200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsList200ResponseCodeEnum> get values => _$momentsList200ResponseCodeEnumValues;
  static MomentsList200ResponseCodeEnum valueOf(String name) => _$momentsList200ResponseCodeEnumValueOf(name);
}
