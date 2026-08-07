//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/sticker_collection_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stickers_get_collection200_response.g.dart';

/// StickersGetCollection200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class StickersGetCollection200Response implements ApiSuccessEnvelope, Built<StickersGetCollection200Response, StickersGetCollection200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  StickerCollectionResponseDto get data;

  StickersGetCollection200Response._();

  factory StickersGetCollection200Response([void updates(StickersGetCollection200ResponseBuilder b)]) = _$StickersGetCollection200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickersGetCollection200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickersGetCollection200Response> get serializer => _$StickersGetCollection200ResponseSerializer();
}

class _$StickersGetCollection200ResponseSerializer implements PrimitiveSerializer<StickersGetCollection200Response> {
  @override
  final Iterable<Type> types = const [StickersGetCollection200Response, _$StickersGetCollection200Response];

  @override
  final String wireName = r'StickersGetCollection200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickersGetCollection200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(StickerCollectionResponseDto),
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
    StickersGetCollection200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickersGetCollection200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StickerCollectionResponseDto),
          ) as StickerCollectionResponseDto;
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
  StickersGetCollection200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickersGetCollection200ResponseBuilder();
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

class StickersGetCollection200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const StickersGetCollection200ResponseCodeEnum number0 = _$stickersGetCollection200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const StickersGetCollection200ResponseCodeEnum unknownDefaultOpenApi = _$stickersGetCollection200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<StickersGetCollection200ResponseCodeEnum> get serializer => _$stickersGetCollection200ResponseCodeEnumSerializer;

  const StickersGetCollection200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<StickersGetCollection200ResponseCodeEnum> get values => _$stickersGetCollection200ResponseCodeEnumValues;
  static StickersGetCollection200ResponseCodeEnum valueOf(String name) => _$stickersGetCollection200ResponseCodeEnumValueOf(name);
}
