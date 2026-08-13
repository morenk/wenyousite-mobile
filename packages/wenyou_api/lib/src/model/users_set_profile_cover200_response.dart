//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/private_user_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_set_profile_cover200_response.g.dart';

/// UsersSetProfileCover200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersSetProfileCover200Response implements ApiSuccessEnvelope, Built<UsersSetProfileCover200Response, UsersSetProfileCover200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PrivateUserResponseDto get data;

  UsersSetProfileCover200Response._();

  factory UsersSetProfileCover200Response([void updates(UsersSetProfileCover200ResponseBuilder b)]) = _$UsersSetProfileCover200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersSetProfileCover200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersSetProfileCover200Response> get serializer => _$UsersSetProfileCover200ResponseSerializer();
}

class _$UsersSetProfileCover200ResponseSerializer implements PrimitiveSerializer<UsersSetProfileCover200Response> {
  @override
  final Iterable<Type> types = const [UsersSetProfileCover200Response, _$UsersSetProfileCover200Response];

  @override
  final String wireName = r'UsersSetProfileCover200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersSetProfileCover200Response object, {
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
    UsersSetProfileCover200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersSetProfileCover200ResponseBuilder result,
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
  UsersSetProfileCover200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersSetProfileCover200ResponseBuilder();
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

class UsersSetProfileCover200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersSetProfileCover200ResponseCodeEnum number0 = _$usersSetProfileCover200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersSetProfileCover200ResponseCodeEnum unknownDefaultOpenApi = _$usersSetProfileCover200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersSetProfileCover200ResponseCodeEnum> get serializer => _$usersSetProfileCover200ResponseCodeEnumSerializer;

  const UsersSetProfileCover200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersSetProfileCover200ResponseCodeEnum> get values => _$usersSetProfileCover200ResponseCodeEnumValues;
  static UsersSetProfileCover200ResponseCodeEnum valueOf(String name) => _$usersSetProfileCover200ResponseCodeEnumValueOf(name);
}
