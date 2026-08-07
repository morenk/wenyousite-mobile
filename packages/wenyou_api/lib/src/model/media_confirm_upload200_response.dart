//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/confirm_upload_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'media_confirm_upload200_response.g.dart';

/// MediaConfirmUpload200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MediaConfirmUpload200Response implements ApiSuccessEnvelope, Built<MediaConfirmUpload200Response, MediaConfirmUpload200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ConfirmUploadResponseDto get data;

  MediaConfirmUpload200Response._();

  factory MediaConfirmUpload200Response([void updates(MediaConfirmUpload200ResponseBuilder b)]) = _$MediaConfirmUpload200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MediaConfirmUpload200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MediaConfirmUpload200Response> get serializer => _$MediaConfirmUpload200ResponseSerializer();
}

class _$MediaConfirmUpload200ResponseSerializer implements PrimitiveSerializer<MediaConfirmUpload200Response> {
  @override
  final Iterable<Type> types = const [MediaConfirmUpload200Response, _$MediaConfirmUpload200Response];

  @override
  final String wireName = r'MediaConfirmUpload200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MediaConfirmUpload200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ConfirmUploadResponseDto),
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
    MediaConfirmUpload200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MediaConfirmUpload200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ConfirmUploadResponseDto),
          ) as ConfirmUploadResponseDto;
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
  MediaConfirmUpload200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MediaConfirmUpload200ResponseBuilder();
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

class MediaConfirmUpload200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MediaConfirmUpload200ResponseCodeEnum number0 = _$mediaConfirmUpload200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MediaConfirmUpload200ResponseCodeEnum unknownDefaultOpenApi = _$mediaConfirmUpload200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MediaConfirmUpload200ResponseCodeEnum> get serializer => _$mediaConfirmUpload200ResponseCodeEnumSerializer;

  const MediaConfirmUpload200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MediaConfirmUpload200ResponseCodeEnum> get values => _$mediaConfirmUpload200ResponseCodeEnumValues;
  static MediaConfirmUpload200ResponseCodeEnum valueOf(String name) => _$mediaConfirmUpload200ResponseCodeEnumValueOf(name);
}
