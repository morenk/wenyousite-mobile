//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/auth_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_refresh200_response.g.dart';

/// AuthRefresh200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AuthRefresh200Response implements ApiSuccessEnvelope, Built<AuthRefresh200Response, AuthRefresh200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AuthResponseDto get data;

  AuthRefresh200Response._();

  factory AuthRefresh200Response([void updates(AuthRefresh200ResponseBuilder b)]) = _$AuthRefresh200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthRefresh200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthRefresh200Response> get serializer => _$AuthRefresh200ResponseSerializer();
}

class _$AuthRefresh200ResponseSerializer implements PrimitiveSerializer<AuthRefresh200Response> {
  @override
  final Iterable<Type> types = const [AuthRefresh200Response, _$AuthRefresh200Response];

  @override
  final String wireName = r'AuthRefresh200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthRefresh200Response object, {
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
    AuthRefresh200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthRefresh200ResponseBuilder result,
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
  AuthRefresh200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthRefresh200ResponseBuilder();
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

class AuthRefresh200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AuthRefresh200ResponseCodeEnum number0 = _$authRefresh200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AuthRefresh200ResponseCodeEnum unknownDefaultOpenApi = _$authRefresh200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AuthRefresh200ResponseCodeEnum> get serializer => _$authRefresh200ResponseCodeEnumSerializer;

  const AuthRefresh200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AuthRefresh200ResponseCodeEnum> get values => _$authRefresh200ResponseCodeEnumValues;
  static AuthRefresh200ResponseCodeEnum valueOf(String name) => _$authRefresh200ResponseCodeEnumValueOf(name);
}
