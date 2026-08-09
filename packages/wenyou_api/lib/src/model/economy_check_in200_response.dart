//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/daily_check_in_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'economy_check_in200_response.g.dart';

/// EconomyCheckIn200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class EconomyCheckIn200Response implements ApiSuccessEnvelope, Built<EconomyCheckIn200Response, EconomyCheckIn200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DailyCheckInResponseDto get data;

  EconomyCheckIn200Response._();

  factory EconomyCheckIn200Response([void updates(EconomyCheckIn200ResponseBuilder b)]) = _$EconomyCheckIn200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EconomyCheckIn200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EconomyCheckIn200Response> get serializer => _$EconomyCheckIn200ResponseSerializer();
}

class _$EconomyCheckIn200ResponseSerializer implements PrimitiveSerializer<EconomyCheckIn200Response> {
  @override
  final Iterable<Type> types = const [EconomyCheckIn200Response, _$EconomyCheckIn200Response];

  @override
  final String wireName = r'EconomyCheckIn200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EconomyCheckIn200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DailyCheckInResponseDto),
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
    EconomyCheckIn200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EconomyCheckIn200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DailyCheckInResponseDto),
          ) as DailyCheckInResponseDto;
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
  EconomyCheckIn200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EconomyCheckIn200ResponseBuilder();
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

class EconomyCheckIn200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const EconomyCheckIn200ResponseCodeEnum number0 = _$economyCheckIn200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const EconomyCheckIn200ResponseCodeEnum unknownDefaultOpenApi = _$economyCheckIn200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<EconomyCheckIn200ResponseCodeEnum> get serializer => _$economyCheckIn200ResponseCodeEnumSerializer;

  const EconomyCheckIn200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<EconomyCheckIn200ResponseCodeEnum> get values => _$economyCheckIn200ResponseCodeEnumValues;
  static EconomyCheckIn200ResponseCodeEnum valueOf(String name) => _$economyCheckIn200ResponseCodeEnumValueOf(name);
}
