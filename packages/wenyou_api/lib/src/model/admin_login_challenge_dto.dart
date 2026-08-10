//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_login_challenge_dto.g.dart';

/// AdminLoginChallengeDto
///
/// Properties:
/// * [account] - 管理员邮箱或用户名
/// * [password]
@BuiltValue()
abstract class AdminLoginChallengeDto implements Built<AdminLoginChallengeDto, AdminLoginChallengeDtoBuilder> {
  /// 管理员邮箱或用户名
  @BuiltValueField(wireName: r'account')
  String get account;

  @BuiltValueField(wireName: r'password')
  String get password;

  AdminLoginChallengeDto._();

  factory AdminLoginChallengeDto([void updates(AdminLoginChallengeDtoBuilder b)]) = _$AdminLoginChallengeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminLoginChallengeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminLoginChallengeDto> get serializer => _$AdminLoginChallengeDtoSerializer();
}

class _$AdminLoginChallengeDtoSerializer implements PrimitiveSerializer<AdminLoginChallengeDto> {
  @override
  final Iterable<Type> types = const [AdminLoginChallengeDto, _$AdminLoginChallengeDto];

  @override
  final String wireName = r'AdminLoginChallengeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminLoginChallengeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'account';
    yield serializers.serialize(
      object.account,
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
    AdminLoginChallengeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminLoginChallengeDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'account':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.account = valueDes;
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
  AdminLoginChallengeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminLoginChallengeDtoBuilder();
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
