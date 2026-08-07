//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mobile_device_unregister200_response.g.dart';

/// MobileDeviceUnregister200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MobileDeviceUnregister200Response implements ApiSuccessEnvelope, Built<MobileDeviceUnregister200Response, MobileDeviceUnregister200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  MobileDeviceUnregister200Response._();

  factory MobileDeviceUnregister200Response([void updates(MobileDeviceUnregister200ResponseBuilder b)]) = _$MobileDeviceUnregister200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MobileDeviceUnregister200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MobileDeviceUnregister200Response> get serializer => _$MobileDeviceUnregister200ResponseSerializer();
}

class _$MobileDeviceUnregister200ResponseSerializer implements PrimitiveSerializer<MobileDeviceUnregister200Response> {
  @override
  final Iterable<Type> types = const [MobileDeviceUnregister200Response, _$MobileDeviceUnregister200Response];

  @override
  final String wireName = r'MobileDeviceUnregister200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MobileDeviceUnregister200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MessageResponseDto),
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
    MobileDeviceUnregister200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MobileDeviceUnregister200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MessageResponseDto),
          ) as MessageResponseDto;
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
  MobileDeviceUnregister200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MobileDeviceUnregister200ResponseBuilder();
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

class MobileDeviceUnregister200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MobileDeviceUnregister200ResponseCodeEnum number0 = _$mobileDeviceUnregister200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MobileDeviceUnregister200ResponseCodeEnum unknownDefaultOpenApi = _$mobileDeviceUnregister200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MobileDeviceUnregister200ResponseCodeEnum> get serializer => _$mobileDeviceUnregister200ResponseCodeEnumSerializer;

  const MobileDeviceUnregister200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MobileDeviceUnregister200ResponseCodeEnum> get values => _$mobileDeviceUnregister200ResponseCodeEnumValues;
  static MobileDeviceUnregister200ResponseCodeEnum valueOf(String name) => _$mobileDeviceUnregister200ResponseCodeEnumValueOf(name);
}
