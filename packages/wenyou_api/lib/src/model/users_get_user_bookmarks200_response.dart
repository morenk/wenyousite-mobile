//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/bookmark_thread_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_get_user_bookmarks200_response.g.dart';

/// UsersGetUserBookmarks200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class UsersGetUserBookmarks200Response implements ApiPaginatedSuccessEnvelope, Built<UsersGetUserBookmarks200Response, UsersGetUserBookmarks200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<BookmarkThreadResponseDto> get data;

  UsersGetUserBookmarks200Response._();

  factory UsersGetUserBookmarks200Response([void updates(UsersGetUserBookmarks200ResponseBuilder b)]) = _$UsersGetUserBookmarks200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersGetUserBookmarks200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersGetUserBookmarks200Response> get serializer => _$UsersGetUserBookmarks200ResponseSerializer();
}

class _$UsersGetUserBookmarks200ResponseSerializer implements PrimitiveSerializer<UsersGetUserBookmarks200Response> {
  @override
  final Iterable<Type> types = const [UsersGetUserBookmarks200Response, _$UsersGetUserBookmarks200Response];

  @override
  final String wireName = r'UsersGetUserBookmarks200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersGetUserBookmarks200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(BookmarkThreadResponseDto)]),
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
    UsersGetUserBookmarks200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersGetUserBookmarks200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(BookmarkThreadResponseDto)]),
          ) as BuiltList<BookmarkThreadResponseDto>;
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
  UsersGetUserBookmarks200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersGetUserBookmarks200ResponseBuilder();
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

class UsersGetUserBookmarks200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersGetUserBookmarks200ResponseCodeEnum number0 = _$usersGetUserBookmarks200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersGetUserBookmarks200ResponseCodeEnum unknownDefaultOpenApi = _$usersGetUserBookmarks200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersGetUserBookmarks200ResponseCodeEnum> get serializer => _$usersGetUserBookmarks200ResponseCodeEnumSerializer;

  const UsersGetUserBookmarks200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersGetUserBookmarks200ResponseCodeEnum> get values => _$usersGetUserBookmarks200ResponseCodeEnumValues;
  static UsersGetUserBookmarks200ResponseCodeEnum valueOf(String name) => _$usersGetUserBookmarks200ResponseCodeEnumValueOf(name);
}
