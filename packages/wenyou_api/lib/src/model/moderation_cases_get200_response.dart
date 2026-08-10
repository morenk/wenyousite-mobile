//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/moderation_case_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moderation_cases_get200_response.g.dart';

/// ModerationCasesGet200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ModerationCasesGet200Response implements ApiSuccessEnvelope, Built<ModerationCasesGet200Response, ModerationCasesGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ModerationCaseResponseDto get data;

  ModerationCasesGet200Response._();

  factory ModerationCasesGet200Response([void updates(ModerationCasesGet200ResponseBuilder b)]) = _$ModerationCasesGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModerationCasesGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModerationCasesGet200Response> get serializer => _$ModerationCasesGet200ResponseSerializer();
}

class _$ModerationCasesGet200ResponseSerializer implements PrimitiveSerializer<ModerationCasesGet200Response> {
  @override
  final Iterable<Type> types = const [ModerationCasesGet200Response, _$ModerationCasesGet200Response];

  @override
  final String wireName = r'ModerationCasesGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModerationCasesGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ModerationCaseResponseDto),
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
    ModerationCasesGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ModerationCasesGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ModerationCaseResponseDto),
          ) as ModerationCaseResponseDto;
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
  ModerationCasesGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModerationCasesGet200ResponseBuilder();
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

class ModerationCasesGet200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ModerationCasesGet200ResponseCodeEnum number0 = _$moderationCasesGet200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ModerationCasesGet200ResponseCodeEnum unknownDefaultOpenApi = _$moderationCasesGet200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ModerationCasesGet200ResponseCodeEnum> get serializer => _$moderationCasesGet200ResponseCodeEnumSerializer;

  const ModerationCasesGet200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ModerationCasesGet200ResponseCodeEnum> get values => _$moderationCasesGet200ResponseCodeEnumValues;
  static ModerationCasesGet200ResponseCodeEnum valueOf(String name) => _$moderationCasesGet200ResponseCodeEnumValueOf(name);
}
