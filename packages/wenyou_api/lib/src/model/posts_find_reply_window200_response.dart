//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/reply_window_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'posts_find_reply_window200_response.g.dart';

/// PostsFindReplyWindow200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class PostsFindReplyWindow200Response implements ApiSuccessEnvelope, Built<PostsFindReplyWindow200Response, PostsFindReplyWindow200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ReplyWindowResponseDto get data;

  PostsFindReplyWindow200Response._();

  factory PostsFindReplyWindow200Response([void updates(PostsFindReplyWindow200ResponseBuilder b)]) = _$PostsFindReplyWindow200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostsFindReplyWindow200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostsFindReplyWindow200Response> get serializer => _$PostsFindReplyWindow200ResponseSerializer();
}

class _$PostsFindReplyWindow200ResponseSerializer implements PrimitiveSerializer<PostsFindReplyWindow200Response> {
  @override
  final Iterable<Type> types = const [PostsFindReplyWindow200Response, _$PostsFindReplyWindow200Response];

  @override
  final String wireName = r'PostsFindReplyWindow200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostsFindReplyWindow200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ReplyWindowResponseDto),
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
    PostsFindReplyWindow200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostsFindReplyWindow200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReplyWindowResponseDto),
          ) as ReplyWindowResponseDto;
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
  PostsFindReplyWindow200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostsFindReplyWindow200ResponseBuilder();
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

class PostsFindReplyWindow200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const PostsFindReplyWindow200ResponseCodeEnum number0 = _$postsFindReplyWindow200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const PostsFindReplyWindow200ResponseCodeEnum unknownDefaultOpenApi = _$postsFindReplyWindow200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<PostsFindReplyWindow200ResponseCodeEnum> get serializer => _$postsFindReplyWindow200ResponseCodeEnumSerializer;

  const PostsFindReplyWindow200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<PostsFindReplyWindow200ResponseCodeEnum> get values => _$postsFindReplyWindow200ResponseCodeEnumValues;
  static PostsFindReplyWindow200ResponseCodeEnum valueOf(String name) => _$postsFindReplyWindow200ResponseCodeEnumValueOf(name);
}
