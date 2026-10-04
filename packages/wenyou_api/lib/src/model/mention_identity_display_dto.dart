//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mention_identity_display_dto.g.dart';

/// MentionIdentityDisplayDto
///
/// Properties:
/// * [userId]
/// * [label] - 正文 canonical mention 的原始标签（不含 @），与 userId 共同作为映射键
/// * [displayName] - 此次阅读应显示的名字；关闭时为账号用户名
/// * [identityId]
@BuiltValue()
abstract class MentionIdentityDisplayDto implements Built<MentionIdentityDisplayDto, MentionIdentityDisplayDtoBuilder> {
  @BuiltValueField(wireName: r'userId')
  String get userId;

  /// 正文 canonical mention 的原始标签（不含 @），与 userId 共同作为映射键
  @BuiltValueField(wireName: r'label')
  String get label;

  /// 此次阅读应显示的名字；关闭时为账号用户名
  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  @BuiltValueField(wireName: r'identityId')
  String? get identityId;

  MentionIdentityDisplayDto._();

  factory MentionIdentityDisplayDto([void updates(MentionIdentityDisplayDtoBuilder b)]) = _$MentionIdentityDisplayDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MentionIdentityDisplayDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MentionIdentityDisplayDto> get serializer => _$MentionIdentityDisplayDtoSerializer();
}

class _$MentionIdentityDisplayDtoSerializer implements PrimitiveSerializer<MentionIdentityDisplayDto> {
  @override
  final Iterable<Type> types = const [MentionIdentityDisplayDto, _$MentionIdentityDisplayDto];

  @override
  final String wireName = r'MentionIdentityDisplayDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MentionIdentityDisplayDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'identityId';
    yield object.identityId == null ? null : serializers.serialize(
      object.identityId,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MentionIdentityDisplayDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MentionIdentityDisplayDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'identityId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.identityId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MentionIdentityDisplayDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MentionIdentityDisplayDtoBuilder();
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
