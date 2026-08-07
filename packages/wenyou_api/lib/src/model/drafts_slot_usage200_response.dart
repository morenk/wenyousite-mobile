//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/draft_slot_usage_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'drafts_slot_usage200_response.g.dart';

/// DraftsSlotUsage200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DraftsSlotUsage200Response implements ApiSuccessEnvelope, Built<DraftsSlotUsage200Response, DraftsSlotUsage200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DraftSlotUsageResponseDto get data;

  DraftsSlotUsage200Response._();

  factory DraftsSlotUsage200Response([void updates(DraftsSlotUsage200ResponseBuilder b)]) = _$DraftsSlotUsage200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DraftsSlotUsage200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DraftsSlotUsage200Response> get serializer => _$DraftsSlotUsage200ResponseSerializer();
}

class _$DraftsSlotUsage200ResponseSerializer implements PrimitiveSerializer<DraftsSlotUsage200Response> {
  @override
  final Iterable<Type> types = const [DraftsSlotUsage200Response, _$DraftsSlotUsage200Response];

  @override
  final String wireName = r'DraftsSlotUsage200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DraftsSlotUsage200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DraftSlotUsageResponseDto),
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
    DraftsSlotUsage200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DraftsSlotUsage200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DraftSlotUsageResponseDto),
          ) as DraftSlotUsageResponseDto;
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
  DraftsSlotUsage200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DraftsSlotUsage200ResponseBuilder();
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

class DraftsSlotUsage200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DraftsSlotUsage200ResponseCodeEnum number0 = _$draftsSlotUsage200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DraftsSlotUsage200ResponseCodeEnum unknownDefaultOpenApi = _$draftsSlotUsage200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DraftsSlotUsage200ResponseCodeEnum> get serializer => _$draftsSlotUsage200ResponseCodeEnumSerializer;

  const DraftsSlotUsage200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DraftsSlotUsage200ResponseCodeEnum> get values => _$draftsSlotUsage200ResponseCodeEnumValues;
  static DraftsSlotUsage200ResponseCodeEnum valueOf(String name) => _$draftsSlotUsage200ResponseCodeEnumValueOf(name);
}
