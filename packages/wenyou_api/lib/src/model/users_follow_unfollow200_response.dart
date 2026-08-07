//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_follow_unfollow200_response.g.dart';

/// UsersFollowUnfollow200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersFollowUnfollow200Response implements ApiSuccessEnvelope, Built<UsersFollowUnfollow200Response, UsersFollowUnfollow200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  UsersFollowUnfollow200Response._();

  factory UsersFollowUnfollow200Response([void updates(UsersFollowUnfollow200ResponseBuilder b)]) = _$UsersFollowUnfollow200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersFollowUnfollow200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersFollowUnfollow200Response> get serializer => _$UsersFollowUnfollow200ResponseSerializer();
}

class _$UsersFollowUnfollow200ResponseSerializer implements PrimitiveSerializer<UsersFollowUnfollow200Response> {
  @override
  final Iterable<Type> types = const [UsersFollowUnfollow200Response, _$UsersFollowUnfollow200Response];

  @override
  final String wireName = r'UsersFollowUnfollow200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersFollowUnfollow200Response object, {
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
    UsersFollowUnfollow200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersFollowUnfollow200ResponseBuilder result,
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
  UsersFollowUnfollow200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersFollowUnfollow200ResponseBuilder();
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

class UsersFollowUnfollow200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersFollowUnfollow200ResponseCodeEnum number0 = _$usersFollowUnfollow200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersFollowUnfollow200ResponseCodeEnum unknownDefaultOpenApi = _$usersFollowUnfollow200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersFollowUnfollow200ResponseCodeEnum> get serializer => _$usersFollowUnfollow200ResponseCodeEnumSerializer;

  const UsersFollowUnfollow200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersFollowUnfollow200ResponseCodeEnum> get values => _$usersFollowUnfollow200ResponseCodeEnumValues;
  static UsersFollowUnfollow200ResponseCodeEnum valueOf(String name) => _$usersFollowUnfollow200ResponseCodeEnumValueOf(name);
}
