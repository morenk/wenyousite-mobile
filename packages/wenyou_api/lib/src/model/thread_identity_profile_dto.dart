//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_identity_profile_dto.g.dart';

/// ThreadIdentityProfileDto
///
/// Properties:
/// * [id]
/// * [nickname]
/// * [avatarMediaId]
/// * [version]
@BuiltValue()
abstract class ThreadIdentityProfileDto implements Built<ThreadIdentityProfileDto, ThreadIdentityProfileDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'nickname')
  String? get nickname;

  @BuiltValueField(wireName: r'avatarMediaId')
  String? get avatarMediaId;

  @BuiltValueField(wireName: r'version')
  num get version;

  ThreadIdentityProfileDto._();

  factory ThreadIdentityProfileDto([void updates(ThreadIdentityProfileDtoBuilder b)]) = _$ThreadIdentityProfileDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadIdentityProfileDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadIdentityProfileDto> get serializer => _$ThreadIdentityProfileDtoSerializer();
}

class _$ThreadIdentityProfileDtoSerializer implements PrimitiveSerializer<ThreadIdentityProfileDto> {
  @override
  final Iterable<Type> types = const [ThreadIdentityProfileDto, _$ThreadIdentityProfileDto];

  @override
  final String wireName = r'ThreadIdentityProfileDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadIdentityProfileDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'nickname';
    yield object.nickname == null ? null : serializers.serialize(
      object.nickname,
      specifiedType: const FullType.nullable(String),
    );
    yield r'avatarMediaId';
    yield object.avatarMediaId == null ? null : serializers.serialize(
      object.avatarMediaId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadIdentityProfileDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadIdentityProfileDtoBuilder result,
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
        case r'nickname':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nickname = valueDes;
          break;
        case r'avatarMediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatarMediaId = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadIdentityProfileDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadIdentityProfileDtoBuilder();
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
