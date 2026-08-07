//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/notification_response_dto.dart';
import 'package:wenyou_api/src/model/api_pagination_meta.dart';
import 'package:wenyou_api/src/model/api_paginated_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notifications_find_all200_response.g.dart';

/// NotificationsFindAll200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [meta]
/// * [data]
@BuiltValue()
abstract class NotificationsFindAll200Response implements ApiPaginatedSuccessEnvelope, Built<NotificationsFindAll200Response, NotificationsFindAll200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<NotificationResponseDto> get data;

  NotificationsFindAll200Response._();

  factory NotificationsFindAll200Response([void updates(NotificationsFindAll200ResponseBuilder b)]) = _$NotificationsFindAll200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationsFindAll200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationsFindAll200Response> get serializer => _$NotificationsFindAll200ResponseSerializer();
}

class _$NotificationsFindAll200ResponseSerializer implements PrimitiveSerializer<NotificationsFindAll200Response> {
  @override
  final Iterable<Type> types = const [NotificationsFindAll200Response, _$NotificationsFindAll200Response];

  @override
  final String wireName = r'NotificationsFindAll200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationsFindAll200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(NotificationResponseDto)]),
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
    NotificationsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationsFindAll200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(NotificationResponseDto)]),
          ) as BuiltList<NotificationResponseDto>;
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
  NotificationsFindAll200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationsFindAll200ResponseBuilder();
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

class NotificationsFindAll200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const NotificationsFindAll200ResponseCodeEnum number0 = _$notificationsFindAll200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const NotificationsFindAll200ResponseCodeEnum unknownDefaultOpenApi = _$notificationsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<NotificationsFindAll200ResponseCodeEnum> get serializer => _$notificationsFindAll200ResponseCodeEnumSerializer;

  const NotificationsFindAll200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<NotificationsFindAll200ResponseCodeEnum> get values => _$notificationsFindAll200ResponseCodeEnumValues;
  static NotificationsFindAll200ResponseCodeEnum valueOf(String name) => _$notificationsFindAll200ResponseCodeEnumValueOf(name);
}
