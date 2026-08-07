//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/auth_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_login200_response.g.dart';

/// AuthLogin200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AuthLogin200Response implements ApiSuccessEnvelope, Built<AuthLogin200Response, AuthLogin200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AuthResponseDto get data;

  AuthLogin200Response._();

  factory AuthLogin200Response([void updates(AuthLogin200ResponseBuilder b)]) = _$AuthLogin200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthLogin200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthLogin200Response> get serializer => _$AuthLogin200ResponseSerializer();
}

class _$AuthLogin200ResponseSerializer implements PrimitiveSerializer<AuthLogin200Response> {
  @override
  final Iterable<Type> types = const [AuthLogin200Response, _$AuthLogin200Response];

  @override
  final String wireName = r'AuthLogin200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthLogin200Response object, {
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
    AuthLogin200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthLogin200ResponseBuilder result,
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
  AuthLogin200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthLogin200ResponseBuilder();
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

class AuthLogin200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AuthLogin200ResponseCodeEnum number0 = _$authLogin200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AuthLogin200ResponseCodeEnum unknownDefaultOpenApi = _$authLogin200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AuthLogin200ResponseCodeEnum> get serializer => _$authLogin200ResponseCodeEnumSerializer;

  const AuthLogin200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AuthLogin200ResponseCodeEnum> get values => _$authLogin200ResponseCodeEnumValues;
  static AuthLogin200ResponseCodeEnum valueOf(String name) => _$authLogin200ResponseCodeEnumValueOf(name);
}
