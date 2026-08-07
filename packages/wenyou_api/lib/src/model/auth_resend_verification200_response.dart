//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_resend_verification200_response.g.dart';

/// AuthResendVerification200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AuthResendVerification200Response implements ApiSuccessEnvelope, Built<AuthResendVerification200Response, AuthResendVerification200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  AuthResendVerification200Response._();

  factory AuthResendVerification200Response([void updates(AuthResendVerification200ResponseBuilder b)]) = _$AuthResendVerification200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthResendVerification200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthResendVerification200Response> get serializer => _$AuthResendVerification200ResponseSerializer();
}

class _$AuthResendVerification200ResponseSerializer implements PrimitiveSerializer<AuthResendVerification200Response> {
  @override
  final Iterable<Type> types = const [AuthResendVerification200Response, _$AuthResendVerification200Response];

  @override
  final String wireName = r'AuthResendVerification200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthResendVerification200Response object, {
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
    AuthResendVerification200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthResendVerification200ResponseBuilder result,
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
  AuthResendVerification200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthResendVerification200ResponseBuilder();
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

class AuthResendVerification200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AuthResendVerification200ResponseCodeEnum number0 = _$authResendVerification200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AuthResendVerification200ResponseCodeEnum unknownDefaultOpenApi = _$authResendVerification200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AuthResendVerification200ResponseCodeEnum> get serializer => _$authResendVerification200ResponseCodeEnumSerializer;

  const AuthResendVerification200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AuthResendVerification200ResponseCodeEnum> get values => _$authResendVerification200ResponseCodeEnumValues;
  static AuthResendVerification200ResponseCodeEnum valueOf(String name) => _$authResendVerification200ResponseCodeEnumValueOf(name);
}
