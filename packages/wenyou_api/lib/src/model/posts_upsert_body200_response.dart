//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/post_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'posts_upsert_body200_response.g.dart';

/// PostsUpsertBody200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class PostsUpsertBody200Response implements ApiSuccessEnvelope, Built<PostsUpsertBody200Response, PostsUpsertBody200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PostResponseDto get data;

  PostsUpsertBody200Response._();

  factory PostsUpsertBody200Response([void updates(PostsUpsertBody200ResponseBuilder b)]) = _$PostsUpsertBody200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostsUpsertBody200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostsUpsertBody200Response> get serializer => _$PostsUpsertBody200ResponseSerializer();
}

class _$PostsUpsertBody200ResponseSerializer implements PrimitiveSerializer<PostsUpsertBody200Response> {
  @override
  final Iterable<Type> types = const [PostsUpsertBody200Response, _$PostsUpsertBody200Response];

  @override
  final String wireName = r'PostsUpsertBody200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostsUpsertBody200Response object, {
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
    PostsUpsertBody200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostsUpsertBody200ResponseBuilder result,
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
  PostsUpsertBody200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostsUpsertBody200ResponseBuilder();
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

class PostsUpsertBody200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const PostsUpsertBody200ResponseCodeEnum number0 = _$postsUpsertBody200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const PostsUpsertBody200ResponseCodeEnum unknownDefaultOpenApi = _$postsUpsertBody200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<PostsUpsertBody200ResponseCodeEnum> get serializer => _$postsUpsertBody200ResponseCodeEnumSerializer;

  const PostsUpsertBody200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<PostsUpsertBody200ResponseCodeEnum> get values => _$postsUpsertBody200ResponseCodeEnumValues;
  static PostsUpsertBody200ResponseCodeEnum valueOf(String name) => _$postsUpsertBody200ResponseCodeEnumValueOf(name);
}
