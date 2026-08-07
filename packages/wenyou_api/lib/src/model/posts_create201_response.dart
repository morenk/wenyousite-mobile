//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/post_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'posts_create201_response.g.dart';

/// PostsCreate201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class PostsCreate201Response implements ApiSuccessEnvelope, Built<PostsCreate201Response, PostsCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PostResponseDto get data;

  PostsCreate201Response._();

  factory PostsCreate201Response([void updates(PostsCreate201ResponseBuilder b)]) = _$PostsCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostsCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostsCreate201Response> get serializer => _$PostsCreate201ResponseSerializer();
}

class _$PostsCreate201ResponseSerializer implements PrimitiveSerializer<PostsCreate201Response> {
  @override
  final Iterable<Type> types = const [PostsCreate201Response, _$PostsCreate201Response];

  @override
  final String wireName = r'PostsCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PostResponseDto),
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
    PostsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostsCreate201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostResponseDto),
          ) as PostResponseDto;
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
  PostsCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostsCreate201ResponseBuilder();
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

class PostsCreate201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const PostsCreate201ResponseCodeEnum number0 = _$postsCreate201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const PostsCreate201ResponseCodeEnum unknownDefaultOpenApi = _$postsCreate201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<PostsCreate201ResponseCodeEnum> get serializer => _$postsCreate201ResponseCodeEnumSerializer;

  const PostsCreate201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<PostsCreate201ResponseCodeEnum> get values => _$postsCreate201ResponseCodeEnumValues;
  static PostsCreate201ResponseCodeEnum valueOf(String name) => _$postsCreate201ResponseCodeEnumValueOf(name);
}
