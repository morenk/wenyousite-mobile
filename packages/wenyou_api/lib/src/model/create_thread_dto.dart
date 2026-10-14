//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_thread_dto.g.dart';

/// CreateThreadDto
///
/// Properties:
/// * [markdownContractVersion] - 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
/// * [clientRequestId] - 客户端创建幂等键；同一次提交和网络重试必须复用
/// * [title] - 主题帖标题（可为空，发布时校验）
/// * [category] - 管理员配置的主题帖分类 slug；服务端会去除首尾空白并转为大写，草稿可暂不选择
/// * [content] - 默认子贴正文（kind=BODY，可选，留空仅创建空子贴）
/// * [subthreadTitle] - 默认子贴标题（可选，不填则取主题帖标题）
/// * [tagNames] - 主题帖标签名称列表
/// * [visibility] - 可见性
@BuiltValue()
abstract class CreateThreadDto implements Built<CreateThreadDto, CreateThreadDtoBuilder> {
  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueField(wireName: r'markdownContractVersion')
  CreateThreadDtoMarkdownContractVersionEnum? get markdownContractVersion;
  // enum markdownContractVersionEnum {  6,  };

  /// 客户端创建幂等键；同一次提交和网络重试必须复用
  @BuiltValueField(wireName: r'clientRequestId')
  String? get clientRequestId;

  /// 主题帖标题（可为空，发布时校验）
  @BuiltValueField(wireName: r'title')
  String? get title;

  /// 管理员配置的主题帖分类 slug；服务端会去除首尾空白并转为大写，草稿可暂不选择
  @BuiltValueField(wireName: r'category')
  String? get category;

  /// 默认子贴正文（kind=BODY，可选，留空仅创建空子贴）
  @BuiltValueField(wireName: r'content')
  String? get content;

  /// 默认子贴标题（可选，不填则取主题帖标题）
  @BuiltValueField(wireName: r'subthreadTitle')
  String? get subthreadTitle;

  /// 主题帖标签名称列表
  @BuiltValueField(wireName: r'tagNames')
  BuiltList<String>? get tagNames;

  /// 可见性
  @BuiltValueField(wireName: r'visibility')
  CreateThreadDtoVisibilityEnum? get visibility;
  // enum visibilityEnum {  PUBLIC,  PRIVATE,  };

  CreateThreadDto._();

  factory CreateThreadDto([void updates(CreateThreadDtoBuilder b)]) = _$CreateThreadDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateThreadDtoBuilder b) => b
      ..visibility = CreateThreadDtoVisibilityEnum.valueOf('PUBLIC');

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateThreadDto> get serializer => _$CreateThreadDtoSerializer();
}

class _$CreateThreadDtoSerializer implements PrimitiveSerializer<CreateThreadDto> {
  @override
  final Iterable<Type> types = const [CreateThreadDto, _$CreateThreadDto];

  @override
  final String wireName = r'CreateThreadDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateThreadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.markdownContractVersion != null) {
      yield r'markdownContractVersion';
      yield serializers.serialize(
        object.markdownContractVersion,
        specifiedType: const FullType(CreateThreadDtoMarkdownContractVersionEnum),
      );
    }
    if (object.clientRequestId != null) {
      yield r'clientRequestId';
      yield serializers.serialize(
        object.clientRequestId,
        specifiedType: const FullType(String),
      );
    }
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.category != null) {
      yield r'category';
      yield serializers.serialize(
        object.category,
        specifiedType: const FullType(String),
      );
    }
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
    if (object.subthreadTitle != null) {
      yield r'subthreadTitle';
      yield serializers.serialize(
        object.subthreadTitle,
        specifiedType: const FullType(String),
      );
    }
    if (object.tagNames != null) {
      yield r'tagNames';
      yield serializers.serialize(
        object.tagNames,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.visibility != null) {
      yield r'visibility';
      yield serializers.serialize(
        object.visibility,
        specifiedType: const FullType(CreateThreadDtoVisibilityEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateThreadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateThreadDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'markdownContractVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateThreadDtoMarkdownContractVersionEnum),
          ) as CreateThreadDtoMarkdownContractVersionEnum;
          result.markdownContractVersion = valueDes;
          break;
        case r'clientRequestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientRequestId = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.category = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'subthreadTitle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.subthreadTitle = valueDes;
          break;
        case r'tagNames':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.tagNames.replace(valueDes);
          break;
        case r'visibility':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateThreadDtoVisibilityEnum),
          ) as CreateThreadDtoVisibilityEnum;
          result.visibility = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateThreadDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateThreadDtoBuilder();
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

class CreateThreadDtoMarkdownContractVersionEnum extends EnumClass {

  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueEnumConst(wireNumber: 6)
  static const CreateThreadDtoMarkdownContractVersionEnum number6 = _$createThreadDtoMarkdownContractVersionEnum_number6;
  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const CreateThreadDtoMarkdownContractVersionEnum unknownDefaultOpenApi = _$createThreadDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;

  static Serializer<CreateThreadDtoMarkdownContractVersionEnum> get serializer => _$createThreadDtoMarkdownContractVersionEnumSerializer;

  const CreateThreadDtoMarkdownContractVersionEnum._(String name): super(name);

  static BuiltSet<CreateThreadDtoMarkdownContractVersionEnum> get values => _$createThreadDtoMarkdownContractVersionEnumValues;
  static CreateThreadDtoMarkdownContractVersionEnum valueOf(String name) => _$createThreadDtoMarkdownContractVersionEnumValueOf(name);
}

class CreateThreadDtoVisibilityEnum extends EnumClass {

  /// 可见性
  @BuiltValueEnumConst(wireName: r'PUBLIC')
  static const CreateThreadDtoVisibilityEnum PUBLIC = _$createThreadDtoVisibilityEnum_PUBLIC;
  /// 可见性
  @BuiltValueEnumConst(wireName: r'PRIVATE')
  static const CreateThreadDtoVisibilityEnum PRIVATE = _$createThreadDtoVisibilityEnum_PRIVATE;
  /// 可见性
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CreateThreadDtoVisibilityEnum unknownDefaultOpenApi = _$createThreadDtoVisibilityEnum_unknownDefaultOpenApi;

  static Serializer<CreateThreadDtoVisibilityEnum> get serializer => _$createThreadDtoVisibilityEnumSerializer;

  const CreateThreadDtoVisibilityEnum._(String name): super(name);

  static BuiltSet<CreateThreadDtoVisibilityEnum> get values => _$createThreadDtoVisibilityEnumValues;
  static CreateThreadDtoVisibilityEnum valueOf(String name) => _$createThreadDtoVisibilityEnumValueOf(name);
}
