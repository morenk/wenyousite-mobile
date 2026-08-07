//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/delete_draft_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'drafts_remove200_response.g.dart';

/// DraftsRemove200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DraftsRemove200Response implements ApiSuccessEnvelope, Built<DraftsRemove200Response, DraftsRemove200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DeleteDraftResponseDto get data;

  DraftsRemove200Response._();

  factory DraftsRemove200Response([void updates(DraftsRemove200ResponseBuilder b)]) = _$DraftsRemove200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DraftsRemove200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DraftsRemove200Response> get serializer => _$DraftsRemove200ResponseSerializer();
}

class _$DraftsRemove200ResponseSerializer implements PrimitiveSerializer<DraftsRemove200Response> {
  @override
  final Iterable<Type> types = const [DraftsRemove200Response, _$DraftsRemove200Response];

  @override
  final String wireName = r'DraftsRemove200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DraftsRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DeleteDraftResponseDto),
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
    DraftsRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DraftsRemove200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeleteDraftResponseDto),
          ) as DeleteDraftResponseDto;
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
  DraftsRemove200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DraftsRemove200ResponseBuilder();
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

class DraftsRemove200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DraftsRemove200ResponseCodeEnum number0 = _$draftsRemove200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DraftsRemove200ResponseCodeEnum unknownDefaultOpenApi = _$draftsRemove200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DraftsRemove200ResponseCodeEnum> get serializer => _$draftsRemove200ResponseCodeEnumSerializer;

  const DraftsRemove200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DraftsRemove200ResponseCodeEnum> get values => _$draftsRemove200ResponseCodeEnumValues;
  static DraftsRemove200ResponseCodeEnum valueOf(String name) => _$draftsRemove200ResponseCodeEnumValueOf(name);
}
