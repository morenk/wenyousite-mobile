//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/sticker_collection_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stickers_reorder200_response.g.dart';

/// StickersReorder200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class StickersReorder200Response implements ApiSuccessEnvelope, Built<StickersReorder200Response, StickersReorder200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  StickerCollectionResponseDto get data;

  StickersReorder200Response._();

  factory StickersReorder200Response([void updates(StickersReorder200ResponseBuilder b)]) = _$StickersReorder200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickersReorder200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickersReorder200Response> get serializer => _$StickersReorder200ResponseSerializer();
}

class _$StickersReorder200ResponseSerializer implements PrimitiveSerializer<StickersReorder200Response> {
  @override
  final Iterable<Type> types = const [StickersReorder200Response, _$StickersReorder200Response];

  @override
  final String wireName = r'StickersReorder200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickersReorder200Response object, {
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
    StickersReorder200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickersReorder200ResponseBuilder result,
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
  StickersReorder200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickersReorder200ResponseBuilder();
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

class StickersReorder200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const StickersReorder200ResponseCodeEnum number0 = _$stickersReorder200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const StickersReorder200ResponseCodeEnum unknownDefaultOpenApi = _$stickersReorder200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<StickersReorder200ResponseCodeEnum> get serializer => _$stickersReorder200ResponseCodeEnumSerializer;

  const StickersReorder200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<StickersReorder200ResponseCodeEnum> get values => _$stickersReorder200ResponseCodeEnumValues;
  static StickersReorder200ResponseCodeEnum valueOf(String name) => _$stickersReorder200ResponseCodeEnumValueOf(name);
}
