//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/thread_identity_account_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/rp_identity_state_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rp_identity_collection_dto.g.dart';

/// RpIdentityCollectionDto
///
/// Properties:
/// * [threadId]
/// * [userId]
/// * [enabled]
/// * [eligible]
/// * [canEdit]
/// * [activeCount] - 未删除身份数；清空资料仍占一个名额，删除释放名额
/// * [limit]
/// * [compatibilityIdentityId] - 旧 single 接口的明确锚点；首次角色绑定，删除后不自动接管
/// * [defaultIdentityId] - 固定 null；新空白编辑器默认 ACCOUNT，不覆盖恢复的显式草稿
/// * [identities]
/// * [account]
@BuiltValue()
abstract class RpIdentityCollectionDto implements Built<RpIdentityCollectionDto, RpIdentityCollectionDtoBuilder> {
  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'eligible')
  bool get eligible;

  @BuiltValueField(wireName: r'canEdit')
  bool get canEdit;

  /// 未删除身份数；清空资料仍占一个名额，删除释放名额
  @BuiltValueField(wireName: r'activeCount')
  num get activeCount;

  @BuiltValueField(wireName: r'limit')
  RpIdentityCollectionDtoLimitEnum get limit;
  // enum limitEnum {  10,  };

  /// 旧 single 接口的明确锚点；首次角色绑定，删除后不自动接管
  @BuiltValueField(wireName: r'compatibilityIdentityId')
  String? get compatibilityIdentityId;

  /// 固定 null；新空白编辑器默认 ACCOUNT，不覆盖恢复的显式草稿
  @BuiltValueField(wireName: r'defaultIdentityId')
  String? get defaultIdentityId;

  @BuiltValueField(wireName: r'identities')
  BuiltList<RpIdentityStateDto> get identities;

  @BuiltValueField(wireName: r'account')
  ThreadIdentityAccountDto get account;

  RpIdentityCollectionDto._();

  factory RpIdentityCollectionDto([void updates(RpIdentityCollectionDtoBuilder b)]) = _$RpIdentityCollectionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RpIdentityCollectionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RpIdentityCollectionDto> get serializer => _$RpIdentityCollectionDtoSerializer();
}

class _$RpIdentityCollectionDtoSerializer implements PrimitiveSerializer<RpIdentityCollectionDto> {
  @override
  final Iterable<Type> types = const [RpIdentityCollectionDto, _$RpIdentityCollectionDto];

  @override
  final String wireName = r'RpIdentityCollectionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RpIdentityCollectionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'activeCount';
    yield serializers.serialize(
      object.activeCount,
      specifiedType: const FullType(num),
    );
    yield r'limit';
    yield serializers.serialize(
      object.limit,
      specifiedType: const FullType(RpIdentityCollectionDtoLimitEnum),
    );
    yield r'compatibilityIdentityId';
    yield object.compatibilityIdentityId == null ? null : serializers.serialize(
      object.compatibilityIdentityId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'defaultIdentityId';
    yield object.defaultIdentityId == null ? null : serializers.serialize(
      object.defaultIdentityId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'identities';
    yield serializers.serialize(
      object.identities,
      specifiedType: const FullType(BuiltList, [FullType(RpIdentityStateDto)]),
    );
    yield r'account';
    yield serializers.serialize(
      object.account,
      specifiedType: const FullType(ThreadIdentityAccountDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RpIdentityCollectionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RpIdentityCollectionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'activeCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.activeCount = valueDes;
          break;
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RpIdentityCollectionDtoLimitEnum),
          ) as RpIdentityCollectionDtoLimitEnum;
          result.limit = valueDes;
          break;
        case r'compatibilityIdentityId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.compatibilityIdentityId = valueDes;
          break;
        case r'defaultIdentityId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.defaultIdentityId = valueDes;
          break;
        case r'identities':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RpIdentityStateDto)]),
          ) as BuiltList<RpIdentityStateDto>;
          result.identities.replace(valueDes);
          break;
        case r'account':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadIdentityAccountDto),
          ) as ThreadIdentityAccountDto;
          result.account.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RpIdentityCollectionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RpIdentityCollectionDtoBuilder();
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

class RpIdentityCollectionDtoLimitEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'10')
  static const RpIdentityCollectionDtoLimitEnum n10 = _$rpIdentityCollectionDtoLimitEnum_n10;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const RpIdentityCollectionDtoLimitEnum unknownDefaultOpenApi = _$rpIdentityCollectionDtoLimitEnum_unknownDefaultOpenApi;

  static Serializer<RpIdentityCollectionDtoLimitEnum> get serializer => _$rpIdentityCollectionDtoLimitEnumSerializer;

  const RpIdentityCollectionDtoLimitEnum._(String name): super(name);

  static BuiltSet<RpIdentityCollectionDtoLimitEnum> get values => _$rpIdentityCollectionDtoLimitEnumValues;
  static RpIdentityCollectionDtoLimitEnum valueOf(String name) => _$rpIdentityCollectionDtoLimitEnumValueOf(name);
}
