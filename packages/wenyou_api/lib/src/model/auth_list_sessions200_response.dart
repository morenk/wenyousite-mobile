//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/session_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_list_sessions200_response.g.dart';

/// AuthListSessions200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AuthListSessions200Response implements ApiSuccessEnvelope, Built<AuthListSessions200Response, AuthListSessions200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<SessionResponseDto> get data;

  AuthListSessions200Response._();

  factory AuthListSessions200Response([void updates(AuthListSessions200ResponseBuilder b)]) = _$AuthListSessions200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthListSessions200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthListSessions200Response> get serializer => _$AuthListSessions200ResponseSerializer();
}

class _$AuthListSessions200ResponseSerializer implements PrimitiveSerializer<AuthListSessions200Response> {
  @override
  final Iterable<Type> types = const [AuthListSessions200Response, _$AuthListSessions200Response];

  @override
  final String wireName = r'AuthListSessions200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthListSessions200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(SessionResponseDto)]),
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
    AuthListSessions200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthListSessions200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SessionResponseDto)]),
          ) as BuiltList<SessionResponseDto>;
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
  AuthListSessions200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthListSessions200ResponseBuilder();
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

class AuthListSessions200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AuthListSessions200ResponseCodeEnum number0 = _$authListSessions200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AuthListSessions200ResponseCodeEnum unknownDefaultOpenApi = _$authListSessions200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AuthListSessions200ResponseCodeEnum> get serializer => _$authListSessions200ResponseCodeEnumSerializer;

  const AuthListSessions200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AuthListSessions200ResponseCodeEnum> get values => _$authListSessions200ResponseCodeEnumValues;
  static AuthListSessions200ResponseCodeEnum valueOf(String name) => _$authListSessions200ResponseCodeEnumValueOf(name);
}
