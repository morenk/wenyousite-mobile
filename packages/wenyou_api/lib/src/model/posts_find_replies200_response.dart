//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/reply_response_dto.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'posts_find_replies200_response.g.dart';

/// PostsFindReplies200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class PostsFindReplies200Response implements ApiPaginatedSuccessEnvelope, Built<PostsFindReplies200Response, PostsFindReplies200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ReplyResponseDto> get data;

  PostsFindReplies200Response._();

  factory PostsFindReplies200Response([void updates(PostsFindReplies200ResponseBuilder b)]) = _$PostsFindReplies200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostsFindReplies200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostsFindReplies200Response> get serializer => _$PostsFindReplies200ResponseSerializer();
}

class _$PostsFindReplies200ResponseSerializer implements PrimitiveSerializer<PostsFindReplies200Response> {
  @override
  final Iterable<Type> types = const [PostsFindReplies200Response, _$PostsFindReplies200Response];

  @override
  final String wireName = r'PostsFindReplies200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostsFindReplies200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(ReplyResponseDto)]),
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
    PostsFindReplies200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostsFindReplies200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(ReplyResponseDto)]),
          ) as BuiltList<ReplyResponseDto>;
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
  PostsFindReplies200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostsFindReplies200ResponseBuilder();
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

class PostsFindReplies200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const PostsFindReplies200ResponseCodeEnum number0 = _$postsFindReplies200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const PostsFindReplies200ResponseCodeEnum unknownDefaultOpenApi = _$postsFindReplies200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<PostsFindReplies200ResponseCodeEnum> get serializer => _$postsFindReplies200ResponseCodeEnumSerializer;

  const PostsFindReplies200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<PostsFindReplies200ResponseCodeEnum> get values => _$postsFindReplies200ResponseCodeEnumValues;
  static PostsFindReplies200ResponseCodeEnum valueOf(String name) => _$postsFindReplies200ResponseCodeEnumValueOf(name);
}
