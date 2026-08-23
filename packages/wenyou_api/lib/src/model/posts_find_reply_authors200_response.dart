//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/discussion_author_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'posts_find_reply_authors200_response.g.dart';

/// PostsFindReplyAuthors200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class PostsFindReplyAuthors200Response implements ApiSuccessEnvelope, Built<PostsFindReplyAuthors200Response, PostsFindReplyAuthors200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<DiscussionAuthorResponseDto> get data;

  PostsFindReplyAuthors200Response._();

  factory PostsFindReplyAuthors200Response([void updates(PostsFindReplyAuthors200ResponseBuilder b)]) = _$PostsFindReplyAuthors200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostsFindReplyAuthors200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostsFindReplyAuthors200Response> get serializer => _$PostsFindReplyAuthors200ResponseSerializer();
}

class _$PostsFindReplyAuthors200ResponseSerializer implements PrimitiveSerializer<PostsFindReplyAuthors200Response> {
  @override
  final Iterable<Type> types = const [PostsFindReplyAuthors200Response, _$PostsFindReplyAuthors200Response];

  @override
  final String wireName = r'PostsFindReplyAuthors200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostsFindReplyAuthors200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(DiscussionAuthorResponseDto)]),
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
    PostsFindReplyAuthors200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostsFindReplyAuthors200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DiscussionAuthorResponseDto)]),
          ) as BuiltList<DiscussionAuthorResponseDto>;
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
  PostsFindReplyAuthors200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostsFindReplyAuthors200ResponseBuilder();
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

class PostsFindReplyAuthors200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const PostsFindReplyAuthors200ResponseCodeEnum number0 = _$postsFindReplyAuthors200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const PostsFindReplyAuthors200ResponseCodeEnum unknownDefaultOpenApi = _$postsFindReplyAuthors200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<PostsFindReplyAuthors200ResponseCodeEnum> get serializer => _$postsFindReplyAuthors200ResponseCodeEnumSerializer;

  const PostsFindReplyAuthors200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<PostsFindReplyAuthors200ResponseCodeEnum> get values => _$postsFindReplyAuthors200ResponseCodeEnumValues;
  static PostsFindReplyAuthors200ResponseCodeEnum valueOf(String name) => _$postsFindReplyAuthors200ResponseCodeEnumValueOf(name);
}
