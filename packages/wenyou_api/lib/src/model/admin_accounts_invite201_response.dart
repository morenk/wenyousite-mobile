//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_invite_created_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_accounts_invite201_response.g.dart';

/// AdminAccountsInvite201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminAccountsInvite201Response implements ApiSuccessEnvelope, Built<AdminAccountsInvite201Response, AdminAccountsInvite201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminInviteCreatedResponseDto get data;

  AdminAccountsInvite201Response._();

  factory AdminAccountsInvite201Response([void updates(AdminAccountsInvite201ResponseBuilder b)]) = _$AdminAccountsInvite201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAccountsInvite201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAccountsInvite201Response> get serializer => _$AdminAccountsInvite201ResponseSerializer();
}

class _$AdminAccountsInvite201ResponseSerializer implements PrimitiveSerializer<AdminAccountsInvite201Response> {
  @override
  final Iterable<Type> types = const [AdminAccountsInvite201Response, _$AdminAccountsInvite201Response];

  @override
  final String wireName = r'AdminAccountsInvite201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAccountsInvite201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminInviteCreatedResponseDto),
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
    AdminAccountsInvite201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAccountsInvite201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminInviteCreatedResponseDto),
          ) as AdminInviteCreatedResponseDto;
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
  AdminAccountsInvite201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAccountsInvite201ResponseBuilder();
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

class AdminAccountsInvite201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminAccountsInvite201ResponseCodeEnum number0 = _$adminAccountsInvite201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminAccountsInvite201ResponseCodeEnum unknownDefaultOpenApi = _$adminAccountsInvite201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminAccountsInvite201ResponseCodeEnum> get serializer => _$adminAccountsInvite201ResponseCodeEnumSerializer;

  const AdminAccountsInvite201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminAccountsInvite201ResponseCodeEnum> get values => _$adminAccountsInvite201ResponseCodeEnumValues;
  static AdminAccountsInvite201ResponseCodeEnum valueOf(String name) => _$adminAccountsInvite201ResponseCodeEnumValueOf(name);
}
