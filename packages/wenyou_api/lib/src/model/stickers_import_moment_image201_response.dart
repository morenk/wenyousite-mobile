//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/sticker_import_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stickers_import_moment_image201_response.g.dart';

/// StickersImportMomentImage201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class StickersImportMomentImage201Response implements ApiSuccessEnvelope, Built<StickersImportMomentImage201Response, StickersImportMomentImage201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  StickerImportResponseDto get data;

  StickersImportMomentImage201Response._();

  factory StickersImportMomentImage201Response([void updates(StickersImportMomentImage201ResponseBuilder b)]) = _$StickersImportMomentImage201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickersImportMomentImage201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickersImportMomentImage201Response> get serializer => _$StickersImportMomentImage201ResponseSerializer();
}

class _$StickersImportMomentImage201ResponseSerializer implements PrimitiveSerializer<StickersImportMomentImage201Response> {
  @override
  final Iterable<Type> types = const [StickersImportMomentImage201Response, _$StickersImportMomentImage201Response];

  @override
  final String wireName = r'StickersImportMomentImage201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickersImportMomentImage201Response object, {
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
    StickersImportMomentImage201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickersImportMomentImage201ResponseBuilder result,
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
  StickersImportMomentImage201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickersImportMomentImage201ResponseBuilder();
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

class StickersImportMomentImage201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const StickersImportMomentImage201ResponseCodeEnum number0 = _$stickersImportMomentImage201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const StickersImportMomentImage201ResponseCodeEnum unknownDefaultOpenApi = _$stickersImportMomentImage201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<StickersImportMomentImage201ResponseCodeEnum> get serializer => _$stickersImportMomentImage201ResponseCodeEnumSerializer;

  const StickersImportMomentImage201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<StickersImportMomentImage201ResponseCodeEnum> get values => _$stickersImportMomentImage201ResponseCodeEnumValues;
  static StickersImportMomentImage201ResponseCodeEnum valueOf(String name) => _$stickersImportMomentImage201ResponseCodeEnumValueOf(name);
}
