//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_verify_email200_response.g.dart';

/// AuthVerifyEmail200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AuthVerifyEmail200Response implements ApiSuccessEnvelope, Built<AuthVerifyEmail200Response, AuthVerifyEmail200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  AuthVerifyEmail200Response._();

  factory AuthVerifyEmail200Response([void updates(AuthVerifyEmail200ResponseBuilder b)]) = _$AuthVerifyEmail200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthVerifyEmail200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthVerifyEmail200Response> get serializer => _$AuthVerifyEmail200ResponseSerializer();
}

class _$AuthVerifyEmail200ResponseSerializer implements PrimitiveSerializer<AuthVerifyEmail200Response> {
  @override
  final Iterable<Type> types = const [AuthVerifyEmail200Response, _$AuthVerifyEmail200Response];

  @override
  final String wireName = r'AuthVerifyEmail200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthVerifyEmail200Response object, {
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
    AuthVerifyEmail200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthVerifyEmail200ResponseBuilder result,
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
  AuthVerifyEmail200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthVerifyEmail200ResponseBuilder();
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

class AuthVerifyEmail200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AuthVerifyEmail200ResponseCodeEnum number0 = _$authVerifyEmail200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AuthVerifyEmail200ResponseCodeEnum unknownDefaultOpenApi = _$authVerifyEmail200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AuthVerifyEmail200ResponseCodeEnum> get serializer => _$authVerifyEmail200ResponseCodeEnumSerializer;

  const AuthVerifyEmail200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AuthVerifyEmail200ResponseCodeEnum> get values => _$authVerifyEmail200ResponseCodeEnumValues;
  static AuthVerifyEmail200ResponseCodeEnum valueOf(String name) => _$authVerifyEmail200ResponseCodeEnumValueOf(name);
}
