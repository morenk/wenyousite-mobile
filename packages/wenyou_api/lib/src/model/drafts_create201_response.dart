//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/draft_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'drafts_create201_response.g.dart';

/// DraftsCreate201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class DraftsCreate201Response implements ApiSuccessEnvelope, Built<DraftsCreate201Response, DraftsCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DraftResponseDto get data;

  DraftsCreate201Response._();

  factory DraftsCreate201Response([void updates(DraftsCreate201ResponseBuilder b)]) = _$DraftsCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DraftsCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DraftsCreate201Response> get serializer => _$DraftsCreate201ResponseSerializer();
}

class _$DraftsCreate201ResponseSerializer implements PrimitiveSerializer<DraftsCreate201Response> {
  @override
  final Iterable<Type> types = const [DraftsCreate201Response, _$DraftsCreate201Response];

  @override
  final String wireName = r'DraftsCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DraftsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DraftResponseDto),
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
    DraftsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DraftsCreate201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DraftResponseDto),
          ) as DraftResponseDto;
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
  DraftsCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DraftsCreate201ResponseBuilder();
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

class DraftsCreate201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const DraftsCreate201ResponseCodeEnum number0 = _$draftsCreate201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const DraftsCreate201ResponseCodeEnum unknownDefaultOpenApi = _$draftsCreate201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<DraftsCreate201ResponseCodeEnum> get serializer => _$draftsCreate201ResponseCodeEnumSerializer;

  const DraftsCreate201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<DraftsCreate201ResponseCodeEnum> get values => _$draftsCreate201ResponseCodeEnumValues;
  static DraftsCreate201ResponseCodeEnum valueOf(String name) => _$draftsCreate201ResponseCodeEnumValueOf(name);
}
