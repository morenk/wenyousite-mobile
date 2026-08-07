//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/mention_candidates_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_mention_candidates200_response.g.dart';

/// UsersMentionCandidates200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersMentionCandidates200Response implements ApiSuccessEnvelope, Built<UsersMentionCandidates200Response, UsersMentionCandidates200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MentionCandidatesResponseDto get data;

  UsersMentionCandidates200Response._();

  factory UsersMentionCandidates200Response([void updates(UsersMentionCandidates200ResponseBuilder b)]) = _$UsersMentionCandidates200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersMentionCandidates200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersMentionCandidates200Response> get serializer => _$UsersMentionCandidates200ResponseSerializer();
}

class _$UsersMentionCandidates200ResponseSerializer implements PrimitiveSerializer<UsersMentionCandidates200Response> {
  @override
  final Iterable<Type> types = const [UsersMentionCandidates200Response, _$UsersMentionCandidates200Response];

  @override
  final String wireName = r'UsersMentionCandidates200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersMentionCandidates200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MentionCandidatesResponseDto),
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
    UsersMentionCandidates200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersMentionCandidates200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MentionCandidatesResponseDto),
          ) as MentionCandidatesResponseDto;
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
  UsersMentionCandidates200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersMentionCandidates200ResponseBuilder();
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

class UsersMentionCandidates200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersMentionCandidates200ResponseCodeEnum number0 = _$usersMentionCandidates200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersMentionCandidates200ResponseCodeEnum unknownDefaultOpenApi = _$usersMentionCandidates200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersMentionCandidates200ResponseCodeEnum> get serializer => _$usersMentionCandidates200ResponseCodeEnumSerializer;

  const UsersMentionCandidates200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersMentionCandidates200ResponseCodeEnum> get values => _$usersMentionCandidates200ResponseCodeEnumValues;
  static UsersMentionCandidates200ResponseCodeEnum valueOf(String name) => _$usersMentionCandidates200ResponseCodeEnumValueOf(name);
}
