//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/private_user_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_set_avatar200_response.g.dart';

/// UsersSetAvatar200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersSetAvatar200Response implements ApiSuccessEnvelope, Built<UsersSetAvatar200Response, UsersSetAvatar200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PrivateUserResponseDto get data;

  UsersSetAvatar200Response._();

  factory UsersSetAvatar200Response([void updates(UsersSetAvatar200ResponseBuilder b)]) = _$UsersSetAvatar200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersSetAvatar200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersSetAvatar200Response> get serializer => _$UsersSetAvatar200ResponseSerializer();
}

class _$UsersSetAvatar200ResponseSerializer implements PrimitiveSerializer<UsersSetAvatar200Response> {
  @override
  final Iterable<Type> types = const [UsersSetAvatar200Response, _$UsersSetAvatar200Response];

  @override
  final String wireName = r'UsersSetAvatar200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersSetAvatar200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PrivateUserResponseDto),
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
    UsersSetAvatar200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersSetAvatar200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrivateUserResponseDto),
          ) as PrivateUserResponseDto;
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
  UsersSetAvatar200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersSetAvatar200ResponseBuilder();
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

class UsersSetAvatar200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersSetAvatar200ResponseCodeEnum number0 = _$usersSetAvatar200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersSetAvatar200ResponseCodeEnum unknownDefaultOpenApi = _$usersSetAvatar200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersSetAvatar200ResponseCodeEnum> get serializer => _$usersSetAvatar200ResponseCodeEnumSerializer;

  const UsersSetAvatar200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersSetAvatar200ResponseCodeEnum> get values => _$usersSetAvatar200ResponseCodeEnumValues;
  static UsersSetAvatar200ResponseCodeEnum valueOf(String name) => _$usersSetAvatar200ResponseCodeEnumValueOf(name);
}
