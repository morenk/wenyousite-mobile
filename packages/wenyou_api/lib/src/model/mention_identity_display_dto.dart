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
/// * [sourceHref] - 原始目标 href；与原 label 配对匹配节点，不以 occurrence 或 userId 单独匹配
/// * [targetIdentityId] - 稳定目标角色 ID；ACCOUNT/legacy 为 null，不随关闭/归档丢失。仅声明 Markdown 6 的读取返回角色目标
/// * [threadId] - 角色所属主题；跨页面身份卡读取使用，不能猜当前页面主题
/// * [userId]
/// * [label] - 正文 canonical mention 的原始标签（不含 @），与 userId 共同作为映射键
/// * [displayName] - 此次阅读应显示的名字；关闭时为账号用户名
/// * [identityId]
@BuiltValue()
abstract class MentionIdentityDisplayDto implements Built<MentionIdentityDisplayDto, MentionIdentityDisplayDtoBuilder> {
  /// 原始目标 href；与原 label 配对匹配节点，不以 occurrence 或 userId 单独匹配
  @BuiltValueField(wireName: r'sourceHref')
  String? get sourceHref;

  /// 稳定目标角色 ID；ACCOUNT/legacy 为 null，不随关闭/归档丢失。仅声明 Markdown 6 的读取返回角色目标
  @BuiltValueField(wireName: r'targetIdentityId')
  String? get targetIdentityId;

  /// 角色所属主题；跨页面身份卡读取使用，不能猜当前页面主题
  @BuiltValueField(wireName: r'threadId')
  String? get threadId;

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
    if (object.sourceHref != null) {
      yield r'sourceHref';
      yield serializers.serialize(
        object.sourceHref,
        specifiedType: const FullType(String),
      );
    }
    if (object.targetIdentityId != null) {
      yield r'targetIdentityId';
      yield serializers.serialize(
        object.targetIdentityId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.threadId != null) {
      yield r'threadId';
      yield serializers.serialize(
        object.threadId,
        specifiedType: const FullType(String),
      );
    }
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
        case r'sourceHref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceHref = valueDes;
          break;
        case r'targetIdentityId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.targetIdentityId = valueDes;
          break;
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.threadId = valueDes;
          break;
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
