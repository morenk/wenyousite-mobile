//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_search200_response.g.dart';

/// UsersSearch200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersSearch200Response implements ApiSuccessEnvelope, Built<UsersSearch200Response, UsersSearch200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<PostAuthorResponseDto> get data;

  UsersSearch200Response._();

  factory UsersSearch200Response([void updates(UsersSearch200ResponseBuilder b)]) = _$UsersSearch200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersSearch200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersSearch200Response> get serializer => _$UsersSearch200ResponseSerializer();
}

class _$UsersSearch200ResponseSerializer implements PrimitiveSerializer<UsersSearch200Response> {
  @override
  final Iterable<Type> types = const [UsersSearch200Response, _$UsersSearch200Response];

  @override
  final String wireName = r'UsersSearch200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersSearch200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(PostAuthorResponseDto)]),
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
    UsersSearch200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersSearch200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PostAuthorResponseDto)]),
          ) as BuiltList<PostAuthorResponseDto>;
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
  UsersSearch200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersSearch200ResponseBuilder();
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

class UsersSearch200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersSearch200ResponseCodeEnum number0 = _$usersSearch200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersSearch200ResponseCodeEnum unknownDefaultOpenApi = _$usersSearch200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersSearch200ResponseCodeEnum> get serializer => _$usersSearch200ResponseCodeEnumSerializer;

  const UsersSearch200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersSearch200ResponseCodeEnum> get values => _$usersSearch200ResponseCodeEnumValues;
  static UsersSearch200ResponseCodeEnum valueOf(String name) => _$usersSearch200ResponseCodeEnumValueOf(name);
}
