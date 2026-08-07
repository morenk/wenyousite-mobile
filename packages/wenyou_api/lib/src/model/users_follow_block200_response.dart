//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_follow_block200_response.g.dart';

/// UsersFollowBlock200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersFollowBlock200Response implements ApiSuccessEnvelope, Built<UsersFollowBlock200Response, UsersFollowBlock200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  UsersFollowBlock200Response._();

  factory UsersFollowBlock200Response([void updates(UsersFollowBlock200ResponseBuilder b)]) = _$UsersFollowBlock200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersFollowBlock200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersFollowBlock200Response> get serializer => _$UsersFollowBlock200ResponseSerializer();
}

class _$UsersFollowBlock200ResponseSerializer implements PrimitiveSerializer<UsersFollowBlock200Response> {
  @override
  final Iterable<Type> types = const [UsersFollowBlock200Response, _$UsersFollowBlock200Response];

  @override
  final String wireName = r'UsersFollowBlock200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersFollowBlock200Response object, {
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
    UsersFollowBlock200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersFollowBlock200ResponseBuilder result,
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
  UsersFollowBlock200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersFollowBlock200ResponseBuilder();
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

class UsersFollowBlock200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersFollowBlock200ResponseCodeEnum number0 = _$usersFollowBlock200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersFollowBlock200ResponseCodeEnum unknownDefaultOpenApi = _$usersFollowBlock200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersFollowBlock200ResponseCodeEnum> get serializer => _$usersFollowBlock200ResponseCodeEnumSerializer;

  const UsersFollowBlock200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersFollowBlock200ResponseCodeEnum> get values => _$usersFollowBlock200ResponseCodeEnumValues;
  static UsersFollowBlock200ResponseCodeEnum valueOf(String name) => _$usersFollowBlock200ResponseCodeEnumValueOf(name);
}
