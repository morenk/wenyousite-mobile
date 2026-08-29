//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/latest_thread_post_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'posts_find_latest_in_thread200_response.g.dart';

/// PostsFindLatestInThread200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class PostsFindLatestInThread200Response implements ApiSuccessEnvelope, Built<PostsFindLatestInThread200Response, PostsFindLatestInThread200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  LatestThreadPostResponseDto get data;

  PostsFindLatestInThread200Response._();

  factory PostsFindLatestInThread200Response([void updates(PostsFindLatestInThread200ResponseBuilder b)]) = _$PostsFindLatestInThread200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostsFindLatestInThread200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostsFindLatestInThread200Response> get serializer => _$PostsFindLatestInThread200ResponseSerializer();
}

class _$PostsFindLatestInThread200ResponseSerializer implements PrimitiveSerializer<PostsFindLatestInThread200Response> {
  @override
  final Iterable<Type> types = const [PostsFindLatestInThread200Response, _$PostsFindLatestInThread200Response];

  @override
  final String wireName = r'PostsFindLatestInThread200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostsFindLatestInThread200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(LatestThreadPostResponseDto),
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
    PostsFindLatestInThread200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostsFindLatestInThread200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LatestThreadPostResponseDto),
          ) as LatestThreadPostResponseDto;
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
  PostsFindLatestInThread200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostsFindLatestInThread200ResponseBuilder();
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

class PostsFindLatestInThread200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const PostsFindLatestInThread200ResponseCodeEnum number0 = _$postsFindLatestInThread200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const PostsFindLatestInThread200ResponseCodeEnum unknownDefaultOpenApi = _$postsFindLatestInThread200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<PostsFindLatestInThread200ResponseCodeEnum> get serializer => _$postsFindLatestInThread200ResponseCodeEnumSerializer;

  const PostsFindLatestInThread200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<PostsFindLatestInThread200ResponseCodeEnum> get values => _$postsFindLatestInThread200ResponseCodeEnumValues;
  static PostsFindLatestInThread200ResponseCodeEnum valueOf(String name) => _$postsFindLatestInThread200ResponseCodeEnumValueOf(name);
}
