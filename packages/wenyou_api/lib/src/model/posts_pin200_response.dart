//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'posts_pin200_response.g.dart';

/// PostsPin200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class PostsPin200Response implements ApiSuccessEnvelope, Built<PostsPin200Response, PostsPin200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  PostsPin200Response._();

  factory PostsPin200Response([void updates(PostsPin200ResponseBuilder b)]) = _$PostsPin200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostsPin200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostsPin200Response> get serializer => _$PostsPin200ResponseSerializer();
}

class _$PostsPin200ResponseSerializer implements PrimitiveSerializer<PostsPin200Response> {
  @override
  final Iterable<Type> types = const [PostsPin200Response, _$PostsPin200Response];

  @override
  final String wireName = r'PostsPin200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostsPin200Response object, {
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
    PostsPin200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostsPin200ResponseBuilder result,
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
  PostsPin200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostsPin200ResponseBuilder();
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

class PostsPin200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const PostsPin200ResponseCodeEnum number0 = _$postsPin200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const PostsPin200ResponseCodeEnum unknownDefaultOpenApi = _$postsPin200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<PostsPin200ResponseCodeEnum> get serializer => _$postsPin200ResponseCodeEnumSerializer;

  const PostsPin200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<PostsPin200ResponseCodeEnum> get values => _$postsPin200ResponseCodeEnumValues;
  static PostsPin200ResponseCodeEnum valueOf(String name) => _$postsPin200ResponseCodeEnumValueOf(name);
}
