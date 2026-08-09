//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/tip_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'economy_tip_user201_response.g.dart';

/// EconomyTipUser201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class EconomyTipUser201Response implements ApiSuccessEnvelope, Built<EconomyTipUser201Response, EconomyTipUser201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  TipResponseDto get data;

  EconomyTipUser201Response._();

  factory EconomyTipUser201Response([void updates(EconomyTipUser201ResponseBuilder b)]) = _$EconomyTipUser201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EconomyTipUser201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EconomyTipUser201Response> get serializer => _$EconomyTipUser201ResponseSerializer();
}

class _$EconomyTipUser201ResponseSerializer implements PrimitiveSerializer<EconomyTipUser201Response> {
  @override
  final Iterable<Type> types = const [EconomyTipUser201Response, _$EconomyTipUser201Response];

  @override
  final String wireName = r'EconomyTipUser201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EconomyTipUser201Response object, {
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
    EconomyTipUser201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EconomyTipUser201ResponseBuilder result,
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
  EconomyTipUser201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EconomyTipUser201ResponseBuilder();
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

class EconomyTipUser201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const EconomyTipUser201ResponseCodeEnum number0 = _$economyTipUser201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const EconomyTipUser201ResponseCodeEnum unknownDefaultOpenApi = _$economyTipUser201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<EconomyTipUser201ResponseCodeEnum> get serializer => _$economyTipUser201ResponseCodeEnumSerializer;

  const EconomyTipUser201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<EconomyTipUser201ResponseCodeEnum> get values => _$economyTipUser201ResponseCodeEnumValues;
  static EconomyTipUser201ResponseCodeEnum valueOf(String name) => _$economyTipUser201ResponseCodeEnumValueOf(name);
}
