//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/moment_bookmark_folder_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_create_bookmark_folder201_response.g.dart';

/// MomentsCreateBookmarkFolder201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsCreateBookmarkFolder201Response implements ApiSuccessEnvelope, Built<MomentsCreateBookmarkFolder201Response, MomentsCreateBookmarkFolder201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MomentBookmarkFolderResponseDto get data;

  MomentsCreateBookmarkFolder201Response._();

  factory MomentsCreateBookmarkFolder201Response([void updates(MomentsCreateBookmarkFolder201ResponseBuilder b)]) = _$MomentsCreateBookmarkFolder201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsCreateBookmarkFolder201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsCreateBookmarkFolder201Response> get serializer => _$MomentsCreateBookmarkFolder201ResponseSerializer();
}

class _$MomentsCreateBookmarkFolder201ResponseSerializer implements PrimitiveSerializer<MomentsCreateBookmarkFolder201Response> {
  @override
  final Iterable<Type> types = const [MomentsCreateBookmarkFolder201Response, _$MomentsCreateBookmarkFolder201Response];

  @override
  final String wireName = r'MomentsCreateBookmarkFolder201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsCreateBookmarkFolder201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MomentBookmarkFolderResponseDto),
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
    MomentsCreateBookmarkFolder201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsCreateBookmarkFolder201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MomentBookmarkFolderResponseDto),
          ) as MomentBookmarkFolderResponseDto;
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
  MomentsCreateBookmarkFolder201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsCreateBookmarkFolder201ResponseBuilder();
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

class MomentsCreateBookmarkFolder201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsCreateBookmarkFolder201ResponseCodeEnum number0 = _$momentsCreateBookmarkFolder201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsCreateBookmarkFolder201ResponseCodeEnum unknownDefaultOpenApi = _$momentsCreateBookmarkFolder201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsCreateBookmarkFolder201ResponseCodeEnum> get serializer => _$momentsCreateBookmarkFolder201ResponseCodeEnumSerializer;

  const MomentsCreateBookmarkFolder201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsCreateBookmarkFolder201ResponseCodeEnum> get values => _$momentsCreateBookmarkFolder201ResponseCodeEnumValues;
  static MomentsCreateBookmarkFolder201ResponseCodeEnum valueOf(String name) => _$momentsCreateBookmarkFolder201ResponseCodeEnumValueOf(name);
}
