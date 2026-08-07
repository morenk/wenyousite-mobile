//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/invite_preview_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'threads_preview_invite_link200_response.g.dart';

/// ThreadsPreviewInviteLink200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadsPreviewInviteLink200Response implements ApiSuccessEnvelope, Built<ThreadsPreviewInviteLink200Response, ThreadsPreviewInviteLink200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  InvitePreviewResponseDto get data;

  ThreadsPreviewInviteLink200Response._();

  factory ThreadsPreviewInviteLink200Response([void updates(ThreadsPreviewInviteLink200ResponseBuilder b)]) = _$ThreadsPreviewInviteLink200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadsPreviewInviteLink200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadsPreviewInviteLink200Response> get serializer => _$ThreadsPreviewInviteLink200ResponseSerializer();
}

class _$ThreadsPreviewInviteLink200ResponseSerializer implements PrimitiveSerializer<ThreadsPreviewInviteLink200Response> {
  @override
  final Iterable<Type> types = const [ThreadsPreviewInviteLink200Response, _$ThreadsPreviewInviteLink200Response];

  @override
  final String wireName = r'ThreadsPreviewInviteLink200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadsPreviewInviteLink200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(InvitePreviewResponseDto),
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
    ThreadsPreviewInviteLink200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadsPreviewInviteLink200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(InvitePreviewResponseDto),
          ) as InvitePreviewResponseDto;
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
  ThreadsPreviewInviteLink200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadsPreviewInviteLink200ResponseBuilder();
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

class ThreadsPreviewInviteLink200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadsPreviewInviteLink200ResponseCodeEnum number0 = _$threadsPreviewInviteLink200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadsPreviewInviteLink200ResponseCodeEnum unknownDefaultOpenApi = _$threadsPreviewInviteLink200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadsPreviewInviteLink200ResponseCodeEnum> get serializer => _$threadsPreviewInviteLink200ResponseCodeEnumSerializer;

  const ThreadsPreviewInviteLink200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadsPreviewInviteLink200ResponseCodeEnum> get values => _$threadsPreviewInviteLink200ResponseCodeEnumValues;
  static ThreadsPreviewInviteLink200ResponseCodeEnum valueOf(String name) => _$threadsPreviewInviteLink200ResponseCodeEnumValueOf(name);
}
