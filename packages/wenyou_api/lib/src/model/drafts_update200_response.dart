//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/draft_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'drafts_update200_response.g.dart';

/// DraftsUpdate200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DraftsUpdate200Response implements ApiSuccessEnvelope, Built<DraftsUpdate200Response, DraftsUpdate200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DraftResponseDto get data;

  DraftsUpdate200Response._();

  factory DraftsUpdate200Response([void updates(DraftsUpdate200ResponseBuilder b)]) = _$DraftsUpdate200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DraftsUpdate200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DraftsUpdate200Response> get serializer => _$DraftsUpdate200ResponseSerializer();
}

class _$DraftsUpdate200ResponseSerializer implements PrimitiveSerializer<DraftsUpdate200Response> {
  @override
  final Iterable<Type> types = const [DraftsUpdate200Response, _$DraftsUpdate200Response];

  @override
  final String wireName = r'DraftsUpdate200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DraftsUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DraftResponseDto),
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
    DraftsUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DraftsUpdate200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DraftResponseDto),
          ) as DraftResponseDto;
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
  DraftsUpdate200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DraftsUpdate200ResponseBuilder();
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

class DraftsUpdate200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DraftsUpdate200ResponseCodeEnum number0 = _$draftsUpdate200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DraftsUpdate200ResponseCodeEnum unknownDefaultOpenApi = _$draftsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DraftsUpdate200ResponseCodeEnum> get serializer => _$draftsUpdate200ResponseCodeEnumSerializer;

  const DraftsUpdate200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DraftsUpdate200ResponseCodeEnum> get values => _$draftsUpdate200ResponseCodeEnumValues;
  static DraftsUpdate200ResponseCodeEnum valueOf(String name) => _$draftsUpdate200ResponseCodeEnumValueOf(name);
}
