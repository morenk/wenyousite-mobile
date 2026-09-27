//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/public_mobile_release_dto.dart';
import 'package:wenyou_api/src/model/mobile_release_snapshot_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_mobile_release_dto.g.dart';

/// AdminMobileReleaseDto
///
/// Properties:
/// * [platform]
/// * [versionName]
/// * [buildNumber]
/// * [id]
/// * [summary]
/// * [items]
/// * [revision]
/// * [status] - 已发布记录即使有待确认修正仍为 PUBLISHED；hasUnconfirmedChanges 表示草稿与确认快照不同
/// * [hasUnconfirmedChanges]
/// * [publishing]
/// * [confirmed]
/// * [published]
/// * [createdAt]
/// * [updatedAt]
@BuiltValue()
abstract class AdminMobileReleaseDto implements Built<AdminMobileReleaseDto, AdminMobileReleaseDtoBuilder> {
  @BuiltValueField(wireName: r'platform')
  AdminMobileReleaseDtoPlatformEnum get platform;
  // enum platformEnum {  android,  };

  @BuiltValueField(wireName: r'versionName')
  String get versionName;

  @BuiltValueField(wireName: r'buildNumber')
  num get buildNumber;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'summary')
  String get summary;

  @BuiltValueField(wireName: r'items')
  BuiltList<String> get items;

  @BuiltValueField(wireName: r'revision')
  num get revision;

  /// 已发布记录即使有待确认修正仍为 PUBLISHED；hasUnconfirmedChanges 表示草稿与确认快照不同
  @BuiltValueField(wireName: r'status')
  AdminMobileReleaseDtoStatusEnum get status;
  // enum statusEnum {  DRAFT,  READY,  PUBLISHED,  };

  @BuiltValueField(wireName: r'hasUnconfirmedChanges')
  bool get hasUnconfirmedChanges;

  @BuiltValueField(wireName: r'publishing')
  bool get publishing;

  @BuiltValueField(wireName: r'confirmed')
  MobileReleaseSnapshotDto? get confirmed;

  @BuiltValueField(wireName: r'published')
  PublicMobileReleaseDto? get published;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  AdminMobileReleaseDto._();

  factory AdminMobileReleaseDto([void updates(AdminMobileReleaseDtoBuilder b)]) = _$AdminMobileReleaseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminMobileReleaseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminMobileReleaseDto> get serializer => _$AdminMobileReleaseDtoSerializer();
}

class _$AdminMobileReleaseDtoSerializer implements PrimitiveSerializer<AdminMobileReleaseDto> {
  @override
  final Iterable<Type> types = const [AdminMobileReleaseDto, _$AdminMobileReleaseDto];

  @override
  final String wireName = r'AdminMobileReleaseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminMobileReleaseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(AdminMobileReleaseDtoPlatformEnum),
    );
    yield r'versionName';
    yield serializers.serialize(
      object.versionName,
      specifiedType: const FullType(String),
    );
    yield r'buildNumber';
    yield serializers.serialize(
      object.buildNumber,
      specifiedType: const FullType(num),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'summary';
    yield serializers.serialize(
      object.summary,
      specifiedType: const FullType(String),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(num),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AdminMobileReleaseDtoStatusEnum),
    );
    yield r'hasUnconfirmedChanges';
    yield serializers.serialize(
      object.hasUnconfirmedChanges,
      specifiedType: const FullType(bool),
    );
    yield r'publishing';
    yield serializers.serialize(
      object.publishing,
      specifiedType: const FullType(bool),
    );
    yield r'confirmed';
    yield object.confirmed == null ? null : serializers.serialize(
      object.confirmed,
      specifiedType: const FullType.nullable(MobileReleaseSnapshotDto),
    );
    yield r'published';
    yield object.published == null ? null : serializers.serialize(
      object.published,
      specifiedType: const FullType.nullable(PublicMobileReleaseDto),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminMobileReleaseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminMobileReleaseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminMobileReleaseDtoPlatformEnum),
          ) as AdminMobileReleaseDtoPlatformEnum;
          result.platform = valueDes;
          break;
        case r'versionName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.versionName = valueDes;
          break;
        case r'buildNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.buildNumber = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.summary = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.items.replace(valueDes);
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.revision = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminMobileReleaseDtoStatusEnum),
          ) as AdminMobileReleaseDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'hasUnconfirmedChanges':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasUnconfirmedChanges = valueDes;
          break;
        case r'publishing':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.publishing = valueDes;
          break;
        case r'confirmed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MobileReleaseSnapshotDto),
          ) as MobileReleaseSnapshotDto?;
          if (valueDes == null) continue;
          result.confirmed.replace(valueDes);
          break;
        case r'published':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PublicMobileReleaseDto),
          ) as PublicMobileReleaseDto?;
          if (valueDes == null) continue;
          result.published.replace(valueDes);
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminMobileReleaseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminMobileReleaseDtoBuilder();
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

class AdminMobileReleaseDtoPlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'android')
  static const AdminMobileReleaseDtoPlatformEnum android = _$adminMobileReleaseDtoPlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminMobileReleaseDtoPlatformEnum unknownDefaultOpenApi = _$adminMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi;

  static Serializer<AdminMobileReleaseDtoPlatformEnum> get serializer => _$adminMobileReleaseDtoPlatformEnumSerializer;

  const AdminMobileReleaseDtoPlatformEnum._(String name): super(name);

  static BuiltSet<AdminMobileReleaseDtoPlatformEnum> get values => _$adminMobileReleaseDtoPlatformEnumValues;
  static AdminMobileReleaseDtoPlatformEnum valueOf(String name) => _$adminMobileReleaseDtoPlatformEnumValueOf(name);
}

class AdminMobileReleaseDtoStatusEnum extends EnumClass {

  /// 已发布记录即使有待确认修正仍为 PUBLISHED；hasUnconfirmedChanges 表示草稿与确认快照不同
  @BuiltValueEnumConst(wireName: r'DRAFT')
  static const AdminMobileReleaseDtoStatusEnum DRAFT = _$adminMobileReleaseDtoStatusEnum_DRAFT;
  /// 已发布记录即使有待确认修正仍为 PUBLISHED；hasUnconfirmedChanges 表示草稿与确认快照不同
  @BuiltValueEnumConst(wireName: r'READY')
  static const AdminMobileReleaseDtoStatusEnum READY = _$adminMobileReleaseDtoStatusEnum_READY;
  /// 已发布记录即使有待确认修正仍为 PUBLISHED；hasUnconfirmedChanges 表示草稿与确认快照不同
  @BuiltValueEnumConst(wireName: r'PUBLISHED')
  static const AdminMobileReleaseDtoStatusEnum PUBLISHED = _$adminMobileReleaseDtoStatusEnum_PUBLISHED;
  /// 已发布记录即使有待确认修正仍为 PUBLISHED；hasUnconfirmedChanges 表示草稿与确认快照不同
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const AdminMobileReleaseDtoStatusEnum unknownDefaultOpenApi = _$adminMobileReleaseDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<AdminMobileReleaseDtoStatusEnum> get serializer => _$adminMobileReleaseDtoStatusEnumSerializer;

  const AdminMobileReleaseDtoStatusEnum._(String name): super(name);

  static BuiltSet<AdminMobileReleaseDtoStatusEnum> get values => _$adminMobileReleaseDtoStatusEnumValues;
  static AdminMobileReleaseDtoStatusEnum valueOf(String name) => _$adminMobileReleaseDtoStatusEnumValueOf(name);
}
