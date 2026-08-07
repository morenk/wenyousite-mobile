//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/current_user_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_get_me200_response.g.dart';

/// UsersGetMe200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersGetMe200Response implements ApiSuccessEnvelope, Built<UsersGetMe200Response, UsersGetMe200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  CurrentUserResponseDto get data;

  UsersGetMe200Response._();

  factory UsersGetMe200Response([void updates(UsersGetMe200ResponseBuilder b)]) = _$UsersGetMe200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersGetMe200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersGetMe200Response> get serializer => _$UsersGetMe200ResponseSerializer();
}

class _$UsersGetMe200ResponseSerializer implements PrimitiveSerializer<UsersGetMe200Response> {
  @override
  final Iterable<Type> types = const [UsersGetMe200Response, _$UsersGetMe200Response];

  @override
  final String wireName = r'UsersGetMe200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersGetMe200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(CurrentUserResponseDto),
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
    UsersGetMe200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersGetMe200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CurrentUserResponseDto),
          ) as CurrentUserResponseDto;
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
  UsersGetMe200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersGetMe200ResponseBuilder();
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

class UsersGetMe200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersGetMe200ResponseCodeEnum number0 = _$usersGetMe200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersGetMe200ResponseCodeEnum unknownDefaultOpenApi = _$usersGetMe200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersGetMe200ResponseCodeEnum> get serializer => _$usersGetMe200ResponseCodeEnumSerializer;

  const UsersGetMe200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersGetMe200ResponseCodeEnum> get values => _$usersGetMe200ResponseCodeEnumValues;
  static UsersGetMe200ResponseCodeEnum valueOf(String name) => _$usersGetMe200ResponseCodeEnumValueOf(name);
}
