//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_post_dto.g.dart';

/// CreatePostDto
///
/// Properties:
/// * [content] - 帖子正文；骰子使用 [[dice:v1:<UUID>:<NdM±K>]] 内联节点
/// * [parentPostId] - 父楼层 ID（楼中楼回复时指定，平级挂载，无嵌套深度限制）
/// * [replyToPostId] - 回复目标帖 ID；必须同时提供 parentPostId，且目标属于该主楼层
/// * [clientRequestId] - 客户端创建请求幂等键；同一次用户提交及网络重试必须复用
@BuiltValue()
abstract class CreatePostDto implements Built<CreatePostDto, CreatePostDtoBuilder> {
  /// 帖子正文；骰子使用 [[dice:v1:<UUID>:<NdM±K>]] 内联节点
  @BuiltValueField(wireName: r'content')
  String get content;

  /// 父楼层 ID（楼中楼回复时指定，平级挂载，无嵌套深度限制）
  @BuiltValueField(wireName: r'parentPostId')
  String? get parentPostId;

  /// 回复目标帖 ID；必须同时提供 parentPostId，且目标属于该主楼层
  @BuiltValueField(wireName: r'replyToPostId')
  String? get replyToPostId;

  /// 客户端创建请求幂等键；同一次用户提交及网络重试必须复用
  @BuiltValueField(wireName: r'clientRequestId')
  String? get clientRequestId;

  CreatePostDto._();

  factory CreatePostDto([void updates(CreatePostDtoBuilder b)]) = _$CreatePostDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreatePostDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreatePostDto> get serializer => _$CreatePostDtoSerializer();
}

class _$CreatePostDtoSerializer implements PrimitiveSerializer<CreatePostDto> {
  @override
  final Iterable<Type> types = const [CreatePostDto, _$CreatePostDto];

  @override
  final String wireName = r'CreatePostDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreatePostDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    if (object.parentPostId != null) {
      yield r'parentPostId';
      yield serializers.serialize(
        object.parentPostId,
        specifiedType: const FullType(String),
      );
    }
    if (object.replyToPostId != null) {
      yield r'replyToPostId';
      yield serializers.serialize(
        object.replyToPostId,
        specifiedType: const FullType(String),
      );
    }
    if (object.clientRequestId != null) {
      yield r'clientRequestId';
      yield serializers.serialize(
        object.clientRequestId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreatePostDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreatePostDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'parentPostId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.parentPostId = valueDes;
          break;
        case r'replyToPostId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.replyToPostId = valueDes;
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
  CreatePostDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreatePostDtoBuilder();
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
