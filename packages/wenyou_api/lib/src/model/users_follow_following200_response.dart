//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/user_follow_record_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_follow_following200_response.g.dart';

/// UsersFollowFollowing200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersFollowFollowing200Response implements ApiSuccessEnvelope, Built<UsersFollowFollowing200Response, UsersFollowFollowing200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<UserFollowRecordResponseDto> get data;

  UsersFollowFollowing200Response._();

  factory UsersFollowFollowing200Response([void updates(UsersFollowFollowing200ResponseBuilder b)]) = _$UsersFollowFollowing200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersFollowFollowing200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersFollowFollowing200Response> get serializer => _$UsersFollowFollowing200ResponseSerializer();
}

class _$UsersFollowFollowing200ResponseSerializer implements PrimitiveSerializer<UsersFollowFollowing200Response> {
  @override
  final Iterable<Type> types = const [UsersFollowFollowing200Response, _$UsersFollowFollowing200Response];

  @override
  final String wireName = r'UsersFollowFollowing200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersFollowFollowing200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(UserFollowRecordResponseDto)]),
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
    UsersFollowFollowing200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersFollowFollowing200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(UserFollowRecordResponseDto)]),
          ) as BuiltList<UserFollowRecordResponseDto>;
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
  UsersFollowFollowing200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersFollowFollowing200ResponseBuilder();
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

class UsersFollowFollowing200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersFollowFollowing200ResponseCodeEnum number0 = _$usersFollowFollowing200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersFollowFollowing200ResponseCodeEnum unknownDefaultOpenApi = _$usersFollowFollowing200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersFollowFollowing200ResponseCodeEnum> get serializer => _$usersFollowFollowing200ResponseCodeEnumSerializer;

  const UsersFollowFollowing200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersFollowFollowing200ResponseCodeEnum> get values => _$usersFollowFollowing200ResponseCodeEnumValues;
  static UsersFollowFollowing200ResponseCodeEnum valueOf(String name) => _$usersFollowFollowing200ResponseCodeEnumValueOf(name);
}
