//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/draft_state_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'drafts_state200_response.g.dart';

/// DraftsState200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DraftsState200Response implements ApiSuccessEnvelope, Built<DraftsState200Response, DraftsState200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DraftStateResponseDto get data;

  DraftsState200Response._();

  factory DraftsState200Response([void updates(DraftsState200ResponseBuilder b)]) = _$DraftsState200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DraftsState200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DraftsState200Response> get serializer => _$DraftsState200ResponseSerializer();
}

class _$DraftsState200ResponseSerializer implements PrimitiveSerializer<DraftsState200Response> {
  @override
  final Iterable<Type> types = const [DraftsState200Response, _$DraftsState200Response];

  @override
  final String wireName = r'DraftsState200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DraftsState200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DraftStateResponseDto),
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
    DraftsState200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DraftsState200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DraftStateResponseDto),
          ) as DraftStateResponseDto;
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
  DraftsState200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DraftsState200ResponseBuilder();
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

class DraftsState200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DraftsState200ResponseCodeEnum number0 = _$draftsState200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DraftsState200ResponseCodeEnum unknownDefaultOpenApi = _$draftsState200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DraftsState200ResponseCodeEnum> get serializer => _$draftsState200ResponseCodeEnumSerializer;

  const DraftsState200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DraftsState200ResponseCodeEnum> get values => _$draftsState200ResponseCodeEnumValues;
  static DraftsState200ResponseCodeEnum valueOf(String name) => _$draftsState200ResponseCodeEnumValueOf(name);
}
