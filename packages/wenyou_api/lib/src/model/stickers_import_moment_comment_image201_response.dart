//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/sticker_import_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stickers_import_moment_comment_image201_response.g.dart';

/// StickersImportMomentCommentImage201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class StickersImportMomentCommentImage201Response implements ApiSuccessEnvelope, Built<StickersImportMomentCommentImage201Response, StickersImportMomentCommentImage201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  StickerImportResponseDto get data;

  StickersImportMomentCommentImage201Response._();

  factory StickersImportMomentCommentImage201Response([void updates(StickersImportMomentCommentImage201ResponseBuilder b)]) = _$StickersImportMomentCommentImage201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StickersImportMomentCommentImage201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StickersImportMomentCommentImage201Response> get serializer => _$StickersImportMomentCommentImage201ResponseSerializer();
}

class _$StickersImportMomentCommentImage201ResponseSerializer implements PrimitiveSerializer<StickersImportMomentCommentImage201Response> {
  @override
  final Iterable<Type> types = const [StickersImportMomentCommentImage201Response, _$StickersImportMomentCommentImage201Response];

  @override
  final String wireName = r'StickersImportMomentCommentImage201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StickersImportMomentCommentImage201Response object, {
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
    StickersImportMomentCommentImage201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StickersImportMomentCommentImage201ResponseBuilder result,
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
  StickersImportMomentCommentImage201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StickersImportMomentCommentImage201ResponseBuilder();
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

class StickersImportMomentCommentImage201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const StickersImportMomentCommentImage201ResponseCodeEnum number0 = _$stickersImportMomentCommentImage201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const StickersImportMomentCommentImage201ResponseCodeEnum unknownDefaultOpenApi = _$stickersImportMomentCommentImage201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<StickersImportMomentCommentImage201ResponseCodeEnum> get serializer => _$stickersImportMomentCommentImage201ResponseCodeEnumSerializer;

  const StickersImportMomentCommentImage201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<StickersImportMomentCommentImage201ResponseCodeEnum> get values => _$stickersImportMomentCommentImage201ResponseCodeEnumValues;
  static StickersImportMomentCommentImage201ResponseCodeEnum valueOf(String name) => _$stickersImportMomentCommentImage201ResponseCodeEnumValueOf(name);
}
