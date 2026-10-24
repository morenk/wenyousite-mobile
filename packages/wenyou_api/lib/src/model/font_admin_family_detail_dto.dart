//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_rights_dto.dart';
import 'package:wenyou_api/src/model/font_job_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_admin_family_detail_dto.g.dart';

/// FontAdminFamilyDetailDto
///
/// Properties:
/// * [name]
/// * [designLanguage]
/// * [sortOrder]
/// * [author]
/// * [sourceUrl] - 出处链接，仅作授权凭据记录；后端从不抓取。
/// * [licenseName]
/// * [licenseText] - 完整授权材料；缺失或三项权利未全部确认时，只能保存草稿和上传源，不能启动处理或发布。
/// * [specimenText] - 展示于 PNG 的样张文字；不允许换行或控制字符。
/// * [rights]
/// * [familyId]
/// * [revision]
/// * [enabled]
/// * [currentVersionId]
/// * [catalogRevision]
/// * [jobs]
/// * [versionIds] - 含未发布和已撤回版本；通过管理预览描述符逐个读取。
@BuiltValue()
abstract class FontAdminFamilyDetailDto implements Built<FontAdminFamilyDetailDto, FontAdminFamilyDetailDtoBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'designLanguage')
  FontAdminFamilyDetailDtoDesignLanguageEnum get designLanguage;
  // enum designLanguageEnum {  zh,  ja,  en,  other,  };

  @BuiltValueField(wireName: r'sortOrder')
  int get sortOrder;

  @BuiltValueField(wireName: r'author')
  String get author;

  /// 出处链接，仅作授权凭据记录；后端从不抓取。
  @BuiltValueField(wireName: r'sourceUrl')
  String get sourceUrl;

  @BuiltValueField(wireName: r'licenseName')
  String get licenseName;

  /// 完整授权材料；缺失或三项权利未全部确认时，只能保存草稿和上传源，不能启动处理或发布。
  @BuiltValueField(wireName: r'licenseText')
  String get licenseText;

  /// 展示于 PNG 的样张文字；不允许换行或控制字符。
  @BuiltValueField(wireName: r'specimenText')
  String get specimenText;

  @BuiltValueField(wireName: r'rights')
  FontRightsDto get rights;

  @BuiltValueField(wireName: r'familyId')
  String get familyId;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'currentVersionId')
  String? get currentVersionId;

  @BuiltValueField(wireName: r'catalogRevision')
  int get catalogRevision;

  @BuiltValueField(wireName: r'jobs')
  BuiltList<FontJobDto> get jobs;

  /// 含未发布和已撤回版本；通过管理预览描述符逐个读取。
  @BuiltValueField(wireName: r'versionIds')
  BuiltList<String> get versionIds;

  FontAdminFamilyDetailDto._();

  factory FontAdminFamilyDetailDto([void updates(FontAdminFamilyDetailDtoBuilder b)]) = _$FontAdminFamilyDetailDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontAdminFamilyDetailDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontAdminFamilyDetailDto> get serializer => _$FontAdminFamilyDetailDtoSerializer();
}

class _$FontAdminFamilyDetailDtoSerializer implements PrimitiveSerializer<FontAdminFamilyDetailDto> {
  @override
  final Iterable<Type> types = const [FontAdminFamilyDetailDto, _$FontAdminFamilyDetailDto];

  @override
  final String wireName = r'FontAdminFamilyDetailDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontAdminFamilyDetailDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'designLanguage';
    yield serializers.serialize(
      object.designLanguage,
      specifiedType: const FullType(FontAdminFamilyDetailDtoDesignLanguageEnum),
    );
    yield r'sortOrder';
    yield serializers.serialize(
      object.sortOrder,
      specifiedType: const FullType(int),
    );
    yield r'author';
    yield serializers.serialize(
      object.author,
      specifiedType: const FullType(String),
    );
    yield r'sourceUrl';
    yield serializers.serialize(
      object.sourceUrl,
      specifiedType: const FullType(String),
    );
    yield r'licenseName';
    yield serializers.serialize(
      object.licenseName,
      specifiedType: const FullType(String),
    );
    yield r'licenseText';
    yield serializers.serialize(
      object.licenseText,
      specifiedType: const FullType(String),
    );
    yield r'specimenText';
    yield serializers.serialize(
      object.specimenText,
      specifiedType: const FullType(String),
    );
    yield r'rights';
    yield serializers.serialize(
      object.rights,
      specifiedType: const FullType(FontRightsDto),
    );
    yield r'familyId';
    yield serializers.serialize(
      object.familyId,
      specifiedType: const FullType(String),
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
    yield r'currentVersionId';
    yield object.currentVersionId == null ? null : serializers.serialize(
      object.currentVersionId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'catalogRevision';
    yield serializers.serialize(
      object.catalogRevision,
      specifiedType: const FullType(int),
    );
    yield r'jobs';
    yield serializers.serialize(
      object.jobs,
      specifiedType: const FullType(BuiltList, [FullType(FontJobDto)]),
    );
    yield r'versionIds';
    yield serializers.serialize(
      object.versionIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontAdminFamilyDetailDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontAdminFamilyDetailDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'designLanguage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontAdminFamilyDetailDtoDesignLanguageEnum),
          ) as FontAdminFamilyDetailDtoDesignLanguageEnum;
          result.designLanguage = valueDes;
          break;
        case r'sortOrder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sortOrder = valueDes;
          break;
        case r'author':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.author = valueDes;
          break;
        case r'sourceUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceUrl = valueDes;
          break;
        case r'licenseName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.licenseName = valueDes;
          break;
        case r'licenseText':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.licenseText = valueDes;
          break;
        case r'specimenText':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.specimenText = valueDes;
          break;
        case r'rights':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontRightsDto),
          ) as FontRightsDto;
          result.rights.replace(valueDes);
          break;
        case r'familyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.familyId = valueDes;
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
        case r'currentVersionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.currentVersionId = valueDes;
          break;
        case r'catalogRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.catalogRevision = valueDes;
          break;
        case r'jobs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FontJobDto)]),
          ) as BuiltList<FontJobDto>;
          result.jobs.replace(valueDes);
          break;
        case r'versionIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.versionIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontAdminFamilyDetailDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontAdminFamilyDetailDtoBuilder();
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

class FontAdminFamilyDetailDtoDesignLanguageEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'zh')
  static const FontAdminFamilyDetailDtoDesignLanguageEnum zh = _$fontAdminFamilyDetailDtoDesignLanguageEnum_zh;
  @BuiltValueEnumConst(wireName: r'ja')
  static const FontAdminFamilyDetailDtoDesignLanguageEnum ja = _$fontAdminFamilyDetailDtoDesignLanguageEnum_ja;
  @BuiltValueEnumConst(wireName: r'en')
  static const FontAdminFamilyDetailDtoDesignLanguageEnum en = _$fontAdminFamilyDetailDtoDesignLanguageEnum_en;
  @BuiltValueEnumConst(wireName: r'other')
  static const FontAdminFamilyDetailDtoDesignLanguageEnum other = _$fontAdminFamilyDetailDtoDesignLanguageEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontAdminFamilyDetailDtoDesignLanguageEnum unknownDefaultOpenApi = _$fontAdminFamilyDetailDtoDesignLanguageEnum_unknownDefaultOpenApi;

  static Serializer<FontAdminFamilyDetailDtoDesignLanguageEnum> get serializer => _$fontAdminFamilyDetailDtoDesignLanguageEnumSerializer;

  const FontAdminFamilyDetailDtoDesignLanguageEnum._(String name): super(name);

  static BuiltSet<FontAdminFamilyDetailDtoDesignLanguageEnum> get values => _$fontAdminFamilyDetailDtoDesignLanguageEnumValues;
  static FontAdminFamilyDetailDtoDesignLanguageEnum valueOf(String name) => _$fontAdminFamilyDetailDtoDesignLanguageEnumValueOf(name);
}
