//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_accounts_transfer201_response.g.dart';

/// AdminAccountsTransfer201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminAccountsTransfer201Response implements ApiSuccessEnvelope, Built<AdminAccountsTransfer201Response, AdminAccountsTransfer201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  AdminAccountsTransfer201Response._();

  factory AdminAccountsTransfer201Response([void updates(AdminAccountsTransfer201ResponseBuilder b)]) = _$AdminAccountsTransfer201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAccountsTransfer201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAccountsTransfer201Response> get serializer => _$AdminAccountsTransfer201ResponseSerializer();
}

class _$AdminAccountsTransfer201ResponseSerializer implements PrimitiveSerializer<AdminAccountsTransfer201Response> {
  @override
  final Iterable<Type> types = const [AdminAccountsTransfer201Response, _$AdminAccountsTransfer201Response];

  @override
  final String wireName = r'AdminAccountsTransfer201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAccountsTransfer201Response object, {
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
    AdminAccountsTransfer201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAccountsTransfer201ResponseBuilder result,
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
  AdminAccountsTransfer201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAccountsTransfer201ResponseBuilder();
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

class AdminAccountsTransfer201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminAccountsTransfer201ResponseCodeEnum number0 = _$adminAccountsTransfer201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminAccountsTransfer201ResponseCodeEnum unknownDefaultOpenApi = _$adminAccountsTransfer201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminAccountsTransfer201ResponseCodeEnum> get serializer => _$adminAccountsTransfer201ResponseCodeEnumSerializer;

  const AdminAccountsTransfer201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminAccountsTransfer201ResponseCodeEnum> get values => _$adminAccountsTransfer201ResponseCodeEnumValues;
  static AdminAccountsTransfer201ResponseCodeEnum valueOf(String name) => _$adminAccountsTransfer201ResponseCodeEnumValueOf(name);
}
