//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/rp_identity_response_dto.dart';
import 'package:wenyou_api/src/model/thread_identity_account_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_identity_profile_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rp_identity_state_dto.g.dart';

/// RpIdentityStateDto
///
/// Properties:
/// * [profilePostStatus] - NONE：无可展示绑定（含身份关闭/归档/资格失效/空身份）；AVAILABLE：可读取当前资料；UNAVAILABLE：有效角色的绑定当前不可读。不可用不提供原因或目标 ID
/// * [profilePostId] - 同一角色当前可读的资料楼层 ID；关闭、失去资格、空身份、归档、目标不可读时为 null。每次打开卡片重新读取，再调用 postsFindById，禁止缓存正文绕过授权
/// * [threadId]
/// * [userId]
/// * [enabled]
/// * [eligible] - 当前是否具有楼主、协作者或玩家资格；不代表发言权限
/// * [canEdit] - 当前访问者能否编辑此身份
/// * [identity]
/// * [display]
/// * [account]
/// * [identityToken] - 仅本人读取返回。新发言传 identityToken；409 后保留草稿并重新读取确认
/// * [canDelete] - 本人可删除未归档角色，关闭功能或撤资格后也可删除
/// * [identityId] - 稳定角色 ID，删除后不会复用
/// * [deleted] - 已删除角色仅保留历史展示与账号；当前 display 为 null
/// * [compatibilityIdentity] - 仅旧 single 协议内部锚点；不是新端的默认或候选优先级
@BuiltValue()
abstract class RpIdentityStateDto implements Built<RpIdentityStateDto, RpIdentityStateDtoBuilder> {
  /// NONE：无可展示绑定（含身份关闭/归档/资格失效/空身份）；AVAILABLE：可读取当前资料；UNAVAILABLE：有效角色的绑定当前不可读。不可用不提供原因或目标 ID
  @BuiltValueField(wireName: r'profilePostStatus')
  RpIdentityStateDtoProfilePostStatusEnum? get profilePostStatus;
  // enum profilePostStatusEnum {  NONE,  AVAILABLE,  UNAVAILABLE,  };

  /// 同一角色当前可读的资料楼层 ID；关闭、失去资格、空身份、归档、目标不可读时为 null。每次打开卡片重新读取，再调用 postsFindById，禁止缓存正文绕过授权
  @BuiltValueField(wireName: r'profilePostId')
  String? get profilePostId;

  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  /// 当前是否具有楼主、协作者或玩家资格；不代表发言权限
  @BuiltValueField(wireName: r'eligible')
  bool get eligible;

  /// 当前访问者能否编辑此身份
  @BuiltValueField(wireName: r'canEdit')
  bool get canEdit;

  @BuiltValueField(wireName: r'identity')
  ThreadIdentityProfileDto? get identity;

  @BuiltValueField(wireName: r'display')
  RpIdentityResponseDto? get display;

  @BuiltValueField(wireName: r'account')
  ThreadIdentityAccountDto get account;

  /// 仅本人读取返回。新发言传 identityToken；409 后保留草稿并重新读取确认
  @BuiltValueField(wireName: r'identityToken')
  String? get identityToken;

  /// 本人可删除未归档角色，关闭功能或撤资格后也可删除
  @BuiltValueField(wireName: r'canDelete')
  bool get canDelete;

  /// 稳定角色 ID，删除后不会复用
  @BuiltValueField(wireName: r'identityId')
  String get identityId;

  /// 已删除角色仅保留历史展示与账号；当前 display 为 null
  @BuiltValueField(wireName: r'deleted')
  bool get deleted;

  /// 仅旧 single 协议内部锚点；不是新端的默认或候选优先级
  @BuiltValueField(wireName: r'compatibilityIdentity')
  bool get compatibilityIdentity;

  RpIdentityStateDto._();

  factory RpIdentityStateDto([void updates(RpIdentityStateDtoBuilder b)]) = _$RpIdentityStateDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RpIdentityStateDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RpIdentityStateDto> get serializer => _$RpIdentityStateDtoSerializer();
}

class _$RpIdentityStateDtoSerializer implements PrimitiveSerializer<RpIdentityStateDto> {
  @override
  final Iterable<Type> types = const [RpIdentityStateDto, _$RpIdentityStateDto];

  @override
  final String wireName = r'RpIdentityStateDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RpIdentityStateDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.profilePostStatus != null) {
      yield r'profilePostStatus';
      yield serializers.serialize(
        object.profilePostStatus,
        specifiedType: const FullType(RpIdentityStateDtoProfilePostStatusEnum),
      );
    }
    if (object.profilePostId != null) {
      yield r'profilePostId';
      yield serializers.serialize(
        object.profilePostId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'threadId';
    yield serializers.serialize(
      object.threadId,
      specifiedType: const FullType(String),
    );
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    yield r'eligible';
    yield serializers.serialize(
      object.eligible,
      specifiedType: const FullType(bool),
    );
    yield r'canEdit';
    yield serializers.serialize(
      object.canEdit,
      specifiedType: const FullType(bool),
    );
    yield r'identity';
    yield object.identity == null ? null : serializers.serialize(
      object.identity,
      specifiedType: const FullType.nullable(ThreadIdentityProfileDto),
    );
    yield r'display';
    yield object.display == null ? null : serializers.serialize(
      object.display,
      specifiedType: const FullType.nullable(RpIdentityResponseDto),
    );
    yield r'account';
    yield serializers.serialize(
      object.account,
      specifiedType: const FullType(ThreadIdentityAccountDto),
    );
    yield r'identityToken';
    yield object.identityToken == null ? null : serializers.serialize(
      object.identityToken,
      specifiedType: const FullType.nullable(String),
    );
    yield r'canDelete';
    yield serializers.serialize(
      object.canDelete,
      specifiedType: const FullType(bool),
    );
    yield r'identityId';
    yield serializers.serialize(
      object.identityId,
      specifiedType: const FullType(String),
    );
    yield r'deleted';
    yield serializers.serialize(
      object.deleted,
      specifiedType: const FullType(bool),
    );
    yield r'compatibilityIdentity';
    yield serializers.serialize(
      object.compatibilityIdentity,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RpIdentityStateDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RpIdentityStateDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'profilePostStatus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RpIdentityStateDtoProfilePostStatusEnum),
          ) as RpIdentityStateDtoProfilePostStatusEnum;
          result.profilePostStatus = valueDes;
          break;
        case r'profilePostId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.profilePostId = valueDes;
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
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'eligible':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.eligible = valueDes;
          break;
        case r'canEdit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canEdit = valueDes;
          break;
        case r'identity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ThreadIdentityProfileDto),
          ) as ThreadIdentityProfileDto?;
          if (valueDes == null) continue;
          result.identity.replace(valueDes);
          break;
        case r'display':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RpIdentityResponseDto),
          ) as RpIdentityResponseDto?;
          if (valueDes == null) continue;
          result.display.replace(valueDes);
          break;
        case r'account':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadIdentityAccountDto),
          ) as ThreadIdentityAccountDto;
          result.account.replace(valueDes);
          break;
        case r'identityToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.identityToken = valueDes;
          break;
        case r'canDelete':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canDelete = valueDes;
          break;
        case r'identityId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.identityId = valueDes;
          break;
        case r'deleted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.deleted = valueDes;
          break;
        case r'compatibilityIdentity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.compatibilityIdentity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RpIdentityStateDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RpIdentityStateDtoBuilder();
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

class RpIdentityStateDtoProfilePostStatusEnum extends EnumClass {

  /// NONE：无可展示绑定（含身份关闭/归档/资格失效/空身份）；AVAILABLE：可读取当前资料；UNAVAILABLE：有效角色的绑定当前不可读。不可用不提供原因或目标 ID
  @BuiltValueEnumConst(wireName: r'NONE')
  static const RpIdentityStateDtoProfilePostStatusEnum NONE = _$rpIdentityStateDtoProfilePostStatusEnum_NONE;
  /// NONE：无可展示绑定（含身份关闭/归档/资格失效/空身份）；AVAILABLE：可读取当前资料；UNAVAILABLE：有效角色的绑定当前不可读。不可用不提供原因或目标 ID
  @BuiltValueEnumConst(wireName: r'AVAILABLE')
  static const RpIdentityStateDtoProfilePostStatusEnum AVAILABLE = _$rpIdentityStateDtoProfilePostStatusEnum_AVAILABLE;
  /// NONE：无可展示绑定（含身份关闭/归档/资格失效/空身份）；AVAILABLE：可读取当前资料；UNAVAILABLE：有效角色的绑定当前不可读。不可用不提供原因或目标 ID
  @BuiltValueEnumConst(wireName: r'UNAVAILABLE')
  static const RpIdentityStateDtoProfilePostStatusEnum UNAVAILABLE = _$rpIdentityStateDtoProfilePostStatusEnum_UNAVAILABLE;
  /// NONE：无可展示绑定（含身份关闭/归档/资格失效/空身份）；AVAILABLE：可读取当前资料；UNAVAILABLE：有效角色的绑定当前不可读。不可用不提供原因或目标 ID
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const RpIdentityStateDtoProfilePostStatusEnum unknownDefaultOpenApi = _$rpIdentityStateDtoProfilePostStatusEnum_unknownDefaultOpenApi;

  static Serializer<RpIdentityStateDtoProfilePostStatusEnum> get serializer => _$rpIdentityStateDtoProfilePostStatusEnumSerializer;

  const RpIdentityStateDtoProfilePostStatusEnum._(String name): super(name);

  static BuiltSet<RpIdentityStateDtoProfilePostStatusEnum> get values => _$rpIdentityStateDtoProfilePostStatusEnumValues;
  static RpIdentityStateDtoProfilePostStatusEnum valueOf(String name) => _$rpIdentityStateDtoProfilePostStatusEnumValueOf(name);
}
