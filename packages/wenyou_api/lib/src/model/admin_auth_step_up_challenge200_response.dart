//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_challenge_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_auth_step_up_challenge200_response.g.dart';

/// AdminAuthStepUpChallenge200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminAuthStepUpChallenge200Response implements ApiSuccessEnvelope, Built<AdminAuthStepUpChallenge200Response, AdminAuthStepUpChallenge200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminChallengeResponseDto get data;

  AdminAuthStepUpChallenge200Response._();

  factory AdminAuthStepUpChallenge200Response([void updates(AdminAuthStepUpChallenge200ResponseBuilder b)]) = _$AdminAuthStepUpChallenge200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAuthStepUpChallenge200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAuthStepUpChallenge200Response> get serializer => _$AdminAuthStepUpChallenge200ResponseSerializer();
}

class _$AdminAuthStepUpChallenge200ResponseSerializer implements PrimitiveSerializer<AdminAuthStepUpChallenge200Response> {
  @override
  final Iterable<Type> types = const [AdminAuthStepUpChallenge200Response, _$AdminAuthStepUpChallenge200Response];

  @override
  final String wireName = r'AdminAuthStepUpChallenge200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAuthStepUpChallenge200Response object, {
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
    AdminAuthStepUpChallenge200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAuthStepUpChallenge200ResponseBuilder result,
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
  AdminAuthStepUpChallenge200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAuthStepUpChallenge200ResponseBuilder();
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

class AdminAuthStepUpChallenge200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminAuthStepUpChallenge200ResponseCodeEnum number0 = _$adminAuthStepUpChallenge200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminAuthStepUpChallenge200ResponseCodeEnum unknownDefaultOpenApi = _$adminAuthStepUpChallenge200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminAuthStepUpChallenge200ResponseCodeEnum> get serializer => _$adminAuthStepUpChallenge200ResponseCodeEnumSerializer;

  const AdminAuthStepUpChallenge200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminAuthStepUpChallenge200ResponseCodeEnum> get values => _$adminAuthStepUpChallenge200ResponseCodeEnumValues;
  static AdminAuthStepUpChallenge200ResponseCodeEnum valueOf(String name) => _$adminAuthStepUpChallenge200ResponseCodeEnumValueOf(name);
}
