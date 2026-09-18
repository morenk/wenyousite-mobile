//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/delete_bookmark_folder_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_delete_bookmark_folder200_response.g.dart';

/// MomentsDeleteBookmarkFolder200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsDeleteBookmarkFolder200Response implements ApiSuccessEnvelope, Built<MomentsDeleteBookmarkFolder200Response, MomentsDeleteBookmarkFolder200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DeleteBookmarkFolderResponseDto get data;

  MomentsDeleteBookmarkFolder200Response._();

  factory MomentsDeleteBookmarkFolder200Response([void updates(MomentsDeleteBookmarkFolder200ResponseBuilder b)]) = _$MomentsDeleteBookmarkFolder200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsDeleteBookmarkFolder200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsDeleteBookmarkFolder200Response> get serializer => _$MomentsDeleteBookmarkFolder200ResponseSerializer();
}

class _$MomentsDeleteBookmarkFolder200ResponseSerializer implements PrimitiveSerializer<MomentsDeleteBookmarkFolder200Response> {
  @override
  final Iterable<Type> types = const [MomentsDeleteBookmarkFolder200Response, _$MomentsDeleteBookmarkFolder200Response];

  @override
  final String wireName = r'MomentsDeleteBookmarkFolder200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsDeleteBookmarkFolder200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DeleteBookmarkFolderResponseDto),
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
    MomentsDeleteBookmarkFolder200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsDeleteBookmarkFolder200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeleteBookmarkFolderResponseDto),
          ) as DeleteBookmarkFolderResponseDto;
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
  MomentsDeleteBookmarkFolder200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsDeleteBookmarkFolder200ResponseBuilder();
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

class MomentsDeleteBookmarkFolder200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsDeleteBookmarkFolder200ResponseCodeEnum number0 = _$momentsDeleteBookmarkFolder200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsDeleteBookmarkFolder200ResponseCodeEnum unknownDefaultOpenApi = _$momentsDeleteBookmarkFolder200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsDeleteBookmarkFolder200ResponseCodeEnum> get serializer => _$momentsDeleteBookmarkFolder200ResponseCodeEnumSerializer;

  const MomentsDeleteBookmarkFolder200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsDeleteBookmarkFolder200ResponseCodeEnum> get values => _$momentsDeleteBookmarkFolder200ResponseCodeEnumValues;
  static MomentsDeleteBookmarkFolder200ResponseCodeEnum valueOf(String name) => _$momentsDeleteBookmarkFolder200ResponseCodeEnumValueOf(name);
}
