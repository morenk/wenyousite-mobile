//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/moment_action_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_unbookmark200_response.g.dart';

/// MomentsUnbookmark200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsUnbookmark200Response implements ApiSuccessEnvelope, Built<MomentsUnbookmark200Response, MomentsUnbookmark200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MomentActionResponseDto get data;

  MomentsUnbookmark200Response._();

  factory MomentsUnbookmark200Response([void updates(MomentsUnbookmark200ResponseBuilder b)]) = _$MomentsUnbookmark200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsUnbookmark200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsUnbookmark200Response> get serializer => _$MomentsUnbookmark200ResponseSerializer();
}

class _$MomentsUnbookmark200ResponseSerializer implements PrimitiveSerializer<MomentsUnbookmark200Response> {
  @override
  final Iterable<Type> types = const [MomentsUnbookmark200Response, _$MomentsUnbookmark200Response];

  @override
  final String wireName = r'MomentsUnbookmark200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsUnbookmark200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MomentActionResponseDto),
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
    MomentsUnbookmark200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsUnbookmark200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MomentActionResponseDto),
          ) as MomentActionResponseDto;
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
  MomentsUnbookmark200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsUnbookmark200ResponseBuilder();
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

class MomentsUnbookmark200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsUnbookmark200ResponseCodeEnum number0 = _$momentsUnbookmark200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsUnbookmark200ResponseCodeEnum unknownDefaultOpenApi = _$momentsUnbookmark200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsUnbookmark200ResponseCodeEnum> get serializer => _$momentsUnbookmark200ResponseCodeEnumSerializer;

  const MomentsUnbookmark200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsUnbookmark200ResponseCodeEnum> get values => _$momentsUnbookmark200ResponseCodeEnumValues;
  static MomentsUnbookmark200ResponseCodeEnum valueOf(String name) => _$momentsUnbookmark200ResponseCodeEnumValueOf(name);
}
