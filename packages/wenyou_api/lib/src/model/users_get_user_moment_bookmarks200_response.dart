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

part 'users_get_user_moment_bookmarks200_response.g.dart';

/// UsersGetUserMomentBookmarks200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class UsersGetUserMomentBookmarks200Response implements ApiPaginatedSuccessEnvelope, Built<UsersGetUserMomentBookmarks200Response, UsersGetUserMomentBookmarks200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<MomentCardResponseDto> get data;

  UsersGetUserMomentBookmarks200Response._();

  factory UsersGetUserMomentBookmarks200Response([void updates(UsersGetUserMomentBookmarks200ResponseBuilder b)]) = _$UsersGetUserMomentBookmarks200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersGetUserMomentBookmarks200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersGetUserMomentBookmarks200Response> get serializer => _$UsersGetUserMomentBookmarks200ResponseSerializer();
}

class _$UsersGetUserMomentBookmarks200ResponseSerializer implements PrimitiveSerializer<UsersGetUserMomentBookmarks200Response> {
  @override
  final Iterable<Type> types = const [UsersGetUserMomentBookmarks200Response, _$UsersGetUserMomentBookmarks200Response];

  @override
  final String wireName = r'UsersGetUserMomentBookmarks200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersGetUserMomentBookmarks200Response object, {
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
    UsersGetUserMomentBookmarks200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersGetUserMomentBookmarks200ResponseBuilder result,
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
  UsersGetUserMomentBookmarks200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersGetUserMomentBookmarks200ResponseBuilder();
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

class UsersGetUserMomentBookmarks200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersGetUserMomentBookmarks200ResponseCodeEnum number0 = _$usersGetUserMomentBookmarks200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersGetUserMomentBookmarks200ResponseCodeEnum unknownDefaultOpenApi = _$usersGetUserMomentBookmarks200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersGetUserMomentBookmarks200ResponseCodeEnum> get serializer => _$usersGetUserMomentBookmarks200ResponseCodeEnumSerializer;

  const UsersGetUserMomentBookmarks200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersGetUserMomentBookmarks200ResponseCodeEnum> get values => _$usersGetUserMomentBookmarks200ResponseCodeEnumValues;
  static UsersGetUserMomentBookmarks200ResponseCodeEnum valueOf(String name) => _$usersGetUserMomentBookmarks200ResponseCodeEnumValueOf(name);
}
