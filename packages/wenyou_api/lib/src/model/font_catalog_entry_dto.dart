//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_asset_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_catalog_entry_dto.g.dart';

/// FontCatalogEntryDto
///
/// Properties:
/// * [familyId]
/// * [versionId]
/// * [name]
/// * [designLanguage]
/// * [sortOrder]
/// * [selectable]
/// * [pasteAllowed]
/// * [renderAllowed]
/// * [assetBasePath] - 本站 API 相对路径；资源为 assetBasePath + sha256 + 点 + format。禁止任意外部 URL。
/// * [specimen] - PNG 样张；选择器不为预览下载字体分片。
@BuiltValue()
abstract class FontCatalogEntryDto implements Built<FontCatalogEntryDto, FontCatalogEntryDtoBuilder> {
  @BuiltValueField(wireName: r'familyId')
  String get familyId;

  @BuiltValueField(wireName: r'versionId')
  String get versionId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'designLanguage')
  FontCatalogEntryDtoDesignLanguageEnum get designLanguage;
  // enum designLanguageEnum {  zh,  ja,  en,  other,  };

  @BuiltValueField(wireName: r'sortOrder')
  int get sortOrder;

  @BuiltValueField(wireName: r'selectable')
  bool get selectable;

  @BuiltValueField(wireName: r'pasteAllowed')
  bool get pasteAllowed;

  @BuiltValueField(wireName: r'renderAllowed')
  bool get renderAllowed;

  /// 本站 API 相对路径；资源为 assetBasePath + sha256 + 点 + format。禁止任意外部 URL。
  @BuiltValueField(wireName: r'assetBasePath')
  String get assetBasePath;

  /// PNG 样张；选择器不为预览下载字体分片。
  @BuiltValueField(wireName: r'specimen')
  FontAssetDto get specimen;

  FontCatalogEntryDto._();

  factory FontCatalogEntryDto([void updates(FontCatalogEntryDtoBuilder b)]) = _$FontCatalogEntryDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontCatalogEntryDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontCatalogEntryDto> get serializer => _$FontCatalogEntryDtoSerializer();
}

class _$FontCatalogEntryDtoSerializer implements PrimitiveSerializer<FontCatalogEntryDto> {
  @override
  final Iterable<Type> types = const [FontCatalogEntryDto, _$FontCatalogEntryDto];

  @override
  final String wireName = r'FontCatalogEntryDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontCatalogEntryDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'familyId';
    yield serializers.serialize(
      object.familyId,
      specifiedType: const FullType(String),
    );
    yield r'versionId';
    yield serializers.serialize(
      object.versionId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'designLanguage';
    yield serializers.serialize(
      object.designLanguage,
      specifiedType: const FullType(FontCatalogEntryDtoDesignLanguageEnum),
    );
    yield r'sortOrder';
    yield serializers.serialize(
      object.sortOrder,
      specifiedType: const FullType(int),
    );
    yield r'selectable';
    yield serializers.serialize(
      object.selectable,
      specifiedType: const FullType(bool),
    );
    yield r'pasteAllowed';
    yield serializers.serialize(
      object.pasteAllowed,
      specifiedType: const FullType(bool),
    );
    yield r'renderAllowed';
    yield serializers.serialize(
      object.renderAllowed,
      specifiedType: const FullType(bool),
    );
    yield r'assetBasePath';
    yield serializers.serialize(
      object.assetBasePath,
      specifiedType: const FullType(String),
    );
    yield r'specimen';
    yield serializers.serialize(
      object.specimen,
      specifiedType: const FullType(FontAssetDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontCatalogEntryDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontCatalogEntryDtoBuilder result,
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
        case r'versionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.versionId = valueDes;
          break;
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
            specifiedType: const FullType(FontCatalogEntryDtoDesignLanguageEnum),
          ) as FontCatalogEntryDtoDesignLanguageEnum;
          result.designLanguage = valueDes;
          break;
        case r'sortOrder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sortOrder = valueDes;
          break;
        case r'selectable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.selectable = valueDes;
          break;
        case r'pasteAllowed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pasteAllowed = valueDes;
          break;
        case r'renderAllowed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.renderAllowed = valueDes;
          break;
        case r'assetBasePath':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.assetBasePath = valueDes;
          break;
        case r'specimen':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontAssetDto),
          ) as FontAssetDto;
          result.specimen.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontCatalogEntryDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontCatalogEntryDtoBuilder();
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

class FontCatalogEntryDtoDesignLanguageEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'zh')
  static const FontCatalogEntryDtoDesignLanguageEnum zh = _$fontCatalogEntryDtoDesignLanguageEnum_zh;
  @BuiltValueEnumConst(wireName: r'ja')
  static const FontCatalogEntryDtoDesignLanguageEnum ja = _$fontCatalogEntryDtoDesignLanguageEnum_ja;
  @BuiltValueEnumConst(wireName: r'en')
  static const FontCatalogEntryDtoDesignLanguageEnum en = _$fontCatalogEntryDtoDesignLanguageEnum_en;
  @BuiltValueEnumConst(wireName: r'other')
  static const FontCatalogEntryDtoDesignLanguageEnum other = _$fontCatalogEntryDtoDesignLanguageEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontCatalogEntryDtoDesignLanguageEnum unknownDefaultOpenApi = _$fontCatalogEntryDtoDesignLanguageEnum_unknownDefaultOpenApi;

  static Serializer<FontCatalogEntryDtoDesignLanguageEnum> get serializer => _$fontCatalogEntryDtoDesignLanguageEnumSerializer;

  const FontCatalogEntryDtoDesignLanguageEnum._(String name): super(name);

  static BuiltSet<FontCatalogEntryDtoDesignLanguageEnum> get values => _$fontCatalogEntryDtoDesignLanguageEnumValues;
  static FontCatalogEntryDtoDesignLanguageEnum valueOf(String name) => _$fontCatalogEntryDtoDesignLanguageEnumValueOf(name);
}
