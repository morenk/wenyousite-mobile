//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_logout200_response.g.dart';

/// AuthLogout200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AuthLogout200Response implements ApiSuccessEnvelope, Built<AuthLogout200Response, AuthLogout200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  AuthLogout200Response._();

  factory AuthLogout200Response([void updates(AuthLogout200ResponseBuilder b)]) = _$AuthLogout200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthLogout200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthLogout200Response> get serializer => _$AuthLogout200ResponseSerializer();
}

class _$AuthLogout200ResponseSerializer implements PrimitiveSerializer<AuthLogout200Response> {
  @override
  final Iterable<Type> types = const [AuthLogout200Response, _$AuthLogout200Response];

  @override
  final String wireName = r'AuthLogout200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthLogout200Response object, {
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
    AuthLogout200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthLogout200ResponseBuilder result,
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
  AuthLogout200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthLogout200ResponseBuilder();
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

class AuthLogout200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AuthLogout200ResponseCodeEnum number0 = _$authLogout200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AuthLogout200ResponseCodeEnum unknownDefaultOpenApi = _$authLogout200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AuthLogout200ResponseCodeEnum> get serializer => _$authLogout200ResponseCodeEnumSerializer;

  const AuthLogout200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AuthLogout200ResponseCodeEnum> get values => _$authLogout200ResponseCodeEnumValues;
  static AuthLogout200ResponseCodeEnum valueOf(String name) => _$authLogout200ResponseCodeEnumValueOf(name);
}
