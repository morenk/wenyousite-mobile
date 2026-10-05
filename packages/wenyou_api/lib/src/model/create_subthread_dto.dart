//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_subthread_dto.g.dart';

/// CreateSubthreadDto
///
/// Properties:
/// * [markdownContractVersion] - 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
/// * [identityId] - 本次新发言选择的帖内身份 ID；新客户端 RP 模式必须与该身份 token 一起发送。省略仅兼容旧单身份客户端；ACCOUNT 忽略，编辑旧正文不改变原身份
/// * [identityToken] - GET 帖内身份返回的确认 token；新建正文或发言时使用。身份变化返回 409/40011，保留草稿并重新确认
/// * [identityMode] - 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
/// * [clientRequestId] - 客户端创建幂等键；同一次提交和网络重试必须复用
/// * [title] - 子贴标题
/// * [content] - 子贴正文（kind=BODY，可选，留空仅创建空子贴）
/// * [sortOrder] - 排序序号，越小越靠前
/// * [postingPolicy] - PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅被标记为玩家的参与人可发帖
@BuiltValue()
abstract class CreateSubthreadDto implements Built<CreateSubthreadDto, CreateSubthreadDtoBuilder> {
  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueField(wireName: r'markdownContractVersion')
  CreateSubthreadDtoMarkdownContractVersionEnum? get markdownContractVersion;
  // enum markdownContractVersionEnum {  6,  };

  /// 本次新发言选择的帖内身份 ID；新客户端 RP 模式必须与该身份 token 一起发送。省略仅兼容旧单身份客户端；ACCOUNT 忽略，编辑旧正文不改变原身份
  @BuiltValueField(wireName: r'identityId')
  String? get identityId;

  /// GET 帖内身份返回的确认 token；新建正文或发言时使用。身份变化返回 409/40011，保留草稿并重新确认
  @BuiltValueField(wireName: r'identityToken')
  String? get identityToken;

  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueField(wireName: r'identityMode')
  CreateSubthreadDtoIdentityModeEnum? get identityMode;
  // enum identityModeEnum {  ACCOUNT,  RP,  };

  /// 客户端创建幂等键；同一次提交和网络重试必须复用
  @BuiltValueField(wireName: r'clientRequestId')
  String? get clientRequestId;

  /// 子贴标题
  @BuiltValueField(wireName: r'title')
  String get title;

  /// 子贴正文（kind=BODY，可选，留空仅创建空子贴）
  @BuiltValueField(wireName: r'content')
  String? get content;

  /// 排序序号，越小越靠前
  @BuiltValueField(wireName: r'sortOrder')
  num? get sortOrder;

  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅被标记为玩家的参与人可发帖
  @BuiltValueField(wireName: r'postingPolicy')
  CreateSubthreadDtoPostingPolicyEnum? get postingPolicy;
  // enum postingPolicyEnum {  PARTICIPANTS,  COLLABORATORS,  PLAYERS,  };

  CreateSubthreadDto._();

  factory CreateSubthreadDto([void updates(CreateSubthreadDtoBuilder b)]) = _$CreateSubthreadDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateSubthreadDtoBuilder b) => b
      ..postingPolicy = CreateSubthreadDtoPostingPolicyEnum.valueOf('PARTICIPANTS');

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateSubthreadDto> get serializer => _$CreateSubthreadDtoSerializer();
}

class _$CreateSubthreadDtoSerializer implements PrimitiveSerializer<CreateSubthreadDto> {
  @override
  final Iterable<Type> types = const [CreateSubthreadDto, _$CreateSubthreadDto];

  @override
  final String wireName = r'CreateSubthreadDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateSubthreadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.markdownContractVersion != null) {
      yield r'markdownContractVersion';
      yield serializers.serialize(
        object.markdownContractVersion,
        specifiedType: const FullType(CreateSubthreadDtoMarkdownContractVersionEnum),
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
        specifiedType: const FullType(CreateSubthreadDtoIdentityModeEnum),
      );
    }
    if (object.clientRequestId != null) {
      yield r'clientRequestId';
      yield serializers.serialize(
        object.clientRequestId,
        specifiedType: const FullType(String),
      );
    }
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
    if (object.sortOrder != null) {
      yield r'sortOrder';
      yield serializers.serialize(
        object.sortOrder,
        specifiedType: const FullType(num),
      );
    }
    if (object.postingPolicy != null) {
      yield r'postingPolicy';
      yield serializers.serialize(
        object.postingPolicy,
        specifiedType: const FullType(CreateSubthreadDtoPostingPolicyEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateSubthreadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateSubthreadDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'markdownContractVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateSubthreadDtoMarkdownContractVersionEnum),
          ) as CreateSubthreadDtoMarkdownContractVersionEnum;
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
            specifiedType: const FullType(CreateSubthreadDtoIdentityModeEnum),
          ) as CreateSubthreadDtoIdentityModeEnum;
          result.identityMode = valueDes;
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
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'sortOrder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.sortOrder = valueDes;
          break;
        case r'postingPolicy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateSubthreadDtoPostingPolicyEnum),
          ) as CreateSubthreadDtoPostingPolicyEnum;
          result.postingPolicy = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateSubthreadDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateSubthreadDtoBuilder();
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

class CreateSubthreadDtoMarkdownContractVersionEnum extends EnumClass {

  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueEnumConst(wireName: r'6')
  static const CreateSubthreadDtoMarkdownContractVersionEnum n6 = _$createSubthreadDtoMarkdownContractVersionEnum_n6;
  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const CreateSubthreadDtoMarkdownContractVersionEnum unknownDefaultOpenApi = _$createSubthreadDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;

  static Serializer<CreateSubthreadDtoMarkdownContractVersionEnum> get serializer => _$createSubthreadDtoMarkdownContractVersionEnumSerializer;

  const CreateSubthreadDtoMarkdownContractVersionEnum._(String name): super(name);

  static BuiltSet<CreateSubthreadDtoMarkdownContractVersionEnum> get values => _$createSubthreadDtoMarkdownContractVersionEnumValues;
  static CreateSubthreadDtoMarkdownContractVersionEnum valueOf(String name) => _$createSubthreadDtoMarkdownContractVersionEnumValueOf(name);
}

class CreateSubthreadDtoIdentityModeEnum extends EnumClass {

  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueEnumConst(wireName: r'ACCOUNT')
  static const CreateSubthreadDtoIdentityModeEnum ACCOUNT = _$createSubthreadDtoIdentityModeEnum_ACCOUNT;
  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueEnumConst(wireName: r'RP')
  static const CreateSubthreadDtoIdentityModeEnum RP = _$createSubthreadDtoIdentityModeEnum_RP;
  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CreateSubthreadDtoIdentityModeEnum unknownDefaultOpenApi = _$createSubthreadDtoIdentityModeEnum_unknownDefaultOpenApi;

  static Serializer<CreateSubthreadDtoIdentityModeEnum> get serializer => _$createSubthreadDtoIdentityModeEnumSerializer;

  const CreateSubthreadDtoIdentityModeEnum._(String name): super(name);

  static BuiltSet<CreateSubthreadDtoIdentityModeEnum> get values => _$createSubthreadDtoIdentityModeEnumValues;
  static CreateSubthreadDtoIdentityModeEnum valueOf(String name) => _$createSubthreadDtoIdentityModeEnumValueOf(name);
}

class CreateSubthreadDtoPostingPolicyEnum extends EnumClass {

  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅被标记为玩家的参与人可发帖
  @BuiltValueEnumConst(wireName: r'PARTICIPANTS')
  static const CreateSubthreadDtoPostingPolicyEnum PARTICIPANTS = _$createSubthreadDtoPostingPolicyEnum_PARTICIPANTS;
  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅被标记为玩家的参与人可发帖
  @BuiltValueEnumConst(wireName: r'COLLABORATORS')
  static const CreateSubthreadDtoPostingPolicyEnum COLLABORATORS = _$createSubthreadDtoPostingPolicyEnum_COLLABORATORS;
  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅被标记为玩家的参与人可发帖
  @BuiltValueEnumConst(wireName: r'PLAYERS')
  static const CreateSubthreadDtoPostingPolicyEnum PLAYERS = _$createSubthreadDtoPostingPolicyEnum_PLAYERS;
  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅被标记为玩家的参与人可发帖
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CreateSubthreadDtoPostingPolicyEnum unknownDefaultOpenApi = _$createSubthreadDtoPostingPolicyEnum_unknownDefaultOpenApi;

  static Serializer<CreateSubthreadDtoPostingPolicyEnum> get serializer => _$createSubthreadDtoPostingPolicyEnumSerializer;

  const CreateSubthreadDtoPostingPolicyEnum._(String name): super(name);

  static BuiltSet<CreateSubthreadDtoPostingPolicyEnum> get values => _$createSubthreadDtoPostingPolicyEnumValues;
  static CreateSubthreadDtoPostingPolicyEnum valueOf(String name) => _$createSubthreadDtoPostingPolicyEnumValueOf(name);
}
