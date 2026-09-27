//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_login_verify_dto.g.dart';

/// AdminLoginVerifyDto
///
/// Properties:
/// * [challengeId]
/// * [code]
/// * [rememberDevice] - 记住此设备七天，省略时沿用短会话
@BuiltValue()
abstract class AdminLoginVerifyDto implements Built<AdminLoginVerifyDto, AdminLoginVerifyDtoBuilder> {
  @BuiltValueField(wireName: r'challengeId')
  String get challengeId;

  @BuiltValueField(wireName: r'code')
  String get code;

  /// 记住此设备七天，省略时沿用短会话
  @BuiltValueField(wireName: r'rememberDevice')
  bool? get rememberDevice;

  AdminLoginVerifyDto._();

  factory AdminLoginVerifyDto([void updates(AdminLoginVerifyDtoBuilder b)]) = _$AdminLoginVerifyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminLoginVerifyDtoBuilder b) => b
      ..rememberDevice = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminLoginVerifyDto> get serializer => _$AdminLoginVerifyDtoSerializer();
}

class _$AdminLoginVerifyDtoSerializer implements PrimitiveSerializer<AdminLoginVerifyDto> {
  @override
  final Iterable<Type> types = const [AdminLoginVerifyDto, _$AdminLoginVerifyDto];

  @override
  final String wireName = r'AdminLoginVerifyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminLoginVerifyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'challengeId';
    yield serializers.serialize(
      object.challengeId,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    if (object.rememberDevice != null) {
      yield r'rememberDevice';
      yield serializers.serialize(
        object.rememberDevice,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminLoginVerifyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminLoginVerifyDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'challengeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.challengeId = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'rememberDevice':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.rememberDevice = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminLoginVerifyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminLoginVerifyDtoBuilder();
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
