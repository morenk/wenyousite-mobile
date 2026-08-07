//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_member_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_members_find_all200_response.g.dart';

/// ThreadMembersFindAll200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadMembersFindAll200Response implements ApiSuccessEnvelope, Built<ThreadMembersFindAll200Response, ThreadMembersFindAll200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ThreadMemberResponseDto> get data;

  ThreadMembersFindAll200Response._();

  factory ThreadMembersFindAll200Response([void updates(ThreadMembersFindAll200ResponseBuilder b)]) = _$ThreadMembersFindAll200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadMembersFindAll200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadMembersFindAll200Response> get serializer => _$ThreadMembersFindAll200ResponseSerializer();
}

class _$ThreadMembersFindAll200ResponseSerializer implements PrimitiveSerializer<ThreadMembersFindAll200Response> {
  @override
  final Iterable<Type> types = const [ThreadMembersFindAll200Response, _$ThreadMembersFindAll200Response];

  @override
  final String wireName = r'ThreadMembersFindAll200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadMembersFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(ThreadMemberResponseDto)]),
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
    ThreadMembersFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadMembersFindAll200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ThreadMemberResponseDto)]),
          ) as BuiltList<ThreadMemberResponseDto>;
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
  ThreadMembersFindAll200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadMembersFindAll200ResponseBuilder();
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

class ThreadMembersFindAll200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadMembersFindAll200ResponseCodeEnum number0 = _$threadMembersFindAll200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadMembersFindAll200ResponseCodeEnum unknownDefaultOpenApi = _$threadMembersFindAll200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadMembersFindAll200ResponseCodeEnum> get serializer => _$threadMembersFindAll200ResponseCodeEnumSerializer;

  const ThreadMembersFindAll200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadMembersFindAll200ResponseCodeEnum> get values => _$threadMembersFindAll200ResponseCodeEnumValues;
  static ThreadMembersFindAll200ResponseCodeEnum valueOf(String name) => _$threadMembersFindAll200ResponseCodeEnumValueOf(name);
}
