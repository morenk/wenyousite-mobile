//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/home_thread_list_item_response_dto.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'threads_find_all200_response.g.dart';

/// ThreadsFindAll200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class ThreadsFindAll200Response implements ApiPaginatedSuccessEnvelope, Built<ThreadsFindAll200Response, ThreadsFindAll200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<HomeThreadListItemResponseDto> get data;

  ThreadsFindAll200Response._();

  factory ThreadsFindAll200Response([void updates(ThreadsFindAll200ResponseBuilder b)]) = _$ThreadsFindAll200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadsFindAll200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadsFindAll200Response> get serializer => _$ThreadsFindAll200ResponseSerializer();
}

class _$ThreadsFindAll200ResponseSerializer implements PrimitiveSerializer<ThreadsFindAll200Response> {
  @override
  final Iterable<Type> types = const [ThreadsFindAll200Response, _$ThreadsFindAll200Response];

  @override
  final String wireName = r'ThreadsFindAll200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadsFindAll200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(HomeThreadListItemResponseDto)]),
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
    ThreadsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadsFindAll200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(HomeThreadListItemResponseDto)]),
          ) as BuiltList<HomeThreadListItemResponseDto>;
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
  ThreadsFindAll200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadsFindAll200ResponseBuilder();
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

class ThreadsFindAll200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadsFindAll200ResponseCodeEnum number0 = _$threadsFindAll200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadsFindAll200ResponseCodeEnum unknownDefaultOpenApi = _$threadsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadsFindAll200ResponseCodeEnum> get serializer => _$threadsFindAll200ResponseCodeEnumSerializer;

  const ThreadsFindAll200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadsFindAll200ResponseCodeEnum> get values => _$threadsFindAll200ResponseCodeEnumValues;
  static ThreadsFindAll200ResponseCodeEnum valueOf(String name) => _$threadsFindAll200ResponseCodeEnumValueOf(name);
}
