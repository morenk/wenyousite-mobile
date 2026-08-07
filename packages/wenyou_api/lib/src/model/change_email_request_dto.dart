//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'change_email_request_dto.g.dart';

/// ChangeEmailRequestDto
///
/// Properties:
/// * [newEmail] - 新邮箱地址
/// * [oldPassword] - 当前密码（二次认证）
@BuiltValue()
abstract class ChangeEmailRequestDto implements Built<ChangeEmailRequestDto, ChangeEmailRequestDtoBuilder> {
  /// 新邮箱地址
  @BuiltValueField(wireName: r'newEmail')
  String get newEmail;

  /// 当前密码（二次认证）
  @BuiltValueField(wireName: r'oldPassword')
  String get oldPassword;

  ChangeEmailRequestDto._();

  factory ChangeEmailRequestDto([void updates(ChangeEmailRequestDtoBuilder b)]) = _$ChangeEmailRequestDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChangeEmailRequestDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChangeEmailRequestDto> get serializer => _$ChangeEmailRequestDtoSerializer();
}

class _$ChangeEmailRequestDtoSerializer implements PrimitiveSerializer<ChangeEmailRequestDto> {
  @override
  final Iterable<Type> types = const [ChangeEmailRequestDto, _$ChangeEmailRequestDto];

  @override
  final String wireName = r'ChangeEmailRequestDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChangeEmailRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'newEmail';
    yield serializers.serialize(
      object.newEmail,
      specifiedType: const FullType(String),
    );
    yield r'oldPassword';
    yield serializers.serialize(
      object.oldPassword,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChangeEmailRequestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChangeEmailRequestDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'newEmail':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.newEmail = valueDes;
          break;
        case r'oldPassword':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.oldPassword = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChangeEmailRequestDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChangeEmailRequestDtoBuilder();
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
