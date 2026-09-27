//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_follow_remove_follower200_response.g.dart';

/// UsersFollowRemoveFollower200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersFollowRemoveFollower200Response implements ApiSuccessEnvelope, Built<UsersFollowRemoveFollower200Response, UsersFollowRemoveFollower200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  UsersFollowRemoveFollower200Response._();

  factory UsersFollowRemoveFollower200Response([void updates(UsersFollowRemoveFollower200ResponseBuilder b)]) = _$UsersFollowRemoveFollower200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersFollowRemoveFollower200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersFollowRemoveFollower200Response> get serializer => _$UsersFollowRemoveFollower200ResponseSerializer();
}

class _$UsersFollowRemoveFollower200ResponseSerializer implements PrimitiveSerializer<UsersFollowRemoveFollower200Response> {
  @override
  final Iterable<Type> types = const [UsersFollowRemoveFollower200Response, _$UsersFollowRemoveFollower200Response];

  @override
  final String wireName = r'UsersFollowRemoveFollower200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersFollowRemoveFollower200Response object, {
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
    UsersFollowRemoveFollower200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersFollowRemoveFollower200ResponseBuilder result,
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
  UsersFollowRemoveFollower200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersFollowRemoveFollower200ResponseBuilder();
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

class UsersFollowRemoveFollower200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersFollowRemoveFollower200ResponseCodeEnum number0 = _$usersFollowRemoveFollower200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersFollowRemoveFollower200ResponseCodeEnum unknownDefaultOpenApi = _$usersFollowRemoveFollower200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersFollowRemoveFollower200ResponseCodeEnum> get serializer => _$usersFollowRemoveFollower200ResponseCodeEnumSerializer;

  const UsersFollowRemoveFollower200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersFollowRemoveFollower200ResponseCodeEnum> get values => _$usersFollowRemoveFollower200ResponseCodeEnumValues;
  static UsersFollowRemoveFollower200ResponseCodeEnum valueOf(String name) => _$usersFollowRemoveFollower200ResponseCodeEnumValueOf(name);
}
