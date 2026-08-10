//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_accounts_revoke200_response.g.dart';

/// AdminAccountsRevoke200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminAccountsRevoke200Response implements ApiSuccessEnvelope, Built<AdminAccountsRevoke200Response, AdminAccountsRevoke200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  AdminAccountsRevoke200Response._();

  factory AdminAccountsRevoke200Response([void updates(AdminAccountsRevoke200ResponseBuilder b)]) = _$AdminAccountsRevoke200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAccountsRevoke200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAccountsRevoke200Response> get serializer => _$AdminAccountsRevoke200ResponseSerializer();
}

class _$AdminAccountsRevoke200ResponseSerializer implements PrimitiveSerializer<AdminAccountsRevoke200Response> {
  @override
  final Iterable<Type> types = const [AdminAccountsRevoke200Response, _$AdminAccountsRevoke200Response];

  @override
  final String wireName = r'AdminAccountsRevoke200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAccountsRevoke200Response object, {
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
    AdminAccountsRevoke200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAccountsRevoke200ResponseBuilder result,
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
  AdminAccountsRevoke200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAccountsRevoke200ResponseBuilder();
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

class AdminAccountsRevoke200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminAccountsRevoke200ResponseCodeEnum number0 = _$adminAccountsRevoke200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminAccountsRevoke200ResponseCodeEnum unknownDefaultOpenApi = _$adminAccountsRevoke200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminAccountsRevoke200ResponseCodeEnum> get serializer => _$adminAccountsRevoke200ResponseCodeEnumSerializer;

  const AdminAccountsRevoke200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminAccountsRevoke200ResponseCodeEnum> get values => _$adminAccountsRevoke200ResponseCodeEnumValues;
  static AdminAccountsRevoke200ResponseCodeEnum valueOf(String name) => _$adminAccountsRevoke200ResponseCodeEnumValueOf(name);
}
