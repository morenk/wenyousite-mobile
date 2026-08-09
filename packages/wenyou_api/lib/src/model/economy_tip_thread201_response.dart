//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/tip_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'economy_tip_thread201_response.g.dart';

/// EconomyTipThread201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class EconomyTipThread201Response implements ApiSuccessEnvelope, Built<EconomyTipThread201Response, EconomyTipThread201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  TipResponseDto get data;

  EconomyTipThread201Response._();

  factory EconomyTipThread201Response([void updates(EconomyTipThread201ResponseBuilder b)]) = _$EconomyTipThread201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EconomyTipThread201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EconomyTipThread201Response> get serializer => _$EconomyTipThread201ResponseSerializer();
}

class _$EconomyTipThread201ResponseSerializer implements PrimitiveSerializer<EconomyTipThread201Response> {
  @override
  final Iterable<Type> types = const [EconomyTipThread201Response, _$EconomyTipThread201Response];

  @override
  final String wireName = r'EconomyTipThread201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EconomyTipThread201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(TipResponseDto),
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
    EconomyTipThread201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EconomyTipThread201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TipResponseDto),
          ) as TipResponseDto;
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
  EconomyTipThread201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EconomyTipThread201ResponseBuilder();
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

class EconomyTipThread201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const EconomyTipThread201ResponseCodeEnum number0 = _$economyTipThread201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const EconomyTipThread201ResponseCodeEnum unknownDefaultOpenApi = _$economyTipThread201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<EconomyTipThread201ResponseCodeEnum> get serializer => _$economyTipThread201ResponseCodeEnumSerializer;

  const EconomyTipThread201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<EconomyTipThread201ResponseCodeEnum> get values => _$economyTipThread201ResponseCodeEnumValues;
  static EconomyTipThread201ResponseCodeEnum valueOf(String name) => _$economyTipThread201ResponseCodeEnumValueOf(name);
}
