//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/post_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'posts_update200_response.g.dart';

/// PostsUpdate200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class PostsUpdate200Response implements ApiSuccessEnvelope, Built<PostsUpdate200Response, PostsUpdate200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PostResponseDto get data;

  PostsUpdate200Response._();

  factory PostsUpdate200Response([void updates(PostsUpdate200ResponseBuilder b)]) = _$PostsUpdate200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostsUpdate200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostsUpdate200Response> get serializer => _$PostsUpdate200ResponseSerializer();
}

class _$PostsUpdate200ResponseSerializer implements PrimitiveSerializer<PostsUpdate200Response> {
  @override
  final Iterable<Type> types = const [PostsUpdate200Response, _$PostsUpdate200Response];

  @override
  final String wireName = r'PostsUpdate200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostsUpdate200Response object, {
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
    PostsUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostsUpdate200ResponseBuilder result,
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
  PostsUpdate200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostsUpdate200ResponseBuilder();
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

class PostsUpdate200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const PostsUpdate200ResponseCodeEnum number0 = _$postsUpdate200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const PostsUpdate200ResponseCodeEnum unknownDefaultOpenApi = _$postsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<PostsUpdate200ResponseCodeEnum> get serializer => _$postsUpdate200ResponseCodeEnumSerializer;

  const PostsUpdate200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<PostsUpdate200ResponseCodeEnum> get values => _$postsUpdate200ResponseCodeEnumValues;
  static PostsUpdate200ResponseCodeEnum valueOf(String name) => _$postsUpdate200ResponseCodeEnumValueOf(name);
}
