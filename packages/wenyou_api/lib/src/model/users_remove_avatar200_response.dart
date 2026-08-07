//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/private_user_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_remove_avatar200_response.g.dart';

/// UsersRemoveAvatar200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersRemoveAvatar200Response implements ApiSuccessEnvelope, Built<UsersRemoveAvatar200Response, UsersRemoveAvatar200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PrivateUserResponseDto get data;

  UsersRemoveAvatar200Response._();

  factory UsersRemoveAvatar200Response([void updates(UsersRemoveAvatar200ResponseBuilder b)]) = _$UsersRemoveAvatar200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersRemoveAvatar200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersRemoveAvatar200Response> get serializer => _$UsersRemoveAvatar200ResponseSerializer();
}

class _$UsersRemoveAvatar200ResponseSerializer implements PrimitiveSerializer<UsersRemoveAvatar200Response> {
  @override
  final Iterable<Type> types = const [UsersRemoveAvatar200Response, _$UsersRemoveAvatar200Response];

  @override
  final String wireName = r'UsersRemoveAvatar200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersRemoveAvatar200Response object, {
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
    UsersRemoveAvatar200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersRemoveAvatar200ResponseBuilder result,
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
  UsersRemoveAvatar200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersRemoveAvatar200ResponseBuilder();
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

class UsersRemoveAvatar200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersRemoveAvatar200ResponseCodeEnum number0 = _$usersRemoveAvatar200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersRemoveAvatar200ResponseCodeEnum unknownDefaultOpenApi = _$usersRemoveAvatar200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersRemoveAvatar200ResponseCodeEnum> get serializer => _$usersRemoveAvatar200ResponseCodeEnumSerializer;

  const UsersRemoveAvatar200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersRemoveAvatar200ResponseCodeEnum> get values => _$usersRemoveAvatar200ResponseCodeEnumValues;
  static UsersRemoveAvatar200ResponseCodeEnum valueOf(String name) => _$usersRemoveAvatar200ResponseCodeEnumValueOf(name);
}
