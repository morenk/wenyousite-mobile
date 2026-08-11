//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/appeal_access_token_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_moderation_appeals_issue_token200_response.g.dart';

/// UserModerationAppealsIssueToken200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UserModerationAppealsIssueToken200Response implements ApiSuccessEnvelope, Built<UserModerationAppealsIssueToken200Response, UserModerationAppealsIssueToken200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AppealAccessTokenResponseDto get data;

  UserModerationAppealsIssueToken200Response._();

  factory UserModerationAppealsIssueToken200Response([void updates(UserModerationAppealsIssueToken200ResponseBuilder b)]) = _$UserModerationAppealsIssueToken200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserModerationAppealsIssueToken200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserModerationAppealsIssueToken200Response> get serializer => _$UserModerationAppealsIssueToken200ResponseSerializer();
}

class _$UserModerationAppealsIssueToken200ResponseSerializer implements PrimitiveSerializer<UserModerationAppealsIssueToken200Response> {
  @override
  final Iterable<Type> types = const [UserModerationAppealsIssueToken200Response, _$UserModerationAppealsIssueToken200Response];

  @override
  final String wireName = r'UserModerationAppealsIssueToken200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserModerationAppealsIssueToken200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AppealAccessTokenResponseDto),
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
    UserModerationAppealsIssueToken200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserModerationAppealsIssueToken200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AppealAccessTokenResponseDto),
          ) as AppealAccessTokenResponseDto;
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
  UserModerationAppealsIssueToken200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserModerationAppealsIssueToken200ResponseBuilder();
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

class UserModerationAppealsIssueToken200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UserModerationAppealsIssueToken200ResponseCodeEnum number0 = _$userModerationAppealsIssueToken200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UserModerationAppealsIssueToken200ResponseCodeEnum unknownDefaultOpenApi = _$userModerationAppealsIssueToken200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UserModerationAppealsIssueToken200ResponseCodeEnum> get serializer => _$userModerationAppealsIssueToken200ResponseCodeEnumSerializer;

  const UserModerationAppealsIssueToken200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UserModerationAppealsIssueToken200ResponseCodeEnum> get values => _$userModerationAppealsIssueToken200ResponseCodeEnumValues;
  static UserModerationAppealsIssueToken200ResponseCodeEnum valueOf(String name) => _$userModerationAppealsIssueToken200ResponseCodeEnumValueOf(name);
}
