//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/discussion_author_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'posts_find_floor_authors200_response.g.dart';

/// PostsFindFloorAuthors200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class PostsFindFloorAuthors200Response implements ApiSuccessEnvelope, Built<PostsFindFloorAuthors200Response, PostsFindFloorAuthors200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<DiscussionAuthorResponseDto> get data;

  PostsFindFloorAuthors200Response._();

  factory PostsFindFloorAuthors200Response([void updates(PostsFindFloorAuthors200ResponseBuilder b)]) = _$PostsFindFloorAuthors200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostsFindFloorAuthors200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostsFindFloorAuthors200Response> get serializer => _$PostsFindFloorAuthors200ResponseSerializer();
}

class _$PostsFindFloorAuthors200ResponseSerializer implements PrimitiveSerializer<PostsFindFloorAuthors200Response> {
  @override
  final Iterable<Type> types = const [PostsFindFloorAuthors200Response, _$PostsFindFloorAuthors200Response];

  @override
  final String wireName = r'PostsFindFloorAuthors200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostsFindFloorAuthors200Response object, {
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
    PostsFindFloorAuthors200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostsFindFloorAuthors200ResponseBuilder result,
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
  PostsFindFloorAuthors200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostsFindFloorAuthors200ResponseBuilder();
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

class PostsFindFloorAuthors200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const PostsFindFloorAuthors200ResponseCodeEnum number0 = _$postsFindFloorAuthors200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const PostsFindFloorAuthors200ResponseCodeEnum unknownDefaultOpenApi = _$postsFindFloorAuthors200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<PostsFindFloorAuthors200ResponseCodeEnum> get serializer => _$postsFindFloorAuthors200ResponseCodeEnumSerializer;

  const PostsFindFloorAuthors200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<PostsFindFloorAuthors200ResponseCodeEnum> get values => _$postsFindFloorAuthors200ResponseCodeEnumValues;
  static PostsFindFloorAuthors200ResponseCodeEnum valueOf(String name) => _$postsFindFloorAuthors200ResponseCodeEnumValueOf(name);
}
