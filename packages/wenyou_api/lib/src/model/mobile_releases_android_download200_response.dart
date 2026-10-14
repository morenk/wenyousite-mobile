//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/android_download_info_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mobile_releases_android_download200_response.g.dart';

/// MobileReleasesAndroidDownload200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MobileReleasesAndroidDownload200Response implements ApiSuccessEnvelope, Built<MobileReleasesAndroidDownload200Response, MobileReleasesAndroidDownload200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AndroidDownloadInfoDto get data;

  MobileReleasesAndroidDownload200Response._();

  factory MobileReleasesAndroidDownload200Response([void updates(MobileReleasesAndroidDownload200ResponseBuilder b)]) = _$MobileReleasesAndroidDownload200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MobileReleasesAndroidDownload200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MobileReleasesAndroidDownload200Response> get serializer => _$MobileReleasesAndroidDownload200ResponseSerializer();
}

class _$MobileReleasesAndroidDownload200ResponseSerializer implements PrimitiveSerializer<MobileReleasesAndroidDownload200Response> {
  @override
  final Iterable<Type> types = const [MobileReleasesAndroidDownload200Response, _$MobileReleasesAndroidDownload200Response];

  @override
  final String wireName = r'MobileReleasesAndroidDownload200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MobileReleasesAndroidDownload200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AndroidDownloadInfoDto),
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
    MobileReleasesAndroidDownload200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MobileReleasesAndroidDownload200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AndroidDownloadInfoDto),
          ) as AndroidDownloadInfoDto;
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
  MobileReleasesAndroidDownload200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MobileReleasesAndroidDownload200ResponseBuilder();
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

class MobileReleasesAndroidDownload200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MobileReleasesAndroidDownload200ResponseCodeEnum number0 = _$mobileReleasesAndroidDownload200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MobileReleasesAndroidDownload200ResponseCodeEnum unknownDefaultOpenApi = _$mobileReleasesAndroidDownload200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MobileReleasesAndroidDownload200ResponseCodeEnum> get serializer => _$mobileReleasesAndroidDownload200ResponseCodeEnumSerializer;

  const MobileReleasesAndroidDownload200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MobileReleasesAndroidDownload200ResponseCodeEnum> get values => _$mobileReleasesAndroidDownload200ResponseCodeEnumValues;
  static MobileReleasesAndroidDownload200ResponseCodeEnum valueOf(String name) => _$mobileReleasesAndroidDownload200ResponseCodeEnumValueOf(name);
}
