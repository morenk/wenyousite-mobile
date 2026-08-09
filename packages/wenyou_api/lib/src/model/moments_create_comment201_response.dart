//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/moment_comment_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_create_comment201_response.g.dart';

/// MomentsCreateComment201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsCreateComment201Response implements ApiSuccessEnvelope, Built<MomentsCreateComment201Response, MomentsCreateComment201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MomentCommentResponseDto get data;

  MomentsCreateComment201Response._();

  factory MomentsCreateComment201Response([void updates(MomentsCreateComment201ResponseBuilder b)]) = _$MomentsCreateComment201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsCreateComment201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsCreateComment201Response> get serializer => _$MomentsCreateComment201ResponseSerializer();
}

class _$MomentsCreateComment201ResponseSerializer implements PrimitiveSerializer<MomentsCreateComment201Response> {
  @override
  final Iterable<Type> types = const [MomentsCreateComment201Response, _$MomentsCreateComment201Response];

  @override
  final String wireName = r'MomentsCreateComment201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsCreateComment201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MomentCommentResponseDto),
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
    MomentsCreateComment201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsCreateComment201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MomentCommentResponseDto),
          ) as MomentCommentResponseDto;
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
  MomentsCreateComment201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsCreateComment201ResponseBuilder();
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

class MomentsCreateComment201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsCreateComment201ResponseCodeEnum number0 = _$momentsCreateComment201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsCreateComment201ResponseCodeEnum unknownDefaultOpenApi = _$momentsCreateComment201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsCreateComment201ResponseCodeEnum> get serializer => _$momentsCreateComment201ResponseCodeEnumSerializer;

  const MomentsCreateComment201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsCreateComment201ResponseCodeEnum> get values => _$momentsCreateComment201ResponseCodeEnumValues;
  static MomentsCreateComment201ResponseCodeEnum valueOf(String name) => _$momentsCreateComment201ResponseCodeEnumValueOf(name);
}
