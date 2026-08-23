//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_draft_dto.g.dart';

/// CreateDraftDto
///
/// Properties:
/// * [clientRequestId] - 客户端创建幂等键；同一次提交和网络重试必须复用
/// * [content] - 草稿正文；待掷骰子作为内联节点包含在正文中
/// * [slot] - 草稿位（1-5），不传则自动选择空闲位
/// * [version] - 覆盖已有槽位时必填的当前乐观锁版本；创建空槽位时省略
@BuiltValue()
abstract class CreateDraftDto implements Built<CreateDraftDto, CreateDraftDtoBuilder> {
  /// 客户端创建幂等键；同一次提交和网络重试必须复用
  @BuiltValueField(wireName: r'clientRequestId')
  String? get clientRequestId;

  /// 草稿正文；待掷骰子作为内联节点包含在正文中
  @BuiltValueField(wireName: r'content')
  String get content;

  /// 草稿位（1-5），不传则自动选择空闲位
  @BuiltValueField(wireName: r'slot')
  num? get slot;

  /// 覆盖已有槽位时必填的当前乐观锁版本；创建空槽位时省略
  @BuiltValueField(wireName: r'version')
  num? get version;

  CreateDraftDto._();

  factory CreateDraftDto([void updates(CreateDraftDtoBuilder b)]) = _$CreateDraftDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateDraftDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateDraftDto> get serializer => _$CreateDraftDtoSerializer();
}

class _$CreateDraftDtoSerializer implements PrimitiveSerializer<CreateDraftDto> {
  @override
  final Iterable<Type> types = const [CreateDraftDto, _$CreateDraftDto];

  @override
  final String wireName = r'CreateDraftDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateDraftDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.clientRequestId != null) {
      yield r'clientRequestId';
      yield serializers.serialize(
        object.clientRequestId,
        specifiedType: const FullType(String),
      );
    }
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    if (object.slot != null) {
      yield r'slot';
      yield serializers.serialize(
        object.slot,
        specifiedType: const FullType(num),
      );
    }
    if (object.version != null) {
      yield r'version';
      yield serializers.serialize(
        object.version,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateDraftDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateDraftDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clientRequestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientRequestId = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.slot = valueDes;
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
  CreateDraftDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateDraftDtoBuilder();
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
