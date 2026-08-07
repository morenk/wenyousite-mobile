//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'change_email_verify_dto.g.dart';

/// ChangeEmailVerifyDto
///
/// Properties:
/// * [newEmail] - 新邮箱地址
/// * [code] - 6 位邮箱验证码
@BuiltValue()
abstract class ChangeEmailVerifyDto implements Built<ChangeEmailVerifyDto, ChangeEmailVerifyDtoBuilder> {
  /// 新邮箱地址
  @BuiltValueField(wireName: r'newEmail')
  String get newEmail;

  /// 6 位邮箱验证码
  @BuiltValueField(wireName: r'code')
  String get code;

  ChangeEmailVerifyDto._();

  factory ChangeEmailVerifyDto([void updates(ChangeEmailVerifyDtoBuilder b)]) = _$ChangeEmailVerifyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChangeEmailVerifyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChangeEmailVerifyDto> get serializer => _$ChangeEmailVerifyDtoSerializer();
}

class _$ChangeEmailVerifyDtoSerializer implements PrimitiveSerializer<ChangeEmailVerifyDto> {
  @override
  final Iterable<Type> types = const [ChangeEmailVerifyDto, _$ChangeEmailVerifyDto];

  @override
  final String wireName = r'ChangeEmailVerifyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChangeEmailVerifyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'newEmail';
    yield serializers.serialize(
      object.newEmail,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChangeEmailVerifyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChangeEmailVerifyDtoBuilder result,
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
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  ChangeEmailVerifyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChangeEmailVerifyDtoBuilder();
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
