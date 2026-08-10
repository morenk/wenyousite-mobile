//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/moderation_case_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moderation_cases_resolve201_response.g.dart';

/// ModerationCasesResolve201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ModerationCasesResolve201Response implements ApiSuccessEnvelope, Built<ModerationCasesResolve201Response, ModerationCasesResolve201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ModerationCaseResponseDto get data;

  ModerationCasesResolve201Response._();

  factory ModerationCasesResolve201Response([void updates(ModerationCasesResolve201ResponseBuilder b)]) = _$ModerationCasesResolve201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ModerationCasesResolve201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ModerationCasesResolve201Response> get serializer => _$ModerationCasesResolve201ResponseSerializer();
}

class _$ModerationCasesResolve201ResponseSerializer implements PrimitiveSerializer<ModerationCasesResolve201Response> {
  @override
  final Iterable<Type> types = const [ModerationCasesResolve201Response, _$ModerationCasesResolve201Response];

  @override
  final String wireName = r'ModerationCasesResolve201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ModerationCasesResolve201Response object, {
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
    ModerationCasesResolve201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ModerationCasesResolve201ResponseBuilder result,
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
  ModerationCasesResolve201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ModerationCasesResolve201ResponseBuilder();
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

class ModerationCasesResolve201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ModerationCasesResolve201ResponseCodeEnum number0 = _$moderationCasesResolve201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ModerationCasesResolve201ResponseCodeEnum unknownDefaultOpenApi = _$moderationCasesResolve201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ModerationCasesResolve201ResponseCodeEnum> get serializer => _$moderationCasesResolve201ResponseCodeEnumSerializer;

  const ModerationCasesResolve201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ModerationCasesResolve201ResponseCodeEnum> get values => _$moderationCasesResolve201ResponseCodeEnumValues;
  static ModerationCasesResolve201ResponseCodeEnum valueOf(String name) => _$moderationCasesResolve201ResponseCodeEnumValueOf(name);
}
