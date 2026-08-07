//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_reset_password200_response.g.dart';

/// AuthResetPassword200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AuthResetPassword200Response implements ApiSuccessEnvelope, Built<AuthResetPassword200Response, AuthResetPassword200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  AuthResetPassword200Response._();

  factory AuthResetPassword200Response([void updates(AuthResetPassword200ResponseBuilder b)]) = _$AuthResetPassword200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthResetPassword200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthResetPassword200Response> get serializer => _$AuthResetPassword200ResponseSerializer();
}

class _$AuthResetPassword200ResponseSerializer implements PrimitiveSerializer<AuthResetPassword200Response> {
  @override
  final Iterable<Type> types = const [AuthResetPassword200Response, _$AuthResetPassword200Response];

  @override
  final String wireName = r'AuthResetPassword200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthResetPassword200Response object, {
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
    AuthResetPassword200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthResetPassword200ResponseBuilder result,
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
  AuthResetPassword200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthResetPassword200ResponseBuilder();
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

class AuthResetPassword200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AuthResetPassword200ResponseCodeEnum number0 = _$authResetPassword200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AuthResetPassword200ResponseCodeEnum unknownDefaultOpenApi = _$authResetPassword200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AuthResetPassword200ResponseCodeEnum> get serializer => _$authResetPassword200ResponseCodeEnumSerializer;

  const AuthResetPassword200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AuthResetPassword200ResponseCodeEnum> get values => _$authResetPassword200ResponseCodeEnumValues;
  static AuthResetPassword200ResponseCodeEnum valueOf(String name) => _$authResetPassword200ResponseCodeEnumValueOf(name);
}
