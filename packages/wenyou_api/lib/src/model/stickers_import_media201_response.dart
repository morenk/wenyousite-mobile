//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/sticker_import_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stickers_import_media201_response.g.dart';

/// StickersImportMedia201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class StickersImportMedia201Response implements ApiSuccessEnvelope, Built<StickersImportMedia201Response, StickersImportMedia201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  StickerImportResponseDto get data;

  StickersImportMedia201Response._();

  factory StickersImportMedia201Response([void updates(StickersImportMedia201ResponseBuilder b)]) = _$StickersImportMedia201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickersImportMedia201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickersImportMedia201Response> get serializer => _$StickersImportMedia201ResponseSerializer();
}

class _$StickersImportMedia201ResponseSerializer implements PrimitiveSerializer<StickersImportMedia201Response> {
  @override
  final Iterable<Type> types = const [StickersImportMedia201Response, _$StickersImportMedia201Response];

  @override
  final String wireName = r'StickersImportMedia201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickersImportMedia201Response object, {
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
    StickersImportMedia201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickersImportMedia201ResponseBuilder result,
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
  StickersImportMedia201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickersImportMedia201ResponseBuilder();
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

class StickersImportMedia201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const StickersImportMedia201ResponseCodeEnum number0 = _$stickersImportMedia201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const StickersImportMedia201ResponseCodeEnum unknownDefaultOpenApi = _$stickersImportMedia201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<StickersImportMedia201ResponseCodeEnum> get serializer => _$stickersImportMedia201ResponseCodeEnumSerializer;

  const StickersImportMedia201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<StickersImportMedia201ResponseCodeEnum> get values => _$stickersImportMedia201ResponseCodeEnumValues;
  static StickersImportMedia201ResponseCodeEnum valueOf(String name) => _$stickersImportMedia201ResponseCodeEnumValueOf(name);
}
