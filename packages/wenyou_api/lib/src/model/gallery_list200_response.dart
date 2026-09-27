//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/gallery_page_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'gallery_list200_response.g.dart';

/// GalleryList200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class GalleryList200Response implements ApiSuccessEnvelope, Built<GalleryList200Response, GalleryList200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  GalleryPageDto get data;

  GalleryList200Response._();

  factory GalleryList200Response([void updates(GalleryList200ResponseBuilder b)]) = _$GalleryList200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GalleryList200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GalleryList200Response> get serializer => _$GalleryList200ResponseSerializer();
}

class _$GalleryList200ResponseSerializer implements PrimitiveSerializer<GalleryList200Response> {
  @override
  final Iterable<Type> types = const [GalleryList200Response, _$GalleryList200Response];

  @override
  final String wireName = r'GalleryList200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GalleryList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(GalleryPageDto),
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
    GalleryList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GalleryList200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GalleryPageDto),
          ) as GalleryPageDto;
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
  GalleryList200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GalleryList200ResponseBuilder();
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

class GalleryList200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const GalleryList200ResponseCodeEnum number0 = _$galleryList200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const GalleryList200ResponseCodeEnum unknownDefaultOpenApi = _$galleryList200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<GalleryList200ResponseCodeEnum> get serializer => _$galleryList200ResponseCodeEnumSerializer;

  const GalleryList200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<GalleryList200ResponseCodeEnum> get values => _$galleryList200ResponseCodeEnumValues;
  static GalleryList200ResponseCodeEnum valueOf(String name) => _$galleryList200ResponseCodeEnumValueOf(name);
}
