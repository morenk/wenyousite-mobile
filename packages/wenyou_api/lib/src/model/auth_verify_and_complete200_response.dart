//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/auth_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_verify_and_complete200_response.g.dart';

/// AuthVerifyAndComplete200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AuthVerifyAndComplete200Response implements ApiSuccessEnvelope, Built<AuthVerifyAndComplete200Response, AuthVerifyAndComplete200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AuthResponseDto get data;

  AuthVerifyAndComplete200Response._();

  factory AuthVerifyAndComplete200Response([void updates(AuthVerifyAndComplete200ResponseBuilder b)]) = _$AuthVerifyAndComplete200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthVerifyAndComplete200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthVerifyAndComplete200Response> get serializer => _$AuthVerifyAndComplete200ResponseSerializer();
}

class _$AuthVerifyAndComplete200ResponseSerializer implements PrimitiveSerializer<AuthVerifyAndComplete200Response> {
  @override
  final Iterable<Type> types = const [AuthVerifyAndComplete200Response, _$AuthVerifyAndComplete200Response];

  @override
  final String wireName = r'AuthVerifyAndComplete200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthVerifyAndComplete200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AuthResponseDto),
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
    AuthVerifyAndComplete200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthVerifyAndComplete200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthResponseDto),
          ) as AuthResponseDto;
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
  AuthVerifyAndComplete200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthVerifyAndComplete200ResponseBuilder();
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

class AuthVerifyAndComplete200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AuthVerifyAndComplete200ResponseCodeEnum number0 = _$authVerifyAndComplete200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AuthVerifyAndComplete200ResponseCodeEnum unknownDefaultOpenApi = _$authVerifyAndComplete200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AuthVerifyAndComplete200ResponseCodeEnum> get serializer => _$authVerifyAndComplete200ResponseCodeEnumSerializer;

  const AuthVerifyAndComplete200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AuthVerifyAndComplete200ResponseCodeEnum> get values => _$authVerifyAndComplete200ResponseCodeEnumValues;
  static AuthVerifyAndComplete200ResponseCodeEnum valueOf(String name) => _$authVerifyAndComplete200ResponseCodeEnumValueOf(name);
}
