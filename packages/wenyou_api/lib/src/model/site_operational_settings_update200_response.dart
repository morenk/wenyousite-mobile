//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/site_operational_settings_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'site_operational_settings_update200_response.g.dart';

/// SiteOperationalSettingsUpdate200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class SiteOperationalSettingsUpdate200Response implements ApiSuccessEnvelope, Built<SiteOperationalSettingsUpdate200Response, SiteOperationalSettingsUpdate200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  SiteOperationalSettingsResponseDto get data;

  SiteOperationalSettingsUpdate200Response._();

  factory SiteOperationalSettingsUpdate200Response([void updates(SiteOperationalSettingsUpdate200ResponseBuilder b)]) = _$SiteOperationalSettingsUpdate200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SiteOperationalSettingsUpdate200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SiteOperationalSettingsUpdate200Response> get serializer => _$SiteOperationalSettingsUpdate200ResponseSerializer();
}

class _$SiteOperationalSettingsUpdate200ResponseSerializer implements PrimitiveSerializer<SiteOperationalSettingsUpdate200Response> {
  @override
  final Iterable<Type> types = const [SiteOperationalSettingsUpdate200Response, _$SiteOperationalSettingsUpdate200Response];

  @override
  final String wireName = r'SiteOperationalSettingsUpdate200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SiteOperationalSettingsUpdate200Response object, {
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
    SiteOperationalSettingsUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SiteOperationalSettingsUpdate200ResponseBuilder result,
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
  SiteOperationalSettingsUpdate200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SiteOperationalSettingsUpdate200ResponseBuilder();
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

class SiteOperationalSettingsUpdate200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const SiteOperationalSettingsUpdate200ResponseCodeEnum number0 = _$siteOperationalSettingsUpdate200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const SiteOperationalSettingsUpdate200ResponseCodeEnum unknownDefaultOpenApi = _$siteOperationalSettingsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<SiteOperationalSettingsUpdate200ResponseCodeEnum> get serializer => _$siteOperationalSettingsUpdate200ResponseCodeEnumSerializer;

  const SiteOperationalSettingsUpdate200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<SiteOperationalSettingsUpdate200ResponseCodeEnum> get values => _$siteOperationalSettingsUpdate200ResponseCodeEnumValues;
  static SiteOperationalSettingsUpdate200ResponseCodeEnum valueOf(String name) => _$siteOperationalSettingsUpdate200ResponseCodeEnumValueOf(name);
}
