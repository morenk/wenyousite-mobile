//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_challenge_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_auth_challenge200_response.g.dart';

/// AdminAuthChallenge200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminAuthChallenge200Response implements ApiSuccessEnvelope, Built<AdminAuthChallenge200Response, AdminAuthChallenge200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminChallengeResponseDto get data;

  AdminAuthChallenge200Response._();

  factory AdminAuthChallenge200Response([void updates(AdminAuthChallenge200ResponseBuilder b)]) = _$AdminAuthChallenge200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAuthChallenge200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAuthChallenge200Response> get serializer => _$AdminAuthChallenge200ResponseSerializer();
}

class _$AdminAuthChallenge200ResponseSerializer implements PrimitiveSerializer<AdminAuthChallenge200Response> {
  @override
  final Iterable<Type> types = const [AdminAuthChallenge200Response, _$AdminAuthChallenge200Response];

  @override
  final String wireName = r'AdminAuthChallenge200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAuthChallenge200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminChallengeResponseDto),
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
    AdminAuthChallenge200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAuthChallenge200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminChallengeResponseDto),
          ) as AdminChallengeResponseDto;
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
  AdminAuthChallenge200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAuthChallenge200ResponseBuilder();
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

class AdminAuthChallenge200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminAuthChallenge200ResponseCodeEnum number0 = _$adminAuthChallenge200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminAuthChallenge200ResponseCodeEnum unknownDefaultOpenApi = _$adminAuthChallenge200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminAuthChallenge200ResponseCodeEnum> get serializer => _$adminAuthChallenge200ResponseCodeEnumSerializer;

  const AdminAuthChallenge200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminAuthChallenge200ResponseCodeEnum> get values => _$adminAuthChallenge200ResponseCodeEnumValues;
  static AdminAuthChallenge200ResponseCodeEnum valueOf(String name) => _$adminAuthChallenge200ResponseCodeEnumValueOf(name);
}
