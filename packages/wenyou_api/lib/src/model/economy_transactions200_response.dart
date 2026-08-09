//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:wenyou_api/src/model/wallet_transaction_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'economy_transactions200_response.g.dart';

/// EconomyTransactions200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class EconomyTransactions200Response implements ApiPaginatedSuccessEnvelope, Built<EconomyTransactions200Response, EconomyTransactions200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<WalletTransactionResponseDto> get data;

  EconomyTransactions200Response._();

  factory EconomyTransactions200Response([void updates(EconomyTransactions200ResponseBuilder b)]) = _$EconomyTransactions200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EconomyTransactions200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EconomyTransactions200Response> get serializer => _$EconomyTransactions200ResponseSerializer();
}

class _$EconomyTransactions200ResponseSerializer implements PrimitiveSerializer<EconomyTransactions200Response> {
  @override
  final Iterable<Type> types = const [EconomyTransactions200Response, _$EconomyTransactions200Response];

  @override
  final String wireName = r'EconomyTransactions200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EconomyTransactions200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(WalletTransactionResponseDto)]),
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
    EconomyTransactions200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EconomyTransactions200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(WalletTransactionResponseDto)]),
          ) as BuiltList<WalletTransactionResponseDto>;
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
  EconomyTransactions200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EconomyTransactions200ResponseBuilder();
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

class EconomyTransactions200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const EconomyTransactions200ResponseCodeEnum number0 = _$economyTransactions200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const EconomyTransactions200ResponseCodeEnum unknownDefaultOpenApi = _$economyTransactions200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<EconomyTransactions200ResponseCodeEnum> get serializer => _$economyTransactions200ResponseCodeEnumSerializer;

  const EconomyTransactions200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<EconomyTransactions200ResponseCodeEnum> get values => _$economyTransactions200ResponseCodeEnumValues;
  static EconomyTransactions200ResponseCodeEnum valueOf(String name) => _$economyTransactions200ResponseCodeEnumValueOf(name);
}
