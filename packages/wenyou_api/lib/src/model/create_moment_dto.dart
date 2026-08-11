//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_moment_dto.g.dart';

/// CreateMomentDto
///
/// Properties:
/// * [title] - 动态标题，纯文本
/// * [content] - 动态正文字串；可按 internal-reference v1 嵌入命名站内传送门，其他 Markdown 按普通文本处理
/// * [mediaIds] - 已完成处理的图片 ID，顺序即展示顺序
/// * [coverMediaId] - 必须属于 mediaIds；无图时为 null
/// * [clientRequestId] - 发布幂等键，同时决定无图文字封面配色
@BuiltValue()
abstract class CreateMomentDto implements Built<CreateMomentDto, CreateMomentDtoBuilder> {
  /// 动态标题，纯文本
  @BuiltValueField(wireName: r'title')
  String get title;

  /// 动态正文字串；可按 internal-reference v1 嵌入命名站内传送门，其他 Markdown 按普通文本处理
  @BuiltValueField(wireName: r'content')
  String? get content;

  /// 已完成处理的图片 ID，顺序即展示顺序
  @BuiltValueField(wireName: r'mediaIds')
  BuiltList<String> get mediaIds;

  /// 必须属于 mediaIds；无图时为 null
  @BuiltValueField(wireName: r'coverMediaId')
  String? get coverMediaId;

  /// 发布幂等键，同时决定无图文字封面配色
  @BuiltValueField(wireName: r'clientRequestId')
  String get clientRequestId;

  CreateMomentDto._();

  factory CreateMomentDto([void updates(CreateMomentDtoBuilder b)]) = _$CreateMomentDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateMomentDtoBuilder b) => b
      ..content = ''
      ..mediaIds = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateMomentDto> get serializer => _$CreateMomentDtoSerializer();
}

class _$CreateMomentDtoSerializer implements PrimitiveSerializer<CreateMomentDto> {
  @override
  final Iterable<Type> types = const [CreateMomentDto, _$CreateMomentDto];

  @override
  final String wireName = r'CreateMomentDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateMomentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
    yield r'mediaIds';
    yield serializers.serialize(
      object.mediaIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    if (object.coverMediaId != null) {
      yield r'coverMediaId';
      yield serializers.serialize(
        object.coverMediaId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'clientRequestId';
    yield serializers.serialize(
      object.clientRequestId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateMomentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateMomentDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'mediaIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.mediaIds.replace(valueDes);
          break;
        case r'coverMediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.coverMediaId = valueDes;
          break;
        case r'clientRequestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientRequestId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateMomentDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateMomentDtoBuilder();
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
