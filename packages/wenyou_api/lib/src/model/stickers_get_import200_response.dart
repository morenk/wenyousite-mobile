//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/sticker_import_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stickers_get_import200_response.g.dart';

/// StickersGetImport200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class StickersGetImport200Response implements ApiSuccessEnvelope, Built<StickersGetImport200Response, StickersGetImport200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  StickerImportResponseDto get data;

  StickersGetImport200Response._();

  factory StickersGetImport200Response([void updates(StickersGetImport200ResponseBuilder b)]) = _$StickersGetImport200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickersGetImport200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickersGetImport200Response> get serializer => _$StickersGetImport200ResponseSerializer();
}

class _$StickersGetImport200ResponseSerializer implements PrimitiveSerializer<StickersGetImport200Response> {
  @override
  final Iterable<Type> types = const [StickersGetImport200Response, _$StickersGetImport200Response];

  @override
  final String wireName = r'StickersGetImport200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickersGetImport200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(StickerImportResponseDto),
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
    StickersGetImport200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickersGetImport200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StickerImportResponseDto),
          ) as StickerImportResponseDto;
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
  StickersGetImport200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickersGetImport200ResponseBuilder();
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

class StickersGetImport200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const StickersGetImport200ResponseCodeEnum number0 = _$stickersGetImport200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const StickersGetImport200ResponseCodeEnum unknownDefaultOpenApi = _$stickersGetImport200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<StickersGetImport200ResponseCodeEnum> get serializer => _$stickersGetImport200ResponseCodeEnumSerializer;

  const StickersGetImport200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<StickersGetImport200ResponseCodeEnum> get values => _$stickersGetImport200ResponseCodeEnumValues;
  static StickersGetImport200ResponseCodeEnum valueOf(String name) => _$stickersGetImport200ResponseCodeEnumValueOf(name);
}
