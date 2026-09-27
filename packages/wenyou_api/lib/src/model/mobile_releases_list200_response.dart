//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/public_mobile_release_dto.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mobile_releases_list200_response.g.dart';

/// MobileReleasesList200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class MobileReleasesList200Response implements ApiPaginatedSuccessEnvelope, Built<MobileReleasesList200Response, MobileReleasesList200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<PublicMobileReleaseDto> get data;

  MobileReleasesList200Response._();

  factory MobileReleasesList200Response([void updates(MobileReleasesList200ResponseBuilder b)]) = _$MobileReleasesList200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MobileReleasesList200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MobileReleasesList200Response> get serializer => _$MobileReleasesList200ResponseSerializer();
}

class _$MobileReleasesList200ResponseSerializer implements PrimitiveSerializer<MobileReleasesList200Response> {
  @override
  final Iterable<Type> types = const [MobileReleasesList200Response, _$MobileReleasesList200Response];

  @override
  final String wireName = r'MobileReleasesList200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MobileReleasesList200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(PublicMobileReleaseDto)]),
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
    MobileReleasesList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MobileReleasesList200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(PublicMobileReleaseDto)]),
          ) as BuiltList<PublicMobileReleaseDto>;
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
  MobileReleasesList200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MobileReleasesList200ResponseBuilder();
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

class MobileReleasesList200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MobileReleasesList200ResponseCodeEnum number0 = _$mobileReleasesList200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MobileReleasesList200ResponseCodeEnum unknownDefaultOpenApi = _$mobileReleasesList200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MobileReleasesList200ResponseCodeEnum> get serializer => _$mobileReleasesList200ResponseCodeEnumSerializer;

  const MobileReleasesList200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MobileReleasesList200ResponseCodeEnum> get values => _$mobileReleasesList200ResponseCodeEnumValues;
  static MobileReleasesList200ResponseCodeEnum valueOf(String name) => _$mobileReleasesList200ResponseCodeEnumValueOf(name);
}
