//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/moment_comment_context_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_comment_context200_response.g.dart';

/// MomentsCommentContext200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsCommentContext200Response implements ApiSuccessEnvelope, Built<MomentsCommentContext200Response, MomentsCommentContext200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MomentCommentContextResponseDto get data;

  MomentsCommentContext200Response._();

  factory MomentsCommentContext200Response([void updates(MomentsCommentContext200ResponseBuilder b)]) = _$MomentsCommentContext200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsCommentContext200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsCommentContext200Response> get serializer => _$MomentsCommentContext200ResponseSerializer();
}

class _$MomentsCommentContext200ResponseSerializer implements PrimitiveSerializer<MomentsCommentContext200Response> {
  @override
  final Iterable<Type> types = const [MomentsCommentContext200Response, _$MomentsCommentContext200Response];

  @override
  final String wireName = r'MomentsCommentContext200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsCommentContext200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MomentCommentContextResponseDto),
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
    MomentsCommentContext200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsCommentContext200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MomentCommentContextResponseDto),
          ) as MomentCommentContextResponseDto;
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
  MomentsCommentContext200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsCommentContext200ResponseBuilder();
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

class MomentsCommentContext200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsCommentContext200ResponseCodeEnum number0 = _$momentsCommentContext200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsCommentContext200ResponseCodeEnum unknownDefaultOpenApi = _$momentsCommentContext200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsCommentContext200ResponseCodeEnum> get serializer => _$momentsCommentContext200ResponseCodeEnumSerializer;

  const MomentsCommentContext200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsCommentContext200ResponseCodeEnum> get values => _$momentsCommentContext200ResponseCodeEnumValues;
  static MomentsCommentContext200ResponseCodeEnum valueOf(String name) => _$momentsCommentContext200ResponseCodeEnumValueOf(name);
}
