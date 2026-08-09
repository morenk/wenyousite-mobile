//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/moment_card_response_dto.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_moments_list200_response.g.dart';

/// UserMomentsList200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class UserMomentsList200Response implements ApiPaginatedSuccessEnvelope, Built<UserMomentsList200Response, UserMomentsList200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<MomentCardResponseDto> get data;

  UserMomentsList200Response._();

  factory UserMomentsList200Response([void updates(UserMomentsList200ResponseBuilder b)]) = _$UserMomentsList200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserMomentsList200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserMomentsList200Response> get serializer => _$UserMomentsList200ResponseSerializer();
}

class _$UserMomentsList200ResponseSerializer implements PrimitiveSerializer<UserMomentsList200Response> {
  @override
  final Iterable<Type> types = const [UserMomentsList200Response, _$UserMomentsList200Response];

  @override
  final String wireName = r'UserMomentsList200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserMomentsList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
    );
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(MomentCardResponseDto)]),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(ApiPaginationMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserMomentsList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserMomentsList200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
          ) as ApiSuccessEnvelopeCodeEnum;
          result.code = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MomentCardResponseDto)]),
          ) as BuiltList<MomentCardResponseDto>;
          result.data.replace(valueDes);
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiPaginationMeta),
          ) as ApiPaginationMeta;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserMomentsList200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserMomentsList200ResponseBuilder();
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

class UserMomentsList200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UserMomentsList200ResponseCodeEnum number0 = _$userMomentsList200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UserMomentsList200ResponseCodeEnum unknownDefaultOpenApi = _$userMomentsList200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UserMomentsList200ResponseCodeEnum> get serializer => _$userMomentsList200ResponseCodeEnumSerializer;

  const UserMomentsList200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UserMomentsList200ResponseCodeEnum> get values => _$userMomentsList200ResponseCodeEnumValues;
  static UserMomentsList200ResponseCodeEnum valueOf(String name) => _$userMomentsList200ResponseCodeEnumValueOf(name);
}
