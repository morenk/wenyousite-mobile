//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_accounts_response_dto.g.dart';

/// AdminAccountsResponseDto
///
/// Properties:
/// * [accounts]
/// * [invites]
@BuiltValue()
abstract class AdminAccountsResponseDto implements Built<AdminAccountsResponseDto, AdminAccountsResponseDtoBuilder> {
  @BuiltValueField(wireName: r'accounts')
  BuiltList<BuiltMap<String, JsonObject?>> get accounts;

  @BuiltValueField(wireName: r'invites')
  BuiltList<BuiltMap<String, JsonObject?>> get invites;

  AdminAccountsResponseDto._();

  factory AdminAccountsResponseDto([void updates(AdminAccountsResponseDtoBuilder b)]) = _$AdminAccountsResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAccountsResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAccountsResponseDto> get serializer => _$AdminAccountsResponseDtoSerializer();
}

class _$AdminAccountsResponseDtoSerializer implements PrimitiveSerializer<AdminAccountsResponseDto> {
  @override
  final Iterable<Type> types = const [AdminAccountsResponseDto, _$AdminAccountsResponseDto];

  @override
  final String wireName = r'AdminAccountsResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAccountsResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accounts';
    yield serializers.serialize(
      object.accounts,
      specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
    );
    yield r'invites';
    yield serializers.serialize(
      object.invites,
      specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminAccountsResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAccountsResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accounts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
          ) as BuiltList<BuiltMap<String, JsonObject?>>;
          result.accounts.replace(valueDes);
          break;
        case r'invites':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
          ) as BuiltList<BuiltMap<String, JsonObject?>>;
          result.invites.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminAccountsResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAccountsResponseDtoBuilder();
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
