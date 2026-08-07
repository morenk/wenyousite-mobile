//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/user_follow_record_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_follow_followers200_response.g.dart';

/// UsersFollowFollowers200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersFollowFollowers200Response implements ApiSuccessEnvelope, Built<UsersFollowFollowers200Response, UsersFollowFollowers200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<UserFollowRecordResponseDto> get data;

  UsersFollowFollowers200Response._();

  factory UsersFollowFollowers200Response([void updates(UsersFollowFollowers200ResponseBuilder b)]) = _$UsersFollowFollowers200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersFollowFollowers200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersFollowFollowers200Response> get serializer => _$UsersFollowFollowers200ResponseSerializer();
}

class _$UsersFollowFollowers200ResponseSerializer implements PrimitiveSerializer<UsersFollowFollowers200Response> {
  @override
  final Iterable<Type> types = const [UsersFollowFollowers200Response, _$UsersFollowFollowers200Response];

  @override
  final String wireName = r'UsersFollowFollowers200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersFollowFollowers200Response object, {
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
    UsersFollowFollowers200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersFollowFollowers200ResponseBuilder result,
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
  UsersFollowFollowers200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersFollowFollowers200ResponseBuilder();
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

class UsersFollowFollowers200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersFollowFollowers200ResponseCodeEnum number0 = _$usersFollowFollowers200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersFollowFollowers200ResponseCodeEnum unknownDefaultOpenApi = _$usersFollowFollowers200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersFollowFollowers200ResponseCodeEnum> get serializer => _$usersFollowFollowers200ResponseCodeEnumSerializer;

  const UsersFollowFollowers200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersFollowFollowers200ResponseCodeEnum> get values => _$usersFollowFollowers200ResponseCodeEnumValues;
  static UsersFollowFollowers200ResponseCodeEnum valueOf(String name) => _$usersFollowFollowers200ResponseCodeEnumValueOf(name);
}
