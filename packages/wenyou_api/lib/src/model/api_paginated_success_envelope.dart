//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'api_paginated_success_envelope.g.dart';

/// ApiPaginatedSuccessEnvelope
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
@BuiltValue(instantiable: false)
abstract class ApiPaginatedSuccessEnvelope implements ApiSuccessEnvelope {
  @BuiltValueField(wireName: r'meta')
  ApiPaginationMeta get meta;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApiPaginatedSuccessEnvelope> get serializer => _$ApiPaginatedSuccessEnvelopeSerializer();
}

class _$ApiPaginatedSuccessEnvelopeSerializer implements PrimitiveSerializer<ApiPaginatedSuccessEnvelope> {
  @override
  final Iterable<Type> types = const [ApiPaginatedSuccessEnvelope];

  @override
  final String wireName = r'ApiPaginatedSuccessEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApiPaginatedSuccessEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ApiPaginatedSuccessEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  ApiPaginatedSuccessEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($ApiPaginatedSuccessEnvelope)) as $ApiPaginatedSuccessEnvelope;
  }
}

/// a concrete implementation of [ApiPaginatedSuccessEnvelope], since [ApiPaginatedSuccessEnvelope] is not instantiable
@BuiltValue(instantiable: true)
abstract class $ApiPaginatedSuccessEnvelope implements ApiPaginatedSuccessEnvelope, Built<$ApiPaginatedSuccessEnvelope, $ApiPaginatedSuccessEnvelopeBuilder> {
  $ApiPaginatedSuccessEnvelope._();

  factory $ApiPaginatedSuccessEnvelope([void Function($ApiPaginatedSuccessEnvelopeBuilder)? updates]) = _$$ApiPaginatedSuccessEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($ApiPaginatedSuccessEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$ApiPaginatedSuccessEnvelope> get serializer => _$$ApiPaginatedSuccessEnvelopeSerializer();
}

class _$$ApiPaginatedSuccessEnvelopeSerializer implements PrimitiveSerializer<$ApiPaginatedSuccessEnvelope> {
  @override
  final Iterable<Type> types = const [$ApiPaginatedSuccessEnvelope, _$$ApiPaginatedSuccessEnvelope];

  @override
  final String wireName = r'$ApiPaginatedSuccessEnvelope';

  @override
  Object serialize(
    Serializers serializers,
    $ApiPaginatedSuccessEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(ApiPaginatedSuccessEnvelope))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ApiPaginatedSuccessEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  $ApiPaginatedSuccessEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $ApiPaginatedSuccessEnvelopeBuilder();
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

class ApiPaginatedSuccessEnvelopeCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ApiPaginatedSuccessEnvelopeCodeEnum number0 = _$apiPaginatedSuccessEnvelopeCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ApiPaginatedSuccessEnvelopeCodeEnum unknownDefaultOpenApi = _$apiPaginatedSuccessEnvelopeCodeEnum_unknownDefaultOpenApi;

  static Serializer<ApiPaginatedSuccessEnvelopeCodeEnum> get serializer => _$apiPaginatedSuccessEnvelopeCodeEnumSerializer;

  const ApiPaginatedSuccessEnvelopeCodeEnum._(String name): super(name);

  static BuiltSet<ApiPaginatedSuccessEnvelopeCodeEnum> get values => _$apiPaginatedSuccessEnvelopeCodeEnumValues;
  static ApiPaginatedSuccessEnvelopeCodeEnum valueOf(String name) => _$apiPaginatedSuccessEnvelopeCodeEnumValueOf(name);
}
