//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/blocked_user_record_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_follow_blocks200_response.g.dart';

/// UsersFollowBlocks200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersFollowBlocks200Response implements ApiSuccessEnvelope, Built<UsersFollowBlocks200Response, UsersFollowBlocks200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<BlockedUserRecordResponseDto> get data;

  UsersFollowBlocks200Response._();

  factory UsersFollowBlocks200Response([void updates(UsersFollowBlocks200ResponseBuilder b)]) = _$UsersFollowBlocks200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersFollowBlocks200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersFollowBlocks200Response> get serializer => _$UsersFollowBlocks200ResponseSerializer();
}

class _$UsersFollowBlocks200ResponseSerializer implements PrimitiveSerializer<UsersFollowBlocks200Response> {
  @override
  final Iterable<Type> types = const [UsersFollowBlocks200Response, _$UsersFollowBlocks200Response];

  @override
  final String wireName = r'UsersFollowBlocks200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersFollowBlocks200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(BlockedUserRecordResponseDto)]),
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
    UsersFollowBlocks200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersFollowBlocks200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BlockedUserRecordResponseDto)]),
          ) as BuiltList<BlockedUserRecordResponseDto>;
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
  UsersFollowBlocks200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersFollowBlocks200ResponseBuilder();
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

class UsersFollowBlocks200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersFollowBlocks200ResponseCodeEnum number0 = _$usersFollowBlocks200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersFollowBlocks200ResponseCodeEnum unknownDefaultOpenApi = _$usersFollowBlocks200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersFollowBlocks200ResponseCodeEnum> get serializer => _$usersFollowBlocks200ResponseCodeEnumSerializer;

  const UsersFollowBlocks200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersFollowBlocks200ResponseCodeEnum> get values => _$usersFollowBlocks200ResponseCodeEnumValues;
  static UsersFollowBlocks200ResponseCodeEnum valueOf(String name) => _$usersFollowBlocks200ResponseCodeEnumValueOf(name);
}
