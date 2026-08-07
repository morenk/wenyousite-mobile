//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_verify_change_email200_response.g.dart';

/// AuthVerifyChangeEmail200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AuthVerifyChangeEmail200Response implements ApiSuccessEnvelope, Built<AuthVerifyChangeEmail200Response, AuthVerifyChangeEmail200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  AuthVerifyChangeEmail200Response._();

  factory AuthVerifyChangeEmail200Response([void updates(AuthVerifyChangeEmail200ResponseBuilder b)]) = _$AuthVerifyChangeEmail200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthVerifyChangeEmail200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthVerifyChangeEmail200Response> get serializer => _$AuthVerifyChangeEmail200ResponseSerializer();
}

class _$AuthVerifyChangeEmail200ResponseSerializer implements PrimitiveSerializer<AuthVerifyChangeEmail200Response> {
  @override
  final Iterable<Type> types = const [AuthVerifyChangeEmail200Response, _$AuthVerifyChangeEmail200Response];

  @override
  final String wireName = r'AuthVerifyChangeEmail200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthVerifyChangeEmail200Response object, {
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
    AuthVerifyChangeEmail200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthVerifyChangeEmail200ResponseBuilder result,
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
  AuthVerifyChangeEmail200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthVerifyChangeEmail200ResponseBuilder();
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

class AuthVerifyChangeEmail200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AuthVerifyChangeEmail200ResponseCodeEnum number0 = _$authVerifyChangeEmail200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AuthVerifyChangeEmail200ResponseCodeEnum unknownDefaultOpenApi = _$authVerifyChangeEmail200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AuthVerifyChangeEmail200ResponseCodeEnum> get serializer => _$authVerifyChangeEmail200ResponseCodeEnumSerializer;

  const AuthVerifyChangeEmail200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AuthVerifyChangeEmail200ResponseCodeEnum> get values => _$authVerifyChangeEmail200ResponseCodeEnumValues;
  static AuthVerifyChangeEmail200ResponseCodeEnum valueOf(String name) => _$authVerifyChangeEmail200ResponseCodeEnumValueOf(name);
}
