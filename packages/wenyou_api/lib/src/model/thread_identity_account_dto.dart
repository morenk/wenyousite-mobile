//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_identity_account_dto.g.dart';

/// ThreadIdentityAccountDto
///
/// Properties:
/// * [id]
/// * [username]
/// * [avatar]
@BuiltValue()
abstract class ThreadIdentityAccountDto implements Built<ThreadIdentityAccountDto, ThreadIdentityAccountDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  ThreadIdentityAccountDto._();

  factory ThreadIdentityAccountDto([void updates(ThreadIdentityAccountDtoBuilder b)]) = _$ThreadIdentityAccountDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadIdentityAccountDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadIdentityAccountDto> get serializer => _$ThreadIdentityAccountDtoSerializer();
}

class _$ThreadIdentityAccountDtoSerializer implements PrimitiveSerializer<ThreadIdentityAccountDto> {
  @override
  final Iterable<Type> types = const [ThreadIdentityAccountDto, _$ThreadIdentityAccountDto];

  @override
  final String wireName = r'ThreadIdentityAccountDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadIdentityAccountDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'avatar';
    yield object.avatar == null ? null : serializers.serialize(
      object.avatar,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadIdentityAccountDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadIdentityAccountDtoBuilder result,
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
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'avatar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatar = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadIdentityAccountDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadIdentityAccountDtoBuilder();
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
