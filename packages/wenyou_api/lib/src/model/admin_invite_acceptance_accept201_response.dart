//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_invite_acceptance_accept201_response.g.dart';

/// AdminInviteAcceptanceAccept201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminInviteAcceptanceAccept201Response implements ApiSuccessEnvelope, Built<AdminInviteAcceptanceAccept201Response, AdminInviteAcceptanceAccept201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  AdminInviteAcceptanceAccept201Response._();

  factory AdminInviteAcceptanceAccept201Response([void updates(AdminInviteAcceptanceAccept201ResponseBuilder b)]) = _$AdminInviteAcceptanceAccept201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminInviteAcceptanceAccept201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminInviteAcceptanceAccept201Response> get serializer => _$AdminInviteAcceptanceAccept201ResponseSerializer();
}

class _$AdminInviteAcceptanceAccept201ResponseSerializer implements PrimitiveSerializer<AdminInviteAcceptanceAccept201Response> {
  @override
  final Iterable<Type> types = const [AdminInviteAcceptanceAccept201Response, _$AdminInviteAcceptanceAccept201Response];

  @override
  final String wireName = r'AdminInviteAcceptanceAccept201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminInviteAcceptanceAccept201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MessageResponseDto),
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
    AdminInviteAcceptanceAccept201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminInviteAcceptanceAccept201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MessageResponseDto),
          ) as MessageResponseDto;
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
  AdminInviteAcceptanceAccept201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminInviteAcceptanceAccept201ResponseBuilder();
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

class AdminInviteAcceptanceAccept201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminInviteAcceptanceAccept201ResponseCodeEnum number0 = _$adminInviteAcceptanceAccept201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminInviteAcceptanceAccept201ResponseCodeEnum unknownDefaultOpenApi = _$adminInviteAcceptanceAccept201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminInviteAcceptanceAccept201ResponseCodeEnum> get serializer => _$adminInviteAcceptanceAccept201ResponseCodeEnumSerializer;

  const AdminInviteAcceptanceAccept201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminInviteAcceptanceAccept201ResponseCodeEnum> get values => _$adminInviteAcceptanceAccept201ResponseCodeEnumValues;
  static AdminInviteAcceptanceAccept201ResponseCodeEnum valueOf(String name) => _$adminInviteAcceptanceAccept201ResponseCodeEnumValueOf(name);
}
