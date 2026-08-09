//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/moment_detail_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_create201_response.g.dart';

/// MomentsCreate201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsCreate201Response implements ApiSuccessEnvelope, Built<MomentsCreate201Response, MomentsCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MomentDetailResponseDto get data;

  MomentsCreate201Response._();

  factory MomentsCreate201Response([void updates(MomentsCreate201ResponseBuilder b)]) = _$MomentsCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsCreate201Response> get serializer => _$MomentsCreate201ResponseSerializer();
}

class _$MomentsCreate201ResponseSerializer implements PrimitiveSerializer<MomentsCreate201Response> {
  @override
  final Iterable<Type> types = const [MomentsCreate201Response, _$MomentsCreate201Response];

  @override
  final String wireName = r'MomentsCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MomentDetailResponseDto),
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
    MomentsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsCreate201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MomentDetailResponseDto),
          ) as MomentDetailResponseDto;
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
  MomentsCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsCreate201ResponseBuilder();
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

class MomentsCreate201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsCreate201ResponseCodeEnum number0 = _$momentsCreate201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsCreate201ResponseCodeEnum unknownDefaultOpenApi = _$momentsCreate201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsCreate201ResponseCodeEnum> get serializer => _$momentsCreate201ResponseCodeEnumSerializer;

  const MomentsCreate201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsCreate201ResponseCodeEnum> get values => _$momentsCreate201ResponseCodeEnumValues;
  static MomentsCreate201ResponseCodeEnum valueOf(String name) => _$momentsCreate201ResponseCodeEnumValueOf(name);
}
