//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/post_detail_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'posts_find_by_id200_response.g.dart';

/// PostsFindById200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class PostsFindById200Response implements ApiSuccessEnvelope, Built<PostsFindById200Response, PostsFindById200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PostDetailResponseDto get data;

  PostsFindById200Response._();

  factory PostsFindById200Response([void updates(PostsFindById200ResponseBuilder b)]) = _$PostsFindById200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostsFindById200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostsFindById200Response> get serializer => _$PostsFindById200ResponseSerializer();
}

class _$PostsFindById200ResponseSerializer implements PrimitiveSerializer<PostsFindById200Response> {
  @override
  final Iterable<Type> types = const [PostsFindById200Response, _$PostsFindById200Response];

  @override
  final String wireName = r'PostsFindById200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostsFindById200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PostDetailResponseDto),
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
    PostsFindById200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostsFindById200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostDetailResponseDto),
          ) as PostDetailResponseDto;
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
  PostsFindById200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostsFindById200ResponseBuilder();
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

class PostsFindById200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const PostsFindById200ResponseCodeEnum number0 = _$postsFindById200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const PostsFindById200ResponseCodeEnum unknownDefaultOpenApi = _$postsFindById200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<PostsFindById200ResponseCodeEnum> get serializer => _$postsFindById200ResponseCodeEnumSerializer;

  const PostsFindById200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<PostsFindById200ResponseCodeEnum> get values => _$postsFindById200ResponseCodeEnumValues;
  static PostsFindById200ResponseCodeEnum valueOf(String name) => _$postsFindById200ResponseCodeEnumValueOf(name);
}
