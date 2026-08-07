//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/sticker_collection_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stickers_remove200_response.g.dart';

/// StickersRemove200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class StickersRemove200Response implements ApiSuccessEnvelope, Built<StickersRemove200Response, StickersRemove200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  StickerCollectionResponseDto get data;

  StickersRemove200Response._();

  factory StickersRemove200Response([void updates(StickersRemove200ResponseBuilder b)]) = _$StickersRemove200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickersRemove200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickersRemove200Response> get serializer => _$StickersRemove200ResponseSerializer();
}

class _$StickersRemove200ResponseSerializer implements PrimitiveSerializer<StickersRemove200Response> {
  @override
  final Iterable<Type> types = const [StickersRemove200Response, _$StickersRemove200Response];

  @override
  final String wireName = r'StickersRemove200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickersRemove200Response object, {
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
    StickersRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickersRemove200ResponseBuilder result,
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
  StickersRemove200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickersRemove200ResponseBuilder();
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

class StickersRemove200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const StickersRemove200ResponseCodeEnum number0 = _$stickersRemove200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const StickersRemove200ResponseCodeEnum unknownDefaultOpenApi = _$stickersRemove200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<StickersRemove200ResponseCodeEnum> get serializer => _$stickersRemove200ResponseCodeEnumSerializer;

  const StickersRemove200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<StickersRemove200ResponseCodeEnum> get values => _$stickersRemove200ResponseCodeEnumValues;
  static StickersRemove200ResponseCodeEnum valueOf(String name) => _$stickersRemove200ResponseCodeEnumValueOf(name);
}
