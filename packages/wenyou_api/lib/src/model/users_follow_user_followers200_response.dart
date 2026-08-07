//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/user_follow_record_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_follow_user_followers200_response.g.dart';

/// UsersFollowUserFollowers200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersFollowUserFollowers200Response implements ApiSuccessEnvelope, Built<UsersFollowUserFollowers200Response, UsersFollowUserFollowers200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<UserFollowRecordResponseDto> get data;

  UsersFollowUserFollowers200Response._();

  factory UsersFollowUserFollowers200Response([void updates(UsersFollowUserFollowers200ResponseBuilder b)]) = _$UsersFollowUserFollowers200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersFollowUserFollowers200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersFollowUserFollowers200Response> get serializer => _$UsersFollowUserFollowers200ResponseSerializer();
}

class _$UsersFollowUserFollowers200ResponseSerializer implements PrimitiveSerializer<UsersFollowUserFollowers200Response> {
  @override
  final Iterable<Type> types = const [UsersFollowUserFollowers200Response, _$UsersFollowUserFollowers200Response];

  @override
  final String wireName = r'UsersFollowUserFollowers200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersFollowUserFollowers200Response object, {
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
    UsersFollowUserFollowers200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersFollowUserFollowers200ResponseBuilder result,
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
  UsersFollowUserFollowers200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersFollowUserFollowers200ResponseBuilder();
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

class UsersFollowUserFollowers200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersFollowUserFollowers200ResponseCodeEnum number0 = _$usersFollowUserFollowers200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersFollowUserFollowers200ResponseCodeEnum unknownDefaultOpenApi = _$usersFollowUserFollowers200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersFollowUserFollowers200ResponseCodeEnum> get serializer => _$usersFollowUserFollowers200ResponseCodeEnumSerializer;

  const UsersFollowUserFollowers200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersFollowUserFollowers200ResponseCodeEnum> get values => _$usersFollowUserFollowers200ResponseCodeEnumValues;
  static UsersFollowUserFollowers200ResponseCodeEnum valueOf(String name) => _$usersFollowUserFollowers200ResponseCodeEnumValueOf(name);
}
