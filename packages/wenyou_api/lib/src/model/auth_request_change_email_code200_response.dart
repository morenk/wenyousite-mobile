//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_request_change_email_code200_response.g.dart';

/// AuthRequestChangeEmailCode200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AuthRequestChangeEmailCode200Response implements ApiSuccessEnvelope, Built<AuthRequestChangeEmailCode200Response, AuthRequestChangeEmailCode200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  AuthRequestChangeEmailCode200Response._();

  factory AuthRequestChangeEmailCode200Response([void updates(AuthRequestChangeEmailCode200ResponseBuilder b)]) = _$AuthRequestChangeEmailCode200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthRequestChangeEmailCode200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthRequestChangeEmailCode200Response> get serializer => _$AuthRequestChangeEmailCode200ResponseSerializer();
}

class _$AuthRequestChangeEmailCode200ResponseSerializer implements PrimitiveSerializer<AuthRequestChangeEmailCode200Response> {
  @override
  final Iterable<Type> types = const [AuthRequestChangeEmailCode200Response, _$AuthRequestChangeEmailCode200Response];

  @override
  final String wireName = r'AuthRequestChangeEmailCode200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthRequestChangeEmailCode200Response object, {
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
    AuthRequestChangeEmailCode200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthRequestChangeEmailCode200ResponseBuilder result,
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
  AuthRequestChangeEmailCode200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthRequestChangeEmailCode200ResponseBuilder();
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

class AuthRequestChangeEmailCode200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AuthRequestChangeEmailCode200ResponseCodeEnum number0 = _$authRequestChangeEmailCode200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AuthRequestChangeEmailCode200ResponseCodeEnum unknownDefaultOpenApi = _$authRequestChangeEmailCode200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AuthRequestChangeEmailCode200ResponseCodeEnum> get serializer => _$authRequestChangeEmailCode200ResponseCodeEnumSerializer;

  const AuthRequestChangeEmailCode200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AuthRequestChangeEmailCode200ResponseCodeEnum> get values => _$authRequestChangeEmailCode200ResponseCodeEnumValues;
  static AuthRequestChangeEmailCode200ResponseCodeEnum valueOf(String name) => _$authRequestChangeEmailCode200ResponseCodeEnumValueOf(name);
}
