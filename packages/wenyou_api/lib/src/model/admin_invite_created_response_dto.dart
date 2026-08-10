//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_invite_created_response_dto.g.dart';

/// AdminInviteCreatedResponseDto
///
/// Properties:
/// * [id]
/// * [expiresAt]
@BuiltValue()
abstract class AdminInviteCreatedResponseDto implements Built<AdminInviteCreatedResponseDto, AdminInviteCreatedResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  AdminInviteCreatedResponseDto._();

  factory AdminInviteCreatedResponseDto([void updates(AdminInviteCreatedResponseDtoBuilder b)]) = _$AdminInviteCreatedResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminInviteCreatedResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminInviteCreatedResponseDto> get serializer => _$AdminInviteCreatedResponseDtoSerializer();
}

class _$AdminInviteCreatedResponseDtoSerializer implements PrimitiveSerializer<AdminInviteCreatedResponseDto> {
  @override
  final Iterable<Type> types = const [AdminInviteCreatedResponseDto, _$AdminInviteCreatedResponseDto];

  @override
  final String wireName = r'AdminInviteCreatedResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminInviteCreatedResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminInviteCreatedResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminInviteCreatedResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminInviteCreatedResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminInviteCreatedResponseDtoBuilder();
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
