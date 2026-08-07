//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/mobile_device_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mobile_device_register200_response.g.dart';

/// MobileDeviceRegister200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MobileDeviceRegister200Response implements ApiSuccessEnvelope, Built<MobileDeviceRegister200Response, MobileDeviceRegister200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MobileDeviceResponseDto get data;

  MobileDeviceRegister200Response._();

  factory MobileDeviceRegister200Response([void updates(MobileDeviceRegister200ResponseBuilder b)]) = _$MobileDeviceRegister200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MobileDeviceRegister200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MobileDeviceRegister200Response> get serializer => _$MobileDeviceRegister200ResponseSerializer();
}

class _$MobileDeviceRegister200ResponseSerializer implements PrimitiveSerializer<MobileDeviceRegister200Response> {
  @override
  final Iterable<Type> types = const [MobileDeviceRegister200Response, _$MobileDeviceRegister200Response];

  @override
  final String wireName = r'MobileDeviceRegister200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MobileDeviceRegister200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MobileDeviceResponseDto),
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
    MobileDeviceRegister200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MobileDeviceRegister200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MobileDeviceResponseDto),
          ) as MobileDeviceResponseDto;
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
  MobileDeviceRegister200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MobileDeviceRegister200ResponseBuilder();
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

class MobileDeviceRegister200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MobileDeviceRegister200ResponseCodeEnum number0 = _$mobileDeviceRegister200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MobileDeviceRegister200ResponseCodeEnum unknownDefaultOpenApi = _$mobileDeviceRegister200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MobileDeviceRegister200ResponseCodeEnum> get serializer => _$mobileDeviceRegister200ResponseCodeEnumSerializer;

  const MobileDeviceRegister200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MobileDeviceRegister200ResponseCodeEnum> get values => _$mobileDeviceRegister200ResponseCodeEnumValues;
  static MobileDeviceRegister200ResponseCodeEnum valueOf(String name) => _$mobileDeviceRegister200ResponseCodeEnumValueOf(name);
}
