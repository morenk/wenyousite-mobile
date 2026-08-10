//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/site_operational_settings_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'site_operational_settings_get200_response.g.dart';

/// SiteOperationalSettingsGet200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class SiteOperationalSettingsGet200Response implements ApiSuccessEnvelope, Built<SiteOperationalSettingsGet200Response, SiteOperationalSettingsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  SiteOperationalSettingsResponseDto get data;

  SiteOperationalSettingsGet200Response._();

  factory SiteOperationalSettingsGet200Response([void updates(SiteOperationalSettingsGet200ResponseBuilder b)]) = _$SiteOperationalSettingsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SiteOperationalSettingsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SiteOperationalSettingsGet200Response> get serializer => _$SiteOperationalSettingsGet200ResponseSerializer();
}

class _$SiteOperationalSettingsGet200ResponseSerializer implements PrimitiveSerializer<SiteOperationalSettingsGet200Response> {
  @override
  final Iterable<Type> types = const [SiteOperationalSettingsGet200Response, _$SiteOperationalSettingsGet200Response];

  @override
  final String wireName = r'SiteOperationalSettingsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SiteOperationalSettingsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(SiteOperationalSettingsResponseDto),
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
    SiteOperationalSettingsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SiteOperationalSettingsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SiteOperationalSettingsResponseDto),
          ) as SiteOperationalSettingsResponseDto;
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
  SiteOperationalSettingsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SiteOperationalSettingsGet200ResponseBuilder();
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

class SiteOperationalSettingsGet200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SiteOperationalSettingsGet200ResponseCodeEnum number0 = _$siteOperationalSettingsGet200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SiteOperationalSettingsGet200ResponseCodeEnum unknownDefaultOpenApi = _$siteOperationalSettingsGet200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SiteOperationalSettingsGet200ResponseCodeEnum> get serializer => _$siteOperationalSettingsGet200ResponseCodeEnumSerializer;

  const SiteOperationalSettingsGet200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SiteOperationalSettingsGet200ResponseCodeEnum> get values => _$siteOperationalSettingsGet200ResponseCodeEnumValues;
  static SiteOperationalSettingsGet200ResponseCodeEnum valueOf(String name) => _$siteOperationalSettingsGet200ResponseCodeEnumValueOf(name);
}
