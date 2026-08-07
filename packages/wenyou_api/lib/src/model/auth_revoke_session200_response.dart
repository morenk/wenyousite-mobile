//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/revoke_session_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_revoke_session200_response.g.dart';

/// AuthRevokeSession200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AuthRevokeSession200Response implements ApiSuccessEnvelope, Built<AuthRevokeSession200Response, AuthRevokeSession200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  RevokeSessionResponseDto get data;

  AuthRevokeSession200Response._();

  factory AuthRevokeSession200Response([void updates(AuthRevokeSession200ResponseBuilder b)]) = _$AuthRevokeSession200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthRevokeSession200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthRevokeSession200Response> get serializer => _$AuthRevokeSession200ResponseSerializer();
}

class _$AuthRevokeSession200ResponseSerializer implements PrimitiveSerializer<AuthRevokeSession200Response> {
  @override
  final Iterable<Type> types = const [AuthRevokeSession200Response, _$AuthRevokeSession200Response];

  @override
  final String wireName = r'AuthRevokeSession200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthRevokeSession200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(RevokeSessionResponseDto),
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
    AuthRevokeSession200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthRevokeSession200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RevokeSessionResponseDto),
          ) as RevokeSessionResponseDto;
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
  AuthRevokeSession200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthRevokeSession200ResponseBuilder();
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

class AuthRevokeSession200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AuthRevokeSession200ResponseCodeEnum number0 = _$authRevokeSession200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AuthRevokeSession200ResponseCodeEnum unknownDefaultOpenApi = _$authRevokeSession200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AuthRevokeSession200ResponseCodeEnum> get serializer => _$authRevokeSession200ResponseCodeEnumSerializer;

  const AuthRevokeSession200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AuthRevokeSession200ResponseCodeEnum> get values => _$authRevokeSession200ResponseCodeEnumValues;
  static AuthRevokeSession200ResponseCodeEnum valueOf(String name) => _$authRevokeSession200ResponseCodeEnumValueOf(name);
}
