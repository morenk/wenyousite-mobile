//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/floor_response_dto.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'posts_find_floors200_response.g.dart';

/// PostsFindFloors200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class PostsFindFloors200Response implements ApiPaginatedSuccessEnvelope, Built<PostsFindFloors200Response, PostsFindFloors200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<FloorResponseDto> get data;

  PostsFindFloors200Response._();

  factory PostsFindFloors200Response([void updates(PostsFindFloors200ResponseBuilder b)]) = _$PostsFindFloors200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostsFindFloors200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostsFindFloors200Response> get serializer => _$PostsFindFloors200ResponseSerializer();
}

class _$PostsFindFloors200ResponseSerializer implements PrimitiveSerializer<PostsFindFloors200Response> {
  @override
  final Iterable<Type> types = const [PostsFindFloors200Response, _$PostsFindFloors200Response];

  @override
  final String wireName = r'PostsFindFloors200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostsFindFloors200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(FloorResponseDto)]),
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
    PostsFindFloors200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostsFindFloors200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(FloorResponseDto)]),
          ) as BuiltList<FloorResponseDto>;
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
  PostsFindFloors200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostsFindFloors200ResponseBuilder();
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

class PostsFindFloors200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const PostsFindFloors200ResponseCodeEnum number0 = _$postsFindFloors200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const PostsFindFloors200ResponseCodeEnum unknownDefaultOpenApi = _$postsFindFloors200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<PostsFindFloors200ResponseCodeEnum> get serializer => _$postsFindFloors200ResponseCodeEnumSerializer;

  const PostsFindFloors200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<PostsFindFloors200ResponseCodeEnum> get values => _$postsFindFloors200ResponseCodeEnumValues;
  static PostsFindFloors200ResponseCodeEnum valueOf(String name) => _$postsFindFloors200ResponseCodeEnumValueOf(name);
}
