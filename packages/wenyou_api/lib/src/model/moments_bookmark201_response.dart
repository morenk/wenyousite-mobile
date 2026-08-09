//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/moment_action_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_bookmark201_response.g.dart';

/// MomentsBookmark201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsBookmark201Response implements ApiSuccessEnvelope, Built<MomentsBookmark201Response, MomentsBookmark201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MomentActionResponseDto get data;

  MomentsBookmark201Response._();

  factory MomentsBookmark201Response([void updates(MomentsBookmark201ResponseBuilder b)]) = _$MomentsBookmark201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsBookmark201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsBookmark201Response> get serializer => _$MomentsBookmark201ResponseSerializer();
}

class _$MomentsBookmark201ResponseSerializer implements PrimitiveSerializer<MomentsBookmark201Response> {
  @override
  final Iterable<Type> types = const [MomentsBookmark201Response, _$MomentsBookmark201Response];

  @override
  final String wireName = r'MomentsBookmark201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsBookmark201Response object, {
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
    MomentsBookmark201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsBookmark201ResponseBuilder result,
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
  MomentsBookmark201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsBookmark201ResponseBuilder();
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

class MomentsBookmark201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsBookmark201ResponseCodeEnum number0 = _$momentsBookmark201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsBookmark201ResponseCodeEnum unknownDefaultOpenApi = _$momentsBookmark201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsBookmark201ResponseCodeEnum> get serializer => _$momentsBookmark201ResponseCodeEnumSerializer;

  const MomentsBookmark201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsBookmark201ResponseCodeEnum> get values => _$momentsBookmark201ResponseCodeEnumValues;
  static MomentsBookmark201ResponseCodeEnum valueOf(String name) => _$momentsBookmark201ResponseCodeEnumValueOf(name);
}
