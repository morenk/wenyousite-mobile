//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/tip_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'economy_tip_moment201_response.g.dart';

/// EconomyTipMoment201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class EconomyTipMoment201Response implements ApiSuccessEnvelope, Built<EconomyTipMoment201Response, EconomyTipMoment201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  TipResponseDto get data;

  EconomyTipMoment201Response._();

  factory EconomyTipMoment201Response([void updates(EconomyTipMoment201ResponseBuilder b)]) = _$EconomyTipMoment201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EconomyTipMoment201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EconomyTipMoment201Response> get serializer => _$EconomyTipMoment201ResponseSerializer();
}

class _$EconomyTipMoment201ResponseSerializer implements PrimitiveSerializer<EconomyTipMoment201Response> {
  @override
  final Iterable<Type> types = const [EconomyTipMoment201Response, _$EconomyTipMoment201Response];

  @override
  final String wireName = r'EconomyTipMoment201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EconomyTipMoment201Response object, {
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
    EconomyTipMoment201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EconomyTipMoment201ResponseBuilder result,
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
  EconomyTipMoment201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EconomyTipMoment201ResponseBuilder();
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

class EconomyTipMoment201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const EconomyTipMoment201ResponseCodeEnum number0 = _$economyTipMoment201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const EconomyTipMoment201ResponseCodeEnum unknownDefaultOpenApi = _$economyTipMoment201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<EconomyTipMoment201ResponseCodeEnum> get serializer => _$economyTipMoment201ResponseCodeEnumSerializer;

  const EconomyTipMoment201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<EconomyTipMoment201ResponseCodeEnum> get values => _$economyTipMoment201ResponseCodeEnumValues;
  static EconomyTipMoment201ResponseCodeEnum valueOf(String name) => _$economyTipMoment201ResponseCodeEnumValueOf(name);
}
