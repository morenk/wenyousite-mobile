//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resend_verification_dto.g.dart';

/// ResendVerificationDto
///
/// Properties:
/// * [email] - 需要重发验证邮件的邮箱
@BuiltValue()
abstract class ResendVerificationDto implements Built<ResendVerificationDto, ResendVerificationDtoBuilder> {
  /// 需要重发验证邮件的邮箱
  @BuiltValueField(wireName: r'email')
  String get email;

  ResendVerificationDto._();

  factory ResendVerificationDto([void updates(ResendVerificationDtoBuilder b)]) = _$ResendVerificationDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResendVerificationDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResendVerificationDto> get serializer => _$ResendVerificationDtoSerializer();
}

class _$ResendVerificationDtoSerializer implements PrimitiveSerializer<ResendVerificationDto> {
  @override
  final Iterable<Type> types = const [ResendVerificationDto, _$ResendVerificationDto];

  @override
  final String wireName = r'ResendVerificationDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResendVerificationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResendVerificationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ResendVerificationDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ResendVerificationDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResendVerificationDtoBuilder();
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
