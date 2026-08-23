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

part 'users_get_my_collaborated_threads200_response.g.dart';

/// UsersGetMyCollaboratedThreads200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class UsersGetMyCollaboratedThreads200Response implements ApiPaginatedSuccessEnvelope, Built<UsersGetMyCollaboratedThreads200Response, UsersGetMyCollaboratedThreads200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ThreadListItemResponseDto> get data;

  UsersGetMyCollaboratedThreads200Response._();

  factory UsersGetMyCollaboratedThreads200Response([void updates(UsersGetMyCollaboratedThreads200ResponseBuilder b)]) = _$UsersGetMyCollaboratedThreads200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersGetMyCollaboratedThreads200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersGetMyCollaboratedThreads200Response> get serializer => _$UsersGetMyCollaboratedThreads200ResponseSerializer();
}

class _$UsersGetMyCollaboratedThreads200ResponseSerializer implements PrimitiveSerializer<UsersGetMyCollaboratedThreads200Response> {
  @override
  final Iterable<Type> types = const [UsersGetMyCollaboratedThreads200Response, _$UsersGetMyCollaboratedThreads200Response];

  @override
  final String wireName = r'UsersGetMyCollaboratedThreads200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersGetMyCollaboratedThreads200Response object, {
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
    UsersGetMyCollaboratedThreads200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersGetMyCollaboratedThreads200ResponseBuilder result,
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
  UsersGetMyCollaboratedThreads200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersGetMyCollaboratedThreads200ResponseBuilder();
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

class UsersGetMyCollaboratedThreads200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersGetMyCollaboratedThreads200ResponseCodeEnum number0 = _$usersGetMyCollaboratedThreads200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersGetMyCollaboratedThreads200ResponseCodeEnum unknownDefaultOpenApi = _$usersGetMyCollaboratedThreads200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersGetMyCollaboratedThreads200ResponseCodeEnum> get serializer => _$usersGetMyCollaboratedThreads200ResponseCodeEnumSerializer;

  const UsersGetMyCollaboratedThreads200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersGetMyCollaboratedThreads200ResponseCodeEnum> get values => _$usersGetMyCollaboratedThreads200ResponseCodeEnumValues;
  static UsersGetMyCollaboratedThreads200ResponseCodeEnum valueOf(String name) => _$usersGetMyCollaboratedThreads200ResponseCodeEnumValueOf(name);
}
