//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/thread_list_item_response_dto.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_get_user_created_threads200_response.g.dart';

/// UsersGetUserCreatedThreads200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class UsersGetUserCreatedThreads200Response implements ApiPaginatedSuccessEnvelope, Built<UsersGetUserCreatedThreads200Response, UsersGetUserCreatedThreads200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ThreadListItemResponseDto> get data;

  UsersGetUserCreatedThreads200Response._();

  factory UsersGetUserCreatedThreads200Response([void updates(UsersGetUserCreatedThreads200ResponseBuilder b)]) = _$UsersGetUserCreatedThreads200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersGetUserCreatedThreads200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersGetUserCreatedThreads200Response> get serializer => _$UsersGetUserCreatedThreads200ResponseSerializer();
}

class _$UsersGetUserCreatedThreads200ResponseSerializer implements PrimitiveSerializer<UsersGetUserCreatedThreads200Response> {
  @override
  final Iterable<Type> types = const [UsersGetUserCreatedThreads200Response, _$UsersGetUserCreatedThreads200Response];

  @override
  final String wireName = r'UsersGetUserCreatedThreads200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersGetUserCreatedThreads200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(ThreadListItemResponseDto)]),
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
    UsersGetUserCreatedThreads200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersGetUserCreatedThreads200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(ThreadListItemResponseDto)]),
          ) as BuiltList<ThreadListItemResponseDto>;
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
  UsersGetUserCreatedThreads200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersGetUserCreatedThreads200ResponseBuilder();
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

class UsersGetUserCreatedThreads200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersGetUserCreatedThreads200ResponseCodeEnum number0 = _$usersGetUserCreatedThreads200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersGetUserCreatedThreads200ResponseCodeEnum unknownDefaultOpenApi = _$usersGetUserCreatedThreads200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersGetUserCreatedThreads200ResponseCodeEnum> get serializer => _$usersGetUserCreatedThreads200ResponseCodeEnumSerializer;

  const UsersGetUserCreatedThreads200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersGetUserCreatedThreads200ResponseCodeEnum> get values => _$usersGetUserCreatedThreads200ResponseCodeEnumValues;
  static UsersGetUserCreatedThreads200ResponseCodeEnum valueOf(String name) => _$usersGetUserCreatedThreads200ResponseCodeEnumValueOf(name);
}
