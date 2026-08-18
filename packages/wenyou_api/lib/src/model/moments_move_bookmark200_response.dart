//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/moment_bookmark_placement_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_move_bookmark200_response.g.dart';

/// MomentsMoveBookmark200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsMoveBookmark200Response implements ApiSuccessEnvelope, Built<MomentsMoveBookmark200Response, MomentsMoveBookmark200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MomentBookmarkPlacementResponseDto get data;

  MomentsMoveBookmark200Response._();

  factory MomentsMoveBookmark200Response([void updates(MomentsMoveBookmark200ResponseBuilder b)]) = _$MomentsMoveBookmark200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsMoveBookmark200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsMoveBookmark200Response> get serializer => _$MomentsMoveBookmark200ResponseSerializer();
}

class _$MomentsMoveBookmark200ResponseSerializer implements PrimitiveSerializer<MomentsMoveBookmark200Response> {
  @override
  final Iterable<Type> types = const [MomentsMoveBookmark200Response, _$MomentsMoveBookmark200Response];

  @override
  final String wireName = r'MomentsMoveBookmark200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsMoveBookmark200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MomentBookmarkPlacementResponseDto),
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
    MomentsMoveBookmark200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsMoveBookmark200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MomentBookmarkPlacementResponseDto),
          ) as MomentBookmarkPlacementResponseDto;
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
  MomentsMoveBookmark200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsMoveBookmark200ResponseBuilder();
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

class MomentsMoveBookmark200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsMoveBookmark200ResponseCodeEnum number0 = _$momentsMoveBookmark200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsMoveBookmark200ResponseCodeEnum unknownDefaultOpenApi = _$momentsMoveBookmark200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsMoveBookmark200ResponseCodeEnum> get serializer => _$momentsMoveBookmark200ResponseCodeEnumSerializer;

  const MomentsMoveBookmark200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsMoveBookmark200ResponseCodeEnum> get values => _$momentsMoveBookmark200ResponseCodeEnumValues;
  static MomentsMoveBookmark200ResponseCodeEnum valueOf(String name) => _$momentsMoveBookmark200ResponseCodeEnumValueOf(name);
}
