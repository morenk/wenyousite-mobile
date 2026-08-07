//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'posts_remove200_response.g.dart';

/// PostsRemove200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class PostsRemove200Response implements ApiSuccessEnvelope, Built<PostsRemove200Response, PostsRemove200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  PostsRemove200Response._();

  factory PostsRemove200Response([void updates(PostsRemove200ResponseBuilder b)]) = _$PostsRemove200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostsRemove200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostsRemove200Response> get serializer => _$PostsRemove200ResponseSerializer();
}

class _$PostsRemove200ResponseSerializer implements PrimitiveSerializer<PostsRemove200Response> {
  @override
  final Iterable<Type> types = const [PostsRemove200Response, _$PostsRemove200Response];

  @override
  final String wireName = r'PostsRemove200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostsRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MessageResponseDto),
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
    PostsRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostsRemove200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MessageResponseDto),
          ) as MessageResponseDto;
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
  PostsRemove200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostsRemove200ResponseBuilder();
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

class PostsRemove200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const PostsRemove200ResponseCodeEnum number0 = _$postsRemove200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const PostsRemove200ResponseCodeEnum unknownDefaultOpenApi = _$postsRemove200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<PostsRemove200ResponseCodeEnum> get serializer => _$postsRemove200ResponseCodeEnumSerializer;

  const PostsRemove200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<PostsRemove200ResponseCodeEnum> get values => _$postsRemove200ResponseCodeEnumValues;
  static PostsRemove200ResponseCodeEnum valueOf(String name) => _$postsRemove200ResponseCodeEnumValueOf(name);
}
