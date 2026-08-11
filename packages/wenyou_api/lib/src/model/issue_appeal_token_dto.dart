//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'issue_appeal_token_dto.g.dart';

/// IssueAppealTokenDto
///
/// Properties:
/// * [account] - 邮箱或大小写敏感的用户名
/// * [password]
@BuiltValue()
abstract class IssueAppealTokenDto implements Built<IssueAppealTokenDto, IssueAppealTokenDtoBuilder> {
  /// 邮箱或大小写敏感的用户名
  @BuiltValueField(wireName: r'account')
  String get account;

  @BuiltValueField(wireName: r'password')
  String get password;

  IssueAppealTokenDto._();

  factory IssueAppealTokenDto([void updates(IssueAppealTokenDtoBuilder b)]) = _$IssueAppealTokenDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IssueAppealTokenDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IssueAppealTokenDto> get serializer => _$IssueAppealTokenDtoSerializer();
}

class _$IssueAppealTokenDtoSerializer implements PrimitiveSerializer<IssueAppealTokenDto> {
  @override
  final Iterable<Type> types = const [IssueAppealTokenDto, _$IssueAppealTokenDto];

  @override
  final String wireName = r'IssueAppealTokenDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IssueAppealTokenDto object, {
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
    IssueAppealTokenDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IssueAppealTokenDtoBuilder result,
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
  IssueAppealTokenDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IssueAppealTokenDtoBuilder();
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
