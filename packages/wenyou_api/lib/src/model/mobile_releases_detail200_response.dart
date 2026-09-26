//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/public_mobile_release_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mobile_releases_detail200_response.g.dart';

/// MobileReleasesDetail200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MobileReleasesDetail200Response implements ApiSuccessEnvelope, Built<MobileReleasesDetail200Response, MobileReleasesDetail200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PublicMobileReleaseDto get data;

  MobileReleasesDetail200Response._();

  factory MobileReleasesDetail200Response([void updates(MobileReleasesDetail200ResponseBuilder b)]) = _$MobileReleasesDetail200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MobileReleasesDetail200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MobileReleasesDetail200Response> get serializer => _$MobileReleasesDetail200ResponseSerializer();
}

class _$MobileReleasesDetail200ResponseSerializer implements PrimitiveSerializer<MobileReleasesDetail200Response> {
  @override
  final Iterable<Type> types = const [MobileReleasesDetail200Response, _$MobileReleasesDetail200Response];

  @override
  final String wireName = r'MobileReleasesDetail200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MobileReleasesDetail200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PublicMobileReleaseDto),
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
    MobileReleasesDetail200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MobileReleasesDetail200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PublicMobileReleaseDto),
          ) as PublicMobileReleaseDto;
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
  MobileReleasesDetail200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MobileReleasesDetail200ResponseBuilder();
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

class MobileReleasesDetail200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MobileReleasesDetail200ResponseCodeEnum number0 = _$mobileReleasesDetail200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MobileReleasesDetail200ResponseCodeEnum unknownDefaultOpenApi = _$mobileReleasesDetail200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MobileReleasesDetail200ResponseCodeEnum> get serializer => _$mobileReleasesDetail200ResponseCodeEnumSerializer;

  const MobileReleasesDetail200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MobileReleasesDetail200ResponseCodeEnum> get values => _$mobileReleasesDetail200ResponseCodeEnumValues;
  static MobileReleasesDetail200ResponseCodeEnum valueOf(String name) => _$mobileReleasesDetail200ResponseCodeEnumValueOf(name);
}
