//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/moment_bookmark_folder_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_rename_bookmark_folder200_response.g.dart';

/// MomentsRenameBookmarkFolder200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsRenameBookmarkFolder200Response implements ApiSuccessEnvelope, Built<MomentsRenameBookmarkFolder200Response, MomentsRenameBookmarkFolder200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MomentBookmarkFolderResponseDto get data;

  MomentsRenameBookmarkFolder200Response._();

  factory MomentsRenameBookmarkFolder200Response([void updates(MomentsRenameBookmarkFolder200ResponseBuilder b)]) = _$MomentsRenameBookmarkFolder200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsRenameBookmarkFolder200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsRenameBookmarkFolder200Response> get serializer => _$MomentsRenameBookmarkFolder200ResponseSerializer();
}

class _$MomentsRenameBookmarkFolder200ResponseSerializer implements PrimitiveSerializer<MomentsRenameBookmarkFolder200Response> {
  @override
  final Iterable<Type> types = const [MomentsRenameBookmarkFolder200Response, _$MomentsRenameBookmarkFolder200Response];

  @override
  final String wireName = r'MomentsRenameBookmarkFolder200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsRenameBookmarkFolder200Response object, {
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
    MomentsRenameBookmarkFolder200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsRenameBookmarkFolder200ResponseBuilder result,
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
  MomentsRenameBookmarkFolder200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsRenameBookmarkFolder200ResponseBuilder();
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

class MomentsRenameBookmarkFolder200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsRenameBookmarkFolder200ResponseCodeEnum number0 = _$momentsRenameBookmarkFolder200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsRenameBookmarkFolder200ResponseCodeEnum unknownDefaultOpenApi = _$momentsRenameBookmarkFolder200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsRenameBookmarkFolder200ResponseCodeEnum> get serializer => _$momentsRenameBookmarkFolder200ResponseCodeEnumSerializer;

  const MomentsRenameBookmarkFolder200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsRenameBookmarkFolder200ResponseCodeEnum> get values => _$momentsRenameBookmarkFolder200ResponseCodeEnumValues;
  static MomentsRenameBookmarkFolder200ResponseCodeEnum valueOf(String name) => _$momentsRenameBookmarkFolder200ResponseCodeEnumValueOf(name);
}
