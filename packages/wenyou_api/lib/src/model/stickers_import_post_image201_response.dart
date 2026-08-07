//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/sticker_import_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stickers_import_post_image201_response.g.dart';

/// StickersImportPostImage201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class StickersImportPostImage201Response implements ApiSuccessEnvelope, Built<StickersImportPostImage201Response, StickersImportPostImage201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  StickerImportResponseDto get data;

  StickersImportPostImage201Response._();

  factory StickersImportPostImage201Response([void updates(StickersImportPostImage201ResponseBuilder b)]) = _$StickersImportPostImage201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickersImportPostImage201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickersImportPostImage201Response> get serializer => _$StickersImportPostImage201ResponseSerializer();
}

class _$StickersImportPostImage201ResponseSerializer implements PrimitiveSerializer<StickersImportPostImage201Response> {
  @override
  final Iterable<Type> types = const [StickersImportPostImage201Response, _$StickersImportPostImage201Response];

  @override
  final String wireName = r'StickersImportPostImage201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickersImportPostImage201Response object, {
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
    StickersImportPostImage201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickersImportPostImage201ResponseBuilder result,
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
  StickersImportPostImage201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickersImportPostImage201ResponseBuilder();
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

class StickersImportPostImage201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const StickersImportPostImage201ResponseCodeEnum number0 = _$stickersImportPostImage201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const StickersImportPostImage201ResponseCodeEnum unknownDefaultOpenApi = _$stickersImportPostImage201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<StickersImportPostImage201ResponseCodeEnum> get serializer => _$stickersImportPostImage201ResponseCodeEnumSerializer;

  const StickersImportPostImage201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<StickersImportPostImage201ResponseCodeEnum> get values => _$stickersImportPostImage201ResponseCodeEnumValues;
  static StickersImportPostImage201ResponseCodeEnum valueOf(String name) => _$stickersImportPostImage201ResponseCodeEnumValueOf(name);
}
