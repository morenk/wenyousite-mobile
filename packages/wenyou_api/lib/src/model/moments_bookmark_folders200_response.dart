//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/moment_bookmark_folder_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moments_bookmark_folders200_response.g.dart';

/// MomentsBookmarkFolders200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MomentsBookmarkFolders200Response implements ApiSuccessEnvelope, Built<MomentsBookmarkFolders200Response, MomentsBookmarkFolders200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<MomentBookmarkFolderResponseDto> get data;

  MomentsBookmarkFolders200Response._();

  factory MomentsBookmarkFolders200Response([void updates(MomentsBookmarkFolders200ResponseBuilder b)]) = _$MomentsBookmarkFolders200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentsBookmarkFolders200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentsBookmarkFolders200Response> get serializer => _$MomentsBookmarkFolders200ResponseSerializer();
}

class _$MomentsBookmarkFolders200ResponseSerializer implements PrimitiveSerializer<MomentsBookmarkFolders200Response> {
  @override
  final Iterable<Type> types = const [MomentsBookmarkFolders200Response, _$MomentsBookmarkFolders200Response];

  @override
  final String wireName = r'MomentsBookmarkFolders200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentsBookmarkFolders200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(MomentBookmarkFolderResponseDto)]),
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
    MomentsBookmarkFolders200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentsBookmarkFolders200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MomentBookmarkFolderResponseDto)]),
          ) as BuiltList<MomentBookmarkFolderResponseDto>;
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
  MomentsBookmarkFolders200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentsBookmarkFolders200ResponseBuilder();
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

class MomentsBookmarkFolders200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MomentsBookmarkFolders200ResponseCodeEnum number0 = _$momentsBookmarkFolders200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MomentsBookmarkFolders200ResponseCodeEnum unknownDefaultOpenApi = _$momentsBookmarkFolders200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MomentsBookmarkFolders200ResponseCodeEnum> get serializer => _$momentsBookmarkFolders200ResponseCodeEnumSerializer;

  const MomentsBookmarkFolders200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MomentsBookmarkFolders200ResponseCodeEnum> get values => _$momentsBookmarkFolders200ResponseCodeEnumValues;
  static MomentsBookmarkFolders200ResponseCodeEnum valueOf(String name) => _$momentsBookmarkFolders200ResponseCodeEnumValueOf(name);
}
