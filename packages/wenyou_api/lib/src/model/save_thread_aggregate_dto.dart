//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'save_thread_aggregate_dto.g.dart';

/// SaveThreadAggregateDto
///
/// Properties:
/// * [markdownContractVersion] - 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
/// * [identityId] - 本次新发言选择的帖内身份 ID；新客户端 RP 模式必须与该身份 token 一起发送。省略仅兼容旧单身份客户端；ACCOUNT 忽略，编辑旧正文不改变原身份
/// * [identityToken] - GET 帖内身份返回的确认 token；新建正文或发言时使用。身份变化返回 409/40011，保留草稿并重新确认
/// * [identityMode] - 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
/// * [title]
/// * [category] - 管理员配置的分类 slug；服务端会去除首尾空白并转为大写
/// * [status]
/// * [visibility]
/// * [published] - 仅允许从草稿发布，不允许撤回
/// * [version] - 主题帖乐观锁版本
/// * [defaultSubthreadVersion] - 默认子贴乐观锁版本
/// * [defaultSubthreadPostingPolicy] - 主贴发言权限；省略保留原值。仅影响默认子贴楼层与回复，不修改其他子贴
/// * [bodyVersion] - 已有默认正文的乐观锁版本
/// * [content] - 默认子贴 Markdown 正文
/// * [tagNames]
@BuiltValue()
abstract class SaveThreadAggregateDto implements Built<SaveThreadAggregateDto, SaveThreadAggregateDtoBuilder> {
  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueField(wireName: r'markdownContractVersion')
  SaveThreadAggregateDtoMarkdownContractVersionEnum? get markdownContractVersion;
  // enum markdownContractVersionEnum {  6,  };

  /// 本次新发言选择的帖内身份 ID；新客户端 RP 模式必须与该身份 token 一起发送。省略仅兼容旧单身份客户端；ACCOUNT 忽略，编辑旧正文不改变原身份
  @BuiltValueField(wireName: r'identityId')
  String? get identityId;

  /// GET 帖内身份返回的确认 token；新建正文或发言时使用。身份变化返回 409/40011，保留草稿并重新确认
  @BuiltValueField(wireName: r'identityToken')
  String? get identityToken;

  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueField(wireName: r'identityMode')
  SaveThreadAggregateDtoIdentityModeEnum? get identityMode;
  // enum identityModeEnum {  ACCOUNT,  RP,  };

  @BuiltValueField(wireName: r'title')
  String? get title;

  /// 管理员配置的分类 slug；服务端会去除首尾空白并转为大写
  @BuiltValueField(wireName: r'category')
  String? get category;

  @BuiltValueField(wireName: r'status')
  SaveThreadAggregateDtoStatusEnum? get status;
  // enum statusEnum {  RECRUITING,  CLOSED,  FINISHED,  };

  @BuiltValueField(wireName: r'visibility')
  SaveThreadAggregateDtoVisibilityEnum? get visibility;
  // enum visibilityEnum {  PUBLIC,  PRIVATE,  };

  /// 仅允许从草稿发布，不允许撤回
  @BuiltValueField(wireName: r'published')
  bool? get published;

  /// 主题帖乐观锁版本
  @BuiltValueField(wireName: r'version')
  num get version;

  /// 默认子贴乐观锁版本
  @BuiltValueField(wireName: r'defaultSubthreadVersion')
  num get defaultSubthreadVersion;

  /// 主贴发言权限；省略保留原值。仅影响默认子贴楼层与回复，不修改其他子贴
  @BuiltValueField(wireName: r'defaultSubthreadPostingPolicy')
  SaveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum? get defaultSubthreadPostingPolicy;
  // enum defaultSubthreadPostingPolicyEnum {  PARTICIPANTS,  COLLABORATORS,  PLAYERS,  };

  /// 已有默认正文的乐观锁版本
  @BuiltValueField(wireName: r'bodyVersion')
  num? get bodyVersion;

  /// 默认子贴 Markdown 正文
  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'tagNames')
  BuiltList<String> get tagNames;

  SaveThreadAggregateDto._();

  factory SaveThreadAggregateDto([void updates(SaveThreadAggregateDtoBuilder b)]) = _$SaveThreadAggregateDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SaveThreadAggregateDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SaveThreadAggregateDto> get serializer => _$SaveThreadAggregateDtoSerializer();
}

class _$SaveThreadAggregateDtoSerializer implements PrimitiveSerializer<SaveThreadAggregateDto> {
  @override
  final Iterable<Type> types = const [SaveThreadAggregateDto, _$SaveThreadAggregateDto];

  @override
  final String wireName = r'SaveThreadAggregateDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SaveThreadAggregateDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.markdownContractVersion != null) {
      yield r'markdownContractVersion';
      yield serializers.serialize(
        object.markdownContractVersion,
        specifiedType: const FullType(SaveThreadAggregateDtoMarkdownContractVersionEnum),
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
        specifiedType: const FullType(SaveThreadAggregateDtoIdentityModeEnum),
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
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(SaveThreadAggregateDtoStatusEnum),
      );
    }
    if (object.visibility != null) {
      yield r'visibility';
      yield serializers.serialize(
        object.visibility,
        specifiedType: const FullType(SaveThreadAggregateDtoVisibilityEnum),
      );
    }
    if (object.published != null) {
      yield r'published';
      yield serializers.serialize(
        object.published,
        specifiedType: const FullType(bool),
      );
    }
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
    yield r'defaultSubthreadVersion';
    yield serializers.serialize(
      object.defaultSubthreadVersion,
      specifiedType: const FullType(num),
    );
    if (object.defaultSubthreadPostingPolicy != null) {
      yield r'defaultSubthreadPostingPolicy';
      yield serializers.serialize(
        object.defaultSubthreadPostingPolicy,
        specifiedType: const FullType(SaveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum),
      );
    }
    if (object.bodyVersion != null) {
      yield r'bodyVersion';
      yield serializers.serialize(
        object.bodyVersion,
        specifiedType: const FullType(num),
      );
    }
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'tagNames';
    yield serializers.serialize(
      object.tagNames,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SaveThreadAggregateDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SaveThreadAggregateDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'markdownContractVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SaveThreadAggregateDtoMarkdownContractVersionEnum),
          ) as SaveThreadAggregateDtoMarkdownContractVersionEnum;
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
            specifiedType: const FullType(SaveThreadAggregateDtoIdentityModeEnum),
          ) as SaveThreadAggregateDtoIdentityModeEnum;
          result.identityMode = valueDes;
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SaveThreadAggregateDtoStatusEnum),
          ) as SaveThreadAggregateDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'visibility':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SaveThreadAggregateDtoVisibilityEnum),
          ) as SaveThreadAggregateDtoVisibilityEnum;
          result.visibility = valueDes;
          break;
        case r'published':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.published = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        case r'defaultSubthreadVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.defaultSubthreadVersion = valueDes;
          break;
        case r'defaultSubthreadPostingPolicy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SaveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum),
          ) as SaveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum;
          result.defaultSubthreadPostingPolicy = valueDes;
          break;
        case r'bodyVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.bodyVersion = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'tagNames':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.tagNames.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SaveThreadAggregateDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SaveThreadAggregateDtoBuilder();
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

class SaveThreadAggregateDtoMarkdownContractVersionEnum extends EnumClass {

  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueEnumConst(wireName: r'6')
  static const SaveThreadAggregateDtoMarkdownContractVersionEnum n6 = _$saveThreadAggregateDtoMarkdownContractVersionEnum_n6;
  /// 声明编辑器支持 Markdown 6 角色提及源的无损读取/编辑。服务端 capabilities.roleMentionsV6Supported 为 true 时新端始终发送，包括删光旧节点；未声明而新/原正文含 v6 返回 409/40014。新节点还须 roleMentionsV6WriteEnabled。
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const SaveThreadAggregateDtoMarkdownContractVersionEnum unknownDefaultOpenApi = _$saveThreadAggregateDtoMarkdownContractVersionEnum_unknownDefaultOpenApi;

  static Serializer<SaveThreadAggregateDtoMarkdownContractVersionEnum> get serializer => _$saveThreadAggregateDtoMarkdownContractVersionEnumSerializer;

  const SaveThreadAggregateDtoMarkdownContractVersionEnum._(String name): super(name);

  static BuiltSet<SaveThreadAggregateDtoMarkdownContractVersionEnum> get values => _$saveThreadAggregateDtoMarkdownContractVersionEnumValues;
  static SaveThreadAggregateDtoMarkdownContractVersionEnum valueOf(String name) => _$saveThreadAggregateDtoMarkdownContractVersionEnumValueOf(name);
}

class SaveThreadAggregateDtoIdentityModeEnum extends EnumClass {

  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueEnumConst(wireName: r'ACCOUNT')
  static const SaveThreadAggregateDtoIdentityModeEnum ACCOUNT = _$saveThreadAggregateDtoIdentityModeEnum_ACCOUNT;
  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueEnumConst(wireName: r'RP')
  static const SaveThreadAggregateDtoIdentityModeEnum RP = _$saveThreadAggregateDtoIdentityModeEnum_RP;
  /// 本次新发言身份；ACCOUNT 明确使用站内账号且不校验 RP token，RP 要求有效帖内身份和 identityToken。省略沿用旧确认规则；编辑已有正文忽略此字段
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const SaveThreadAggregateDtoIdentityModeEnum unknownDefaultOpenApi = _$saveThreadAggregateDtoIdentityModeEnum_unknownDefaultOpenApi;

  static Serializer<SaveThreadAggregateDtoIdentityModeEnum> get serializer => _$saveThreadAggregateDtoIdentityModeEnumSerializer;

  const SaveThreadAggregateDtoIdentityModeEnum._(String name): super(name);

  static BuiltSet<SaveThreadAggregateDtoIdentityModeEnum> get values => _$saveThreadAggregateDtoIdentityModeEnumValues;
  static SaveThreadAggregateDtoIdentityModeEnum valueOf(String name) => _$saveThreadAggregateDtoIdentityModeEnumValueOf(name);
}

class SaveThreadAggregateDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'RECRUITING')
  static const SaveThreadAggregateDtoStatusEnum RECRUITING = _$saveThreadAggregateDtoStatusEnum_RECRUITING;
  @BuiltValueEnumConst(wireName: r'CLOSED')
  static const SaveThreadAggregateDtoStatusEnum CLOSED = _$saveThreadAggregateDtoStatusEnum_CLOSED;
  @BuiltValueEnumConst(wireName: r'FINISHED')
  static const SaveThreadAggregateDtoStatusEnum FINISHED = _$saveThreadAggregateDtoStatusEnum_FINISHED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const SaveThreadAggregateDtoStatusEnum unknownDefaultOpenApi = _$saveThreadAggregateDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<SaveThreadAggregateDtoStatusEnum> get serializer => _$saveThreadAggregateDtoStatusEnumSerializer;

  const SaveThreadAggregateDtoStatusEnum._(String name): super(name);

  static BuiltSet<SaveThreadAggregateDtoStatusEnum> get values => _$saveThreadAggregateDtoStatusEnumValues;
  static SaveThreadAggregateDtoStatusEnum valueOf(String name) => _$saveThreadAggregateDtoStatusEnumValueOf(name);
}

class SaveThreadAggregateDtoVisibilityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PUBLIC')
  static const SaveThreadAggregateDtoVisibilityEnum PUBLIC = _$saveThreadAggregateDtoVisibilityEnum_PUBLIC;
  @BuiltValueEnumConst(wireName: r'PRIVATE')
  static const SaveThreadAggregateDtoVisibilityEnum PRIVATE = _$saveThreadAggregateDtoVisibilityEnum_PRIVATE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const SaveThreadAggregateDtoVisibilityEnum unknownDefaultOpenApi = _$saveThreadAggregateDtoVisibilityEnum_unknownDefaultOpenApi;

  static Serializer<SaveThreadAggregateDtoVisibilityEnum> get serializer => _$saveThreadAggregateDtoVisibilityEnumSerializer;

  const SaveThreadAggregateDtoVisibilityEnum._(String name): super(name);

  static BuiltSet<SaveThreadAggregateDtoVisibilityEnum> get values => _$saveThreadAggregateDtoVisibilityEnumValues;
  static SaveThreadAggregateDtoVisibilityEnum valueOf(String name) => _$saveThreadAggregateDtoVisibilityEnumValueOf(name);
}

class SaveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum extends EnumClass {

  /// 主贴发言权限；省略保留原值。仅影响默认子贴楼层与回复，不修改其他子贴
  @BuiltValueEnumConst(wireName: r'PARTICIPANTS')
  static const SaveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum PARTICIPANTS = _$saveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum_PARTICIPANTS;
  /// 主贴发言权限；省略保留原值。仅影响默认子贴楼层与回复，不修改其他子贴
  @BuiltValueEnumConst(wireName: r'COLLABORATORS')
  static const SaveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum COLLABORATORS = _$saveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum_COLLABORATORS;
  /// 主贴发言权限；省略保留原值。仅影响默认子贴楼层与回复，不修改其他子贴
  @BuiltValueEnumConst(wireName: r'PLAYERS')
  static const SaveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum PLAYERS = _$saveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum_PLAYERS;
  /// 主贴发言权限；省略保留原值。仅影响默认子贴楼层与回复，不修改其他子贴
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const SaveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum unknownDefaultOpenApi = _$saveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum_unknownDefaultOpenApi;

  static Serializer<SaveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum> get serializer => _$saveThreadAggregateDtoDefaultSubthreadPostingPolicyEnumSerializer;

  const SaveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum._(String name): super(name);

  static BuiltSet<SaveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum> get values => _$saveThreadAggregateDtoDefaultSubthreadPostingPolicyEnumValues;
  static SaveThreadAggregateDtoDefaultSubthreadPostingPolicyEnum valueOf(String name) => _$saveThreadAggregateDtoDefaultSubthreadPostingPolicyEnumValueOf(name);
}
