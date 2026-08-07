//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/draft_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'drafts_find_all200_response.g.dart';

/// DraftsFindAll200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DraftsFindAll200Response implements ApiSuccessEnvelope, Built<DraftsFindAll200Response, DraftsFindAll200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<DraftResponseDto> get data;

  DraftsFindAll200Response._();

  factory DraftsFindAll200Response([void updates(DraftsFindAll200ResponseBuilder b)]) = _$DraftsFindAll200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DraftsFindAll200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DraftsFindAll200Response> get serializer => _$DraftsFindAll200ResponseSerializer();
}

class _$DraftsFindAll200ResponseSerializer implements PrimitiveSerializer<DraftsFindAll200Response> {
  @override
  final Iterable<Type> types = const [DraftsFindAll200Response, _$DraftsFindAll200Response];

  @override
  final String wireName = r'DraftsFindAll200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DraftsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(DraftResponseDto)]),
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
    DraftsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DraftsFindAll200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DraftResponseDto)]),
          ) as BuiltList<DraftResponseDto>;
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
  DraftsFindAll200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DraftsFindAll200ResponseBuilder();
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

class DraftsFindAll200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DraftsFindAll200ResponseCodeEnum number0 = _$draftsFindAll200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DraftsFindAll200ResponseCodeEnum unknownDefaultOpenApi = _$draftsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DraftsFindAll200ResponseCodeEnum> get serializer => _$draftsFindAll200ResponseCodeEnumSerializer;

  const DraftsFindAll200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DraftsFindAll200ResponseCodeEnum> get values => _$draftsFindAll200ResponseCodeEnumValues;
  static DraftsFindAll200ResponseCodeEnum valueOf(String name) => _$draftsFindAll200ResponseCodeEnumValueOf(name);
}
