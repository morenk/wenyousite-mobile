//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/sticker_import_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stickers_import_direct_message201_response.g.dart';

/// StickersImportDirectMessage201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class StickersImportDirectMessage201Response implements ApiSuccessEnvelope, Built<StickersImportDirectMessage201Response, StickersImportDirectMessage201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  StickerImportResponseDto get data;

  StickersImportDirectMessage201Response._();

  factory StickersImportDirectMessage201Response([void updates(StickersImportDirectMessage201ResponseBuilder b)]) = _$StickersImportDirectMessage201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickersImportDirectMessage201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickersImportDirectMessage201Response> get serializer => _$StickersImportDirectMessage201ResponseSerializer();
}

class _$StickersImportDirectMessage201ResponseSerializer implements PrimitiveSerializer<StickersImportDirectMessage201Response> {
  @override
  final Iterable<Type> types = const [StickersImportDirectMessage201Response, _$StickersImportDirectMessage201Response];

  @override
  final String wireName = r'StickersImportDirectMessage201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickersImportDirectMessage201Response object, {
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
    StickersImportDirectMessage201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickersImportDirectMessage201ResponseBuilder result,
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
  StickersImportDirectMessage201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickersImportDirectMessage201ResponseBuilder();
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

class StickersImportDirectMessage201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const StickersImportDirectMessage201ResponseCodeEnum number0 = _$stickersImportDirectMessage201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const StickersImportDirectMessage201ResponseCodeEnum unknownDefaultOpenApi = _$stickersImportDirectMessage201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<StickersImportDirectMessage201ResponseCodeEnum> get serializer => _$stickersImportDirectMessage201ResponseCodeEnumSerializer;

  const StickersImportDirectMessage201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<StickersImportDirectMessage201ResponseCodeEnum> get values => _$stickersImportDirectMessage201ResponseCodeEnumValues;
  static StickersImportDirectMessage201ResponseCodeEnum valueOf(String name) => _$stickersImportDirectMessage201ResponseCodeEnumValueOf(name);
}
