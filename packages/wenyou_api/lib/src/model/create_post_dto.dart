//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_post_dto.g.dart';

/// CreatePostDto
///
/// Properties:
/// * [markdownContractVersion] - 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
/// * [identityId] - 本次新发言选择的帖内身份 ID；新客户端 RP 模式必须与该身份 token 一起发送。省略仅兼容旧单身份客户端；ACCOUNT 忽略，编辑旧正文不改变原身份
/// * [identityToken] - GET 帖内身份返回的确认 token；新建正文或发言时使用。身份变化返回 409/40011，保留草稿并重新确认
/// * [identityMode] - 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
/// * [content] - 帖子正文；骰子使用 [[dice:v1:<UUID>:<NdM±K>]] 内联节点
/// * [parentPostId] - 父楼层 ID（楼中楼回复时指定，平级挂载，无嵌套深度限制）
/// * [replyToPostId] - 回复目标帖 ID；必须同时提供 parentPostId，且目标属于该主楼层
/// * [clientRequestId] - 客户端创建请求幂等键；同一次用户提交及网络重试必须复用
@BuiltValue()
abstract class CreatePostDto implements Built<CreatePostDto, CreatePostDtoBuilder> {
  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueField(wireName: r'markdownContractVersion')
  CreatePostDtoMarkdownContractVersionEnum? get markdownContractVersion;
  // enum markdownContractVersionEnum {  6,  };

  /// 本次新发言选择的帖内身份 ID；新客户端 RP 模式必须与该身份 token 一起发送。省略仅兼容旧单身份客户端；ACCOUNT 忽略，编辑旧正文不改变原身份
  @BuiltValueField(wireName: r'identityId')
  String? get identityId;

  /// GET 帖内身份返回的确认 token；新建正文或发言时使用。身份变化返回 409/40011，保留草稿并重新确认
  @BuiltValueField(wireName: r'identityToken')
  String? get identityToken;

  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueField(wireName: r'identityMode')
  CreatePostDtoIdentityModeEnum? get identityMode;
  // enum identityModeEnum {  ACCOUNT,  RP,  };

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
    if (object.markdownContractVersion != null) {
      yield r'markdownContractVersion';
      yield serializers.serialize(
        object.markdownContractVersion,
        specifiedType: const FullType(CreatePostDtoMarkdownContractVersionEnum),
      );
    }
    if (object.identityId != null) {
      yield r'identityId';
      yield serializers.serialize(
        object.identityId,
        specifiedType: const FullType(String),
      );
    }
    if (object.identityToken != null) {
      yield r'identityToken';
      yield serializers.serialize(
        object.identityToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.identityMode != null) {
      yield r'identityMode';
      yield serializers.serialize(
        object.identityMode,
        specifiedType: const FullType(CreatePostDtoIdentityModeEnum),
      );
    }
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
        case r'markdownContractVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreatePostDtoMarkdownContractVersionEnum),
          ) as CreatePostDtoMarkdownContractVersionEnum;
          result.markdownContractVersion = valueDes;
          break;
        case r'identityId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.identityId = valueDes;
          break;
        case r'identityToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.identityToken = valueDes;
          break;
        case r'identityMode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreatePostDtoIdentityModeEnum),
          ) as CreatePostDtoIdentityModeEnum;
          result.identityMode = valueDes;
          break;
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

class CreatePostDtoMarkdownContractVersionEnum extends EnumClass {

  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueEnumConst(wireName: r'6')
  static const CreatePostDtoMarkdownContractVersionEnum n6 = _$createPostDtoMarkdownContractVersionEnum_n6;
  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const CreatePostDtoMarkdownContractVersionEnum unknownDefaultOpenApi = _$createPostDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;

  static Serializer<CreatePostDtoMarkdownContractVersionEnum> get serializer => _$createPostDtoMarkdownContractVersionEnumSerializer;

  const CreatePostDtoMarkdownContractVersionEnum._(String name): super(name);

  static BuiltSet<CreatePostDtoMarkdownContractVersionEnum> get values => _$createPostDtoMarkdownContractVersionEnumValues;
  static CreatePostDtoMarkdownContractVersionEnum valueOf(String name) => _$createPostDtoMarkdownContractVersionEnumValueOf(name);
}

class CreatePostDtoIdentityModeEnum extends EnumClass {

  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueEnumConst(wireName: r'ACCOUNT')
  static const CreatePostDtoIdentityModeEnum ACCOUNT = _$createPostDtoIdentityModeEnum_ACCOUNT;
  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueEnumConst(wireName: r'RP')
  static const CreatePostDtoIdentityModeEnum RP = _$createPostDtoIdentityModeEnum_RP;
  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CreatePostDtoIdentityModeEnum unknownDefaultOpenApi = _$createPostDtoIdentityModeEnum_unknownDefaultOpenApi;

  static Serializer<CreatePostDtoIdentityModeEnum> get serializer => _$createPostDtoIdentityModeEnumSerializer;

  const CreatePostDtoIdentityModeEnum._(String name): super(name);

  static BuiltSet<CreatePostDtoIdentityModeEnum> get values => _$createPostDtoIdentityModeEnumValues;
  static CreatePostDtoIdentityModeEnum valueOf(String name) => _$createPostDtoIdentityModeEnumValueOf(name);
}
