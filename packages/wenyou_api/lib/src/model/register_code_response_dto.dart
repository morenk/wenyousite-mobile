//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'register_code_response_dto.g.dart';

/// RegisterCodeResponseDto
///
/// Properties:
/// * [emailSent]
/// * [codeExpiresIn] - 验证码有效秒数
/// * [message]
@BuiltValue()
abstract class RegisterCodeResponseDto implements Built<RegisterCodeResponseDto, RegisterCodeResponseDtoBuilder> {
  @BuiltValueField(wireName: r'emailSent')
  bool get emailSent;

  /// 验证码有效秒数
  @BuiltValueField(wireName: r'codeExpiresIn')
  num get codeExpiresIn;

  @BuiltValueField(wireName: r'message')
  String get message;

  RegisterCodeResponseDto._();

  factory RegisterCodeResponseDto([void updates(RegisterCodeResponseDtoBuilder b)]) = _$RegisterCodeResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RegisterCodeResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RegisterCodeResponseDto> get serializer => _$RegisterCodeResponseDtoSerializer();
}

class _$RegisterCodeResponseDtoSerializer implements PrimitiveSerializer<RegisterCodeResponseDto> {
  @override
  final Iterable<Type> types = const [RegisterCodeResponseDto, _$RegisterCodeResponseDto];

  @override
  final String wireName = r'RegisterCodeResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RegisterCodeResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'emailSent';
    yield serializers.serialize(
      object.emailSent,
      specifiedType: const FullType(bool),
    );
    yield r'codeExpiresIn';
    yield serializers.serialize(
      object.codeExpiresIn,
      specifiedType: const FullType(num),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RegisterCodeResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RegisterCodeResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'emailSent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.emailSent = valueDes;
          break;
        case r'codeExpiresIn':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.codeExpiresIn = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RegisterCodeResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RegisterCodeResponseDtoBuilder();
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
