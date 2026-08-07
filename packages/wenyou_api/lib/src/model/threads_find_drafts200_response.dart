//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/draft_thread_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'threads_find_drafts200_response.g.dart';

/// ThreadsFindDrafts200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadsFindDrafts200Response implements ApiSuccessEnvelope, Built<ThreadsFindDrafts200Response, ThreadsFindDrafts200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<DraftThreadResponseDto> get data;

  ThreadsFindDrafts200Response._();

  factory ThreadsFindDrafts200Response([void updates(ThreadsFindDrafts200ResponseBuilder b)]) = _$ThreadsFindDrafts200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadsFindDrafts200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadsFindDrafts200Response> get serializer => _$ThreadsFindDrafts200ResponseSerializer();
}

class _$ThreadsFindDrafts200ResponseSerializer implements PrimitiveSerializer<ThreadsFindDrafts200Response> {
  @override
  final Iterable<Type> types = const [ThreadsFindDrafts200Response, _$ThreadsFindDrafts200Response];

  @override
  final String wireName = r'ThreadsFindDrafts200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadsFindDrafts200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(DraftThreadResponseDto)]),
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
    ThreadsFindDrafts200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadsFindDrafts200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DraftThreadResponseDto)]),
          ) as BuiltList<DraftThreadResponseDto>;
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
  ThreadsFindDrafts200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadsFindDrafts200ResponseBuilder();
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

class ThreadsFindDrafts200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadsFindDrafts200ResponseCodeEnum number0 = _$threadsFindDrafts200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadsFindDrafts200ResponseCodeEnum unknownDefaultOpenApi = _$threadsFindDrafts200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadsFindDrafts200ResponseCodeEnum> get serializer => _$threadsFindDrafts200ResponseCodeEnumSerializer;

  const ThreadsFindDrafts200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadsFindDrafts200ResponseCodeEnum> get values => _$threadsFindDrafts200ResponseCodeEnumValues;
  static ThreadsFindDrafts200ResponseCodeEnum valueOf(String name) => _$threadsFindDrafts200ResponseCodeEnumValueOf(name);
}
