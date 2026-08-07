//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/public_user_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_get_user200_response.g.dart';

/// UsersGetUser200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersGetUser200Response implements ApiSuccessEnvelope, Built<UsersGetUser200Response, UsersGetUser200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PublicUserResponseDto get data;

  UsersGetUser200Response._();

  factory UsersGetUser200Response([void updates(UsersGetUser200ResponseBuilder b)]) = _$UsersGetUser200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersGetUser200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersGetUser200Response> get serializer => _$UsersGetUser200ResponseSerializer();
}

class _$UsersGetUser200ResponseSerializer implements PrimitiveSerializer<UsersGetUser200Response> {
  @override
  final Iterable<Type> types = const [UsersGetUser200Response, _$UsersGetUser200Response];

  @override
  final String wireName = r'UsersGetUser200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersGetUser200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PublicUserResponseDto),
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
    UsersGetUser200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersGetUser200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PublicUserResponseDto),
          ) as PublicUserResponseDto;
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
  UsersGetUser200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersGetUser200ResponseBuilder();
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

class UsersGetUser200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersGetUser200ResponseCodeEnum number0 = _$usersGetUser200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersGetUser200ResponseCodeEnum unknownDefaultOpenApi = _$usersGetUser200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersGetUser200ResponseCodeEnum> get serializer => _$usersGetUser200ResponseCodeEnumSerializer;

  const UsersGetUser200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersGetUser200ResponseCodeEnum> get values => _$usersGetUser200ResponseCodeEnumValues;
  static UsersGetUser200ResponseCodeEnum valueOf(String name) => _$usersGetUser200ResponseCodeEnumValueOf(name);
}
