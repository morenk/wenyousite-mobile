//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_recipient_count_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_send_system_notification201_response.g.dart';

/// AdminSendSystemNotification201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminSendSystemNotification201Response implements ApiSuccessEnvelope, Built<AdminSendSystemNotification201Response, AdminSendSystemNotification201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminRecipientCountResponseDto get data;

  AdminSendSystemNotification201Response._();

  factory AdminSendSystemNotification201Response([void updates(AdminSendSystemNotification201ResponseBuilder b)]) = _$AdminSendSystemNotification201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminSendSystemNotification201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminSendSystemNotification201Response> get serializer => _$AdminSendSystemNotification201ResponseSerializer();
}

class _$AdminSendSystemNotification201ResponseSerializer implements PrimitiveSerializer<AdminSendSystemNotification201Response> {
  @override
  final Iterable<Type> types = const [AdminSendSystemNotification201Response, _$AdminSendSystemNotification201Response];

  @override
  final String wireName = r'AdminSendSystemNotification201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminSendSystemNotification201Response object, {
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
    AdminSendSystemNotification201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminSendSystemNotification201ResponseBuilder result,
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
  AdminSendSystemNotification201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminSendSystemNotification201ResponseBuilder();
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

class AdminSendSystemNotification201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminSendSystemNotification201ResponseCodeEnum number0 = _$adminSendSystemNotification201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminSendSystemNotification201ResponseCodeEnum unknownDefaultOpenApi = _$adminSendSystemNotification201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminSendSystemNotification201ResponseCodeEnum> get serializer => _$adminSendSystemNotification201ResponseCodeEnumSerializer;

  const AdminSendSystemNotification201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminSendSystemNotification201ResponseCodeEnum> get values => _$adminSendSystemNotification201ResponseCodeEnumValues;
  static AdminSendSystemNotification201ResponseCodeEnum valueOf(String name) => _$adminSendSystemNotification201ResponseCodeEnumValueOf(name);
}
