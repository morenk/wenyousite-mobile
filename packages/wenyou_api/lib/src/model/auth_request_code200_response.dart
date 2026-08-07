//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/register_code_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_request_code200_response.g.dart';

/// AuthRequestCode200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AuthRequestCode200Response implements ApiSuccessEnvelope, Built<AuthRequestCode200Response, AuthRequestCode200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  RegisterCodeResponseDto get data;

  AuthRequestCode200Response._();

  factory AuthRequestCode200Response([void updates(AuthRequestCode200ResponseBuilder b)]) = _$AuthRequestCode200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthRequestCode200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthRequestCode200Response> get serializer => _$AuthRequestCode200ResponseSerializer();
}

class _$AuthRequestCode200ResponseSerializer implements PrimitiveSerializer<AuthRequestCode200Response> {
  @override
  final Iterable<Type> types = const [AuthRequestCode200Response, _$AuthRequestCode200Response];

  @override
  final String wireName = r'AuthRequestCode200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthRequestCode200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(RegisterCodeResponseDto),
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
    AuthRequestCode200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthRequestCode200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RegisterCodeResponseDto),
          ) as RegisterCodeResponseDto;
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
  AuthRequestCode200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthRequestCode200ResponseBuilder();
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

class AuthRequestCode200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AuthRequestCode200ResponseCodeEnum number0 = _$authRequestCode200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AuthRequestCode200ResponseCodeEnum unknownDefaultOpenApi = _$authRequestCode200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AuthRequestCode200ResponseCodeEnum> get serializer => _$authRequestCode200ResponseCodeEnumSerializer;

  const AuthRequestCode200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AuthRequestCode200ResponseCodeEnum> get values => _$authRequestCode200ResponseCodeEnumValues;
  static AuthRequestCode200ResponseCodeEnum valueOf(String name) => _$authRequestCode200ResponseCodeEnumValueOf(name);
}
