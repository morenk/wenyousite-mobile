//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/post_author_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_comment_authors200_response.g.dart';

/// MomentsCommentAuthors200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsCommentAuthors200Response implements ApiSuccessEnvelope, Built<MomentsCommentAuthors200Response, MomentsCommentAuthors200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<PostAuthorResponseDto> get data;

  MomentsCommentAuthors200Response._();

  factory MomentsCommentAuthors200Response([void updates(MomentsCommentAuthors200ResponseBuilder b)]) = _$MomentsCommentAuthors200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsCommentAuthors200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsCommentAuthors200Response> get serializer => _$MomentsCommentAuthors200ResponseSerializer();
}

class _$MomentsCommentAuthors200ResponseSerializer implements PrimitiveSerializer<MomentsCommentAuthors200Response> {
  @override
  final Iterable<Type> types = const [MomentsCommentAuthors200Response, _$MomentsCommentAuthors200Response];

  @override
  final String wireName = r'MomentsCommentAuthors200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsCommentAuthors200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(PostAuthorResponseDto)]),
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
    MomentsCommentAuthors200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsCommentAuthors200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PostAuthorResponseDto)]),
          ) as BuiltList<PostAuthorResponseDto>;
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
  MomentsCommentAuthors200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsCommentAuthors200ResponseBuilder();
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

class MomentsCommentAuthors200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsCommentAuthors200ResponseCodeEnum number0 = _$momentsCommentAuthors200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsCommentAuthors200ResponseCodeEnum unknownDefaultOpenApi = _$momentsCommentAuthors200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsCommentAuthors200ResponseCodeEnum> get serializer => _$momentsCommentAuthors200ResponseCodeEnumSerializer;

  const MomentsCommentAuthors200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsCommentAuthors200ResponseCodeEnum> get values => _$momentsCommentAuthors200ResponseCodeEnumValues;
  static MomentsCommentAuthors200ResponseCodeEnum valueOf(String name) => _$momentsCommentAuthors200ResponseCodeEnumValueOf(name);
}
