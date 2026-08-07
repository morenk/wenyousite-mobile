//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/private_user_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_update_me200_response.g.dart';

/// UsersUpdateMe200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersUpdateMe200Response implements ApiSuccessEnvelope, Built<UsersUpdateMe200Response, UsersUpdateMe200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PrivateUserResponseDto get data;

  UsersUpdateMe200Response._();

  factory UsersUpdateMe200Response([void updates(UsersUpdateMe200ResponseBuilder b)]) = _$UsersUpdateMe200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersUpdateMe200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersUpdateMe200Response> get serializer => _$UsersUpdateMe200ResponseSerializer();
}

class _$UsersUpdateMe200ResponseSerializer implements PrimitiveSerializer<UsersUpdateMe200Response> {
  @override
  final Iterable<Type> types = const [UsersUpdateMe200Response, _$UsersUpdateMe200Response];

  @override
  final String wireName = r'UsersUpdateMe200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersUpdateMe200Response object, {
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
    UsersUpdateMe200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersUpdateMe200ResponseBuilder result,
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
  UsersUpdateMe200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersUpdateMe200ResponseBuilder();
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

class UsersUpdateMe200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersUpdateMe200ResponseCodeEnum number0 = _$usersUpdateMe200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersUpdateMe200ResponseCodeEnum unknownDefaultOpenApi = _$usersUpdateMe200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersUpdateMe200ResponseCodeEnum> get serializer => _$usersUpdateMe200ResponseCodeEnumSerializer;

  const UsersUpdateMe200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersUpdateMe200ResponseCodeEnum> get values => _$usersUpdateMe200ResponseCodeEnumValues;
  static UsersUpdateMe200ResponseCodeEnum valueOf(String name) => _$usersUpdateMe200ResponseCodeEnumValueOf(name);
}
