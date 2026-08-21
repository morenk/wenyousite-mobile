//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/upload_url_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'media_reissue_upload_url200_response.g.dart';

/// MediaReissueUploadUrl200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MediaReissueUploadUrl200Response implements ApiSuccessEnvelope, Built<MediaReissueUploadUrl200Response, MediaReissueUploadUrl200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  UploadUrlResponseDto get data;

  MediaReissueUploadUrl200Response._();

  factory MediaReissueUploadUrl200Response([void updates(MediaReissueUploadUrl200ResponseBuilder b)]) = _$MediaReissueUploadUrl200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MediaReissueUploadUrl200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MediaReissueUploadUrl200Response> get serializer => _$MediaReissueUploadUrl200ResponseSerializer();
}

class _$MediaReissueUploadUrl200ResponseSerializer implements PrimitiveSerializer<MediaReissueUploadUrl200Response> {
  @override
  final Iterable<Type> types = const [MediaReissueUploadUrl200Response, _$MediaReissueUploadUrl200Response];

  @override
  final String wireName = r'MediaReissueUploadUrl200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MediaReissueUploadUrl200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(UploadUrlResponseDto),
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
    MediaReissueUploadUrl200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MediaReissueUploadUrl200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UploadUrlResponseDto),
          ) as UploadUrlResponseDto;
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
  MediaReissueUploadUrl200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MediaReissueUploadUrl200ResponseBuilder();
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

class MediaReissueUploadUrl200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MediaReissueUploadUrl200ResponseCodeEnum number0 = _$mediaReissueUploadUrl200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MediaReissueUploadUrl200ResponseCodeEnum unknownDefaultOpenApi = _$mediaReissueUploadUrl200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MediaReissueUploadUrl200ResponseCodeEnum> get serializer => _$mediaReissueUploadUrl200ResponseCodeEnumSerializer;

  const MediaReissueUploadUrl200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MediaReissueUploadUrl200ResponseCodeEnum> get values => _$mediaReissueUploadUrl200ResponseCodeEnumValues;
  static MediaReissueUploadUrl200ResponseCodeEnum valueOf(String name) => _$mediaReissueUploadUrl200ResponseCodeEnumValueOf(name);
}
