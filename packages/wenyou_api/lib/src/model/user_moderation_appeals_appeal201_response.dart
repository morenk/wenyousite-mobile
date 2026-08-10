//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/moderation_appeal_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_moderation_appeals_appeal201_response.g.dart';

/// UserModerationAppealsAppeal201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UserModerationAppealsAppeal201Response implements ApiSuccessEnvelope, Built<UserModerationAppealsAppeal201Response, UserModerationAppealsAppeal201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ModerationAppealResponseDto get data;

  UserModerationAppealsAppeal201Response._();

  factory UserModerationAppealsAppeal201Response([void updates(UserModerationAppealsAppeal201ResponseBuilder b)]) = _$UserModerationAppealsAppeal201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserModerationAppealsAppeal201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserModerationAppealsAppeal201Response> get serializer => _$UserModerationAppealsAppeal201ResponseSerializer();
}

class _$UserModerationAppealsAppeal201ResponseSerializer implements PrimitiveSerializer<UserModerationAppealsAppeal201Response> {
  @override
  final Iterable<Type> types = const [UserModerationAppealsAppeal201Response, _$UserModerationAppealsAppeal201Response];

  @override
  final String wireName = r'UserModerationAppealsAppeal201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserModerationAppealsAppeal201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ModerationAppealResponseDto),
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
    UserModerationAppealsAppeal201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserModerationAppealsAppeal201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ModerationAppealResponseDto),
          ) as ModerationAppealResponseDto;
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
  UserModerationAppealsAppeal201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserModerationAppealsAppeal201ResponseBuilder();
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

class UserModerationAppealsAppeal201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UserModerationAppealsAppeal201ResponseCodeEnum number0 = _$userModerationAppealsAppeal201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UserModerationAppealsAppeal201ResponseCodeEnum unknownDefaultOpenApi = _$userModerationAppealsAppeal201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UserModerationAppealsAppeal201ResponseCodeEnum> get serializer => _$userModerationAppealsAppeal201ResponseCodeEnumSerializer;

  const UserModerationAppealsAppeal201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UserModerationAppealsAppeal201ResponseCodeEnum> get values => _$userModerationAppealsAppeal201ResponseCodeEnumValues;
  static UserModerationAppealsAppeal201ResponseCodeEnum valueOf(String name) => _$userModerationAppealsAppeal201ResponseCodeEnumValueOf(name);
}
