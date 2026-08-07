//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_recipient_count_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_preview_recipients201_response.g.dart';

/// AdminPreviewRecipients201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminPreviewRecipients201Response implements ApiSuccessEnvelope, Built<AdminPreviewRecipients201Response, AdminPreviewRecipients201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminRecipientCountResponseDto get data;

  AdminPreviewRecipients201Response._();

  factory AdminPreviewRecipients201Response([void updates(AdminPreviewRecipients201ResponseBuilder b)]) = _$AdminPreviewRecipients201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminPreviewRecipients201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminPreviewRecipients201Response> get serializer => _$AdminPreviewRecipients201ResponseSerializer();
}

class _$AdminPreviewRecipients201ResponseSerializer implements PrimitiveSerializer<AdminPreviewRecipients201Response> {
  @override
  final Iterable<Type> types = const [AdminPreviewRecipients201Response, _$AdminPreviewRecipients201Response];

  @override
  final String wireName = r'AdminPreviewRecipients201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminPreviewRecipients201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminRecipientCountResponseDto),
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
    AdminPreviewRecipients201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminPreviewRecipients201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminRecipientCountResponseDto),
          ) as AdminRecipientCountResponseDto;
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
  AdminPreviewRecipients201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminPreviewRecipients201ResponseBuilder();
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

class AdminPreviewRecipients201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminPreviewRecipients201ResponseCodeEnum number0 = _$adminPreviewRecipients201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminPreviewRecipients201ResponseCodeEnum unknownDefaultOpenApi = _$adminPreviewRecipients201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminPreviewRecipients201ResponseCodeEnum> get serializer => _$adminPreviewRecipients201ResponseCodeEnumSerializer;

  const AdminPreviewRecipients201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminPreviewRecipients201ResponseCodeEnum> get values => _$adminPreviewRecipients201ResponseCodeEnumValues;
  static AdminPreviewRecipients201ResponseCodeEnum valueOf(String name) => _$adminPreviewRecipients201ResponseCodeEnumValueOf(name);
}
