//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_job_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_management_item_dto.g.dart';

/// FontManagementItemDto
///
/// Properties:
/// * [familyId]
/// * [name]
/// * [language]
/// * [sortOrder]
/// * [revision]
/// * [enabled]
/// * [status] - 最后当前版本已撤回优先；从未发布为 draft，否则按家族 enabled 分类。
/// * [currentVersionId]
/// * [lastPublishedVersionId] - 最后被设为当前的已发布版本，含撤回墓碑；不是按版本号猜测。
/// * [createdAt]
/// * [updatedAt] - 家族修改时间；心跳和仅任务进度变化不作为排序修改。
/// * [publishedAt]
/// * [withdrawnAt]
/// * [latestJob]
/// * [latestSubmissionId]
@BuiltValue()
abstract class FontManagementItemDto implements Built<FontManagementItemDto, FontManagementItemDtoBuilder> {
  @BuiltValueField(wireName: r'familyId')
  String get familyId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'language')
  FontManagementItemDtoLanguageEnum get language;
  // enum languageEnum {  zh,  ja,  en,  other,  };

  @BuiltValueField(wireName: r'sortOrder')
  int get sortOrder;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  /// 最后当前版本已撤回优先；从未发布为 draft，否则按家族 enabled 分类。
  @BuiltValueField(wireName: r'status')
  FontManagementItemDtoStatusEnum get status;
  // enum statusEnum {  draft,  enabled,  disabled,  withdrawn,  };

  @BuiltValueField(wireName: r'currentVersionId')
  String? get currentVersionId;

  /// 最后被设为当前的已发布版本，含撤回墓碑；不是按版本号猜测。
  @BuiltValueField(wireName: r'lastPublishedVersionId')
  String? get lastPublishedVersionId;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  /// 家族修改时间；心跳和仅任务进度变化不作为排序修改。
  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'publishedAt')
  DateTime? get publishedAt;

  @BuiltValueField(wireName: r'withdrawnAt')
  DateTime? get withdrawnAt;

  @BuiltValueField(wireName: r'latestJob')
  FontJobDto? get latestJob;

  @BuiltValueField(wireName: r'latestSubmissionId')
  String? get latestSubmissionId;

  FontManagementItemDto._();

  factory FontManagementItemDto([void updates(FontManagementItemDtoBuilder b)]) = _$FontManagementItemDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontManagementItemDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontManagementItemDto> get serializer => _$FontManagementItemDtoSerializer();
}

class _$FontManagementItemDtoSerializer implements PrimitiveSerializer<FontManagementItemDto> {
  @override
  final Iterable<Type> types = const [FontManagementItemDto, _$FontManagementItemDto];

  @override
  final String wireName = r'FontManagementItemDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontManagementItemDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'familyId';
    yield serializers.serialize(
      object.familyId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'language';
    yield serializers.serialize(
      object.language,
      specifiedType: const FullType(FontManagementItemDtoLanguageEnum),
    );
    yield r'sortOrder';
    yield serializers.serialize(
      object.sortOrder,
      specifiedType: const FullType(int),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(FontManagementItemDtoStatusEnum),
    );
    yield r'currentVersionId';
    yield object.currentVersionId == null ? null : serializers.serialize(
      object.currentVersionId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'lastPublishedVersionId';
    yield object.lastPublishedVersionId == null ? null : serializers.serialize(
      object.lastPublishedVersionId,
      specifiedType: const FullType.nullable(String),
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
    yield r'publishedAt';
    yield object.publishedAt == null ? null : serializers.serialize(
      object.publishedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'withdrawnAt';
    yield object.withdrawnAt == null ? null : serializers.serialize(
      object.withdrawnAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'latestJob';
    yield object.latestJob == null ? null : serializers.serialize(
      object.latestJob,
      specifiedType: const FullType.nullable(FontJobDto),
    );
    yield r'latestSubmissionId';
    yield object.latestSubmissionId == null ? null : serializers.serialize(
      object.latestSubmissionId,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontManagementItemDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontManagementItemDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'familyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.familyId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'language':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontManagementItemDtoLanguageEnum),
          ) as FontManagementItemDtoLanguageEnum;
          result.language = valueDes;
          break;
        case r'sortOrder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sortOrder = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontManagementItemDtoStatusEnum),
          ) as FontManagementItemDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'currentVersionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.currentVersionId = valueDes;
          break;
        case r'lastPublishedVersionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lastPublishedVersionId = valueDes;
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
        case r'publishedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.publishedAt = valueDes;
          break;
        case r'withdrawnAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.withdrawnAt = valueDes;
          break;
        case r'latestJob':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(FontJobDto),
          ) as FontJobDto?;
          if (valueDes == null) continue;
          result.latestJob.replace(valueDes);
          break;
        case r'latestSubmissionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.latestSubmissionId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontManagementItemDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontManagementItemDtoBuilder();
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

class FontManagementItemDtoLanguageEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'zh')
  static const FontManagementItemDtoLanguageEnum zh = _$fontManagementItemDtoLanguageEnum_zh;
  @BuiltValueEnumConst(wireName: r'ja')
  static const FontManagementItemDtoLanguageEnum ja = _$fontManagementItemDtoLanguageEnum_ja;
  @BuiltValueEnumConst(wireName: r'en')
  static const FontManagementItemDtoLanguageEnum en = _$fontManagementItemDtoLanguageEnum_en;
  @BuiltValueEnumConst(wireName: r'other')
  static const FontManagementItemDtoLanguageEnum other = _$fontManagementItemDtoLanguageEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontManagementItemDtoLanguageEnum unknownDefaultOpenApi = _$fontManagementItemDtoLanguageEnum_unknownDefaultOpenApi;

  static Serializer<FontManagementItemDtoLanguageEnum> get serializer => _$fontManagementItemDtoLanguageEnumSerializer;

  const FontManagementItemDtoLanguageEnum._(String name): super(name);

  static BuiltSet<FontManagementItemDtoLanguageEnum> get values => _$fontManagementItemDtoLanguageEnumValues;
  static FontManagementItemDtoLanguageEnum valueOf(String name) => _$fontManagementItemDtoLanguageEnumValueOf(name);
}

class FontManagementItemDtoStatusEnum extends EnumClass {

  /// 最后当前版本已撤回优先；从未发布为 draft，否则按家族 enabled 分类。
  @BuiltValueEnumConst(wireName: r'draft')
  static const FontManagementItemDtoStatusEnum draft = _$fontManagementItemDtoStatusEnum_draft;
  /// 最后当前版本已撤回优先；从未发布为 draft，否则按家族 enabled 分类。
  @BuiltValueEnumConst(wireName: r'enabled')
  static const FontManagementItemDtoStatusEnum enabled = _$fontManagementItemDtoStatusEnum_enabled;
  /// 最后当前版本已撤回优先；从未发布为 draft，否则按家族 enabled 分类。
  @BuiltValueEnumConst(wireName: r'disabled')
  static const FontManagementItemDtoStatusEnum disabled = _$fontManagementItemDtoStatusEnum_disabled;
  /// 最后当前版本已撤回优先；从未发布为 draft，否则按家族 enabled 分类。
  @BuiltValueEnumConst(wireName: r'withdrawn')
  static const FontManagementItemDtoStatusEnum withdrawn = _$fontManagementItemDtoStatusEnum_withdrawn;
  /// 最后当前版本已撤回优先；从未发布为 draft，否则按家族 enabled 分类。
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontManagementItemDtoStatusEnum unknownDefaultOpenApi = _$fontManagementItemDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<FontManagementItemDtoStatusEnum> get serializer => _$fontManagementItemDtoStatusEnumSerializer;

  const FontManagementItemDtoStatusEnum._(String name): super(name);

  static BuiltSet<FontManagementItemDtoStatusEnum> get values => _$fontManagementItemDtoStatusEnumValues;
  static FontManagementItemDtoStatusEnum valueOf(String name) => _$fontManagementItemDtoStatusEnumValueOf(name);
}
