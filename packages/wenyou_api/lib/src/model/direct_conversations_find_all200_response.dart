//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/direct_conversation_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_conversations_find_all200_response.g.dart';

/// DirectConversationsFindAll200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class DirectConversationsFindAll200Response implements ApiPaginatedSuccessEnvelope, Built<DirectConversationsFindAll200Response, DirectConversationsFindAll200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<DirectConversationResponseDto> get data;

  DirectConversationsFindAll200Response._();

  factory DirectConversationsFindAll200Response([void updates(DirectConversationsFindAll200ResponseBuilder b)]) = _$DirectConversationsFindAll200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectConversationsFindAll200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectConversationsFindAll200Response> get serializer => _$DirectConversationsFindAll200ResponseSerializer();
}

class _$DirectConversationsFindAll200ResponseSerializer implements PrimitiveSerializer<DirectConversationsFindAll200Response> {
  @override
  final Iterable<Type> types = const [DirectConversationsFindAll200Response, _$DirectConversationsFindAll200Response];

  @override
  final String wireName = r'DirectConversationsFindAll200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectConversationsFindAll200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(DirectConversationResponseDto)]),
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
    DirectConversationsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectConversationsFindAll200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(DirectConversationResponseDto)]),
          ) as BuiltList<DirectConversationResponseDto>;
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
  DirectConversationsFindAll200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectConversationsFindAll200ResponseBuilder();
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

class DirectConversationsFindAll200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DirectConversationsFindAll200ResponseCodeEnum number0 = _$directConversationsFindAll200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DirectConversationsFindAll200ResponseCodeEnum unknownDefaultOpenApi = _$directConversationsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DirectConversationsFindAll200ResponseCodeEnum> get serializer => _$directConversationsFindAll200ResponseCodeEnumSerializer;

  const DirectConversationsFindAll200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DirectConversationsFindAll200ResponseCodeEnum> get values => _$directConversationsFindAll200ResponseCodeEnumValues;
  static DirectConversationsFindAll200ResponseCodeEnum valueOf(String name) => _$directConversationsFindAll200ResponseCodeEnumValueOf(name);
}
