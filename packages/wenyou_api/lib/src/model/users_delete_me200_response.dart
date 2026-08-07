//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_delete_me200_response.g.dart';

/// UsersDeleteMe200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersDeleteMe200Response implements ApiSuccessEnvelope, Built<UsersDeleteMe200Response, UsersDeleteMe200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  UsersDeleteMe200Response._();

  factory UsersDeleteMe200Response([void updates(UsersDeleteMe200ResponseBuilder b)]) = _$UsersDeleteMe200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersDeleteMe200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersDeleteMe200Response> get serializer => _$UsersDeleteMe200ResponseSerializer();
}

class _$UsersDeleteMe200ResponseSerializer implements PrimitiveSerializer<UsersDeleteMe200Response> {
  @override
  final Iterable<Type> types = const [UsersDeleteMe200Response, _$UsersDeleteMe200Response];

  @override
  final String wireName = r'UsersDeleteMe200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersDeleteMe200Response object, {
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
    UsersDeleteMe200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersDeleteMe200ResponseBuilder result,
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
  UsersDeleteMe200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersDeleteMe200ResponseBuilder();
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

class UsersDeleteMe200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersDeleteMe200ResponseCodeEnum number0 = _$usersDeleteMe200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersDeleteMe200ResponseCodeEnum unknownDefaultOpenApi = _$usersDeleteMe200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersDeleteMe200ResponseCodeEnum> get serializer => _$usersDeleteMe200ResponseCodeEnumSerializer;

  const UsersDeleteMe200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersDeleteMe200ResponseCodeEnum> get values => _$usersDeleteMe200ResponseCodeEnumValues;
  static UsersDeleteMe200ResponseCodeEnum valueOf(String name) => _$usersDeleteMe200ResponseCodeEnumValueOf(name);
}
