//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_session_response_dto.g.dart';

/// AdminSessionResponseDto
///
/// Properties:
/// * [session]
/// * [user]
/// * [csrfToken]
@BuiltValue()
abstract class AdminSessionResponseDto implements Built<AdminSessionResponseDto, AdminSessionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'session')
  BuiltMap<String, JsonObject?> get session;

  @BuiltValueField(wireName: r'user')
  BuiltMap<String, JsonObject?> get user;

  @BuiltValueField(wireName: r'csrfToken')
  String get csrfToken;

  AdminSessionResponseDto._();

  factory AdminSessionResponseDto([void updates(AdminSessionResponseDtoBuilder b)]) = _$AdminSessionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminSessionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminSessionResponseDto> get serializer => _$AdminSessionResponseDtoSerializer();
}

class _$AdminSessionResponseDtoSerializer implements PrimitiveSerializer<AdminSessionResponseDto> {
  @override
  final Iterable<Type> types = const [AdminSessionResponseDto, _$AdminSessionResponseDto];

  @override
  final String wireName = r'AdminSessionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminSessionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'session';
    yield serializers.serialize(
      object.session,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'csrfToken';
    yield serializers.serialize(
      object.csrfToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminSessionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminSessionResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'session':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.session.replace(valueDes);
          break;
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.user.replace(valueDes);
          break;
        case r'csrfToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.csrfToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminSessionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminSessionResponseDtoBuilder();
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
