//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_admin_invite_dto.g.dart';

/// CreateAdminInviteDto
///
/// Properties:
/// * [userId] - 已验证邮箱的现有温油账号 ID
@BuiltValue()
abstract class CreateAdminInviteDto implements Built<CreateAdminInviteDto, CreateAdminInviteDtoBuilder> {
  /// 已验证邮箱的现有温油账号 ID
  @BuiltValueField(wireName: r'userId')
  String get userId;

  CreateAdminInviteDto._();

  factory CreateAdminInviteDto([void updates(CreateAdminInviteDtoBuilder b)]) = _$CreateAdminInviteDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateAdminInviteDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateAdminInviteDto> get serializer => _$CreateAdminInviteDtoSerializer();
}

class _$CreateAdminInviteDtoSerializer implements PrimitiveSerializer<CreateAdminInviteDto> {
  @override
  final Iterable<Type> types = const [CreateAdminInviteDto, _$CreateAdminInviteDto];

  @override
  final String wireName = r'CreateAdminInviteDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateAdminInviteDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateAdminInviteDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateAdminInviteDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateAdminInviteDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateAdminInviteDtoBuilder();
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
