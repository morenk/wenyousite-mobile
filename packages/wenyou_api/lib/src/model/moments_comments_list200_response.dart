//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/moment_root_comment_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_comments_list200_response.g.dart';

/// MomentsCommentsList200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class MomentsCommentsList200Response implements ApiPaginatedSuccessEnvelope, Built<MomentsCommentsList200Response, MomentsCommentsList200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<MomentRootCommentResponseDto> get data;

  MomentsCommentsList200Response._();

  factory MomentsCommentsList200Response([void updates(MomentsCommentsList200ResponseBuilder b)]) = _$MomentsCommentsList200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsCommentsList200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsCommentsList200Response> get serializer => _$MomentsCommentsList200ResponseSerializer();
}

class _$MomentsCommentsList200ResponseSerializer implements PrimitiveSerializer<MomentsCommentsList200Response> {
  @override
  final Iterable<Type> types = const [MomentsCommentsList200Response, _$MomentsCommentsList200Response];

  @override
  final String wireName = r'MomentsCommentsList200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsCommentsList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
    );
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(MomentRootCommentResponseDto)]),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(ApiPaginationMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MomentsCommentsList200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsCommentsList200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
          ) as ApiSuccessEnvelopeCodeEnum;
          result.code = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MomentRootCommentResponseDto)]),
          ) as BuiltList<MomentRootCommentResponseDto>;
          result.data.replace(valueDes);
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiPaginationMeta),
          ) as ApiPaginationMeta;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MomentsCommentsList200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsCommentsList200ResponseBuilder();
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

class MomentsCommentsList200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsCommentsList200ResponseCodeEnum number0 = _$momentsCommentsList200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsCommentsList200ResponseCodeEnum unknownDefaultOpenApi = _$momentsCommentsList200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsCommentsList200ResponseCodeEnum> get serializer => _$momentsCommentsList200ResponseCodeEnumSerializer;

  const MomentsCommentsList200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsCommentsList200ResponseCodeEnum> get values => _$momentsCommentsList200ResponseCodeEnumValues;
  static MomentsCommentsList200ResponseCodeEnum valueOf(String name) => _$momentsCommentsList200ResponseCodeEnumValueOf(name);
}
