//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'verify_and_complete_dto.g.dart';

/// VerifyAndCompleteDto
///
/// Properties:
/// * [email] - 注册邮箱（需与上一步一致）
/// * [code] - 6 位数字验证码
/// * [username] - 用户名（字母、数字、中文）
/// * [password] - 登录密码（至少 8 位，需包含字母和数字）
@BuiltValue()
abstract class VerifyAndCompleteDto implements Built<VerifyAndCompleteDto, VerifyAndCompleteDtoBuilder> {
  /// 注册邮箱（需与上一步一致）
  @BuiltValueField(wireName: r'email')
  String get email;

  /// 6 位数字验证码
  @BuiltValueField(wireName: r'code')
  String get code;

  /// 用户名（字母、数字、中文）
  @BuiltValueField(wireName: r'username')
  String get username;

  /// 登录密码（至少 8 位，需包含字母和数字）
  @BuiltValueField(wireName: r'password')
  String get password;

  VerifyAndCompleteDto._();

  factory VerifyAndCompleteDto([void updates(VerifyAndCompleteDtoBuilder b)]) = _$VerifyAndCompleteDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VerifyAndCompleteDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VerifyAndCompleteDto> get serializer => _$VerifyAndCompleteDtoSerializer();
}

class _$VerifyAndCompleteDtoSerializer implements PrimitiveSerializer<VerifyAndCompleteDto> {
  @override
  final Iterable<Type> types = const [VerifyAndCompleteDto, _$VerifyAndCompleteDto];

  @override
  final String wireName = r'VerifyAndCompleteDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VerifyAndCompleteDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VerifyAndCompleteDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VerifyAndCompleteDtoBuilder result,
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
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VerifyAndCompleteDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VerifyAndCompleteDtoBuilder();
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
