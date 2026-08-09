//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/moment_action_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_like201_response.g.dart';

/// MomentsLike201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsLike201Response implements ApiSuccessEnvelope, Built<MomentsLike201Response, MomentsLike201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MomentActionResponseDto get data;

  MomentsLike201Response._();

  factory MomentsLike201Response([void updates(MomentsLike201ResponseBuilder b)]) = _$MomentsLike201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsLike201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsLike201Response> get serializer => _$MomentsLike201ResponseSerializer();
}

class _$MomentsLike201ResponseSerializer implements PrimitiveSerializer<MomentsLike201Response> {
  @override
  final Iterable<Type> types = const [MomentsLike201Response, _$MomentsLike201Response];

  @override
  final String wireName = r'MomentsLike201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsLike201Response object, {
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
    MomentsLike201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsLike201ResponseBuilder result,
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
  MomentsLike201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsLike201ResponseBuilder();
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

class MomentsLike201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsLike201ResponseCodeEnum number0 = _$momentsLike201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsLike201ResponseCodeEnum unknownDefaultOpenApi = _$momentsLike201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsLike201ResponseCodeEnum> get serializer => _$momentsLike201ResponseCodeEnumSerializer;

  const MomentsLike201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsLike201ResponseCodeEnum> get values => _$momentsLike201ResponseCodeEnumValues;
  static MomentsLike201ResponseCodeEnum valueOf(String name) => _$momentsLike201ResponseCodeEnumValueOf(name);
}
