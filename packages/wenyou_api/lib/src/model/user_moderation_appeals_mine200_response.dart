//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/moderation_decision_public_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_moderation_appeals_mine200_response.g.dart';

/// UserModerationAppealsMine200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UserModerationAppealsMine200Response implements ApiSuccessEnvelope, Built<UserModerationAppealsMine200Response, UserModerationAppealsMine200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ModerationDecisionPublicResponseDto> get data;

  UserModerationAppealsMine200Response._();

  factory UserModerationAppealsMine200Response([void updates(UserModerationAppealsMine200ResponseBuilder b)]) = _$UserModerationAppealsMine200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserModerationAppealsMine200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserModerationAppealsMine200Response> get serializer => _$UserModerationAppealsMine200ResponseSerializer();
}

class _$UserModerationAppealsMine200ResponseSerializer implements PrimitiveSerializer<UserModerationAppealsMine200Response> {
  @override
  final Iterable<Type> types = const [UserModerationAppealsMine200Response, _$UserModerationAppealsMine200Response];

  @override
  final String wireName = r'UserModerationAppealsMine200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserModerationAppealsMine200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(ModerationDecisionPublicResponseDto)]),
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
    UserModerationAppealsMine200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserModerationAppealsMine200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ModerationDecisionPublicResponseDto)]),
          ) as BuiltList<ModerationDecisionPublicResponseDto>;
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
  UserModerationAppealsMine200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserModerationAppealsMine200ResponseBuilder();
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

class UserModerationAppealsMine200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UserModerationAppealsMine200ResponseCodeEnum number0 = _$userModerationAppealsMine200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UserModerationAppealsMine200ResponseCodeEnum unknownDefaultOpenApi = _$userModerationAppealsMine200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UserModerationAppealsMine200ResponseCodeEnum> get serializer => _$userModerationAppealsMine200ResponseCodeEnumSerializer;

  const UserModerationAppealsMine200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UserModerationAppealsMine200ResponseCodeEnum> get values => _$userModerationAppealsMine200ResponseCodeEnumValues;
  static UserModerationAppealsMine200ResponseCodeEnum valueOf(String name) => _$userModerationAppealsMine200ResponseCodeEnumValueOf(name);
}
