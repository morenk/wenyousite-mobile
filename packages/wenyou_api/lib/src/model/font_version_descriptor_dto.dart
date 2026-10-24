//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_asset_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_version_descriptor_dto.g.dart';

/// FontVersionDescriptorDto
///
/// Properties:
/// * [fontVersion]
/// * [versionId]
/// * [familyId]
/// * [versionNumber]
/// * [name]
/// * [designLanguage]
/// * [revision] - 最新全局状态修订；比旧缓存优先。显式 withdrawn 为不可逆墓碑。
/// * [status]
/// * [selectable] - 只有当前启用家族的当前发布版本可从选择器新选。
/// * [pasteAllowed] - 启用家族的未撤回历史已发布版本可粘贴/扩写；停用、撤回及仅预览版本不可。
/// * [renderAllowed] - 停用及历史版本可呈现；撤回禁止呈现与下载，保留正文源。preview 仅管理员可呈现。
/// * [assetBasePath] - 撤回为 null；其他状态指向本站受状态校验的下载网关。
/// * [manifest] - 按需获取的单版本分片清单；撤回为 null。
/// * [specimen]
@BuiltValue()
abstract class FontVersionDescriptorDto implements Built<FontVersionDescriptorDto, FontVersionDescriptorDtoBuilder> {
  @BuiltValueField(wireName: r'fontVersion')
  FontVersionDescriptorDtoFontVersionEnum get fontVersion;
  // enum fontVersionEnum {  2,  };

  @BuiltValueField(wireName: r'versionId')
  String get versionId;

  @BuiltValueField(wireName: r'familyId')
  String get familyId;

  @BuiltValueField(wireName: r'versionNumber')
  int get versionNumber;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'designLanguage')
  FontVersionDescriptorDtoDesignLanguageEnum get designLanguage;
  // enum designLanguageEnum {  zh,  ja,  en,  other,  };

  /// 最新全局状态修订；比旧缓存优先。显式 withdrawn 为不可逆墓碑。
  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'status')
  FontVersionDescriptorDtoStatusEnum get status;
  // enum statusEnum {  published,  disabled,  withdrawn,  preview,  };

  /// 只有当前启用家族的当前发布版本可从选择器新选。
  @BuiltValueField(wireName: r'selectable')
  bool get selectable;

  /// 启用家族的未撤回历史已发布版本可粘贴/扩写；停用、撤回及仅预览版本不可。
  @BuiltValueField(wireName: r'pasteAllowed')
  bool get pasteAllowed;

  /// 停用及历史版本可呈现；撤回禁止呈现与下载，保留正文源。preview 仅管理员可呈现。
  @BuiltValueField(wireName: r'renderAllowed')
  bool get renderAllowed;

  /// 撤回为 null；其他状态指向本站受状态校验的下载网关。
  @BuiltValueField(wireName: r'assetBasePath')
  String? get assetBasePath;

  /// 按需获取的单版本分片清单；撤回为 null。
  @BuiltValueField(wireName: r'manifest')
  FontAssetDto? get manifest;

  @BuiltValueField(wireName: r'specimen')
  FontAssetDto? get specimen;

  FontVersionDescriptorDto._();

  factory FontVersionDescriptorDto([void updates(FontVersionDescriptorDtoBuilder b)]) = _$FontVersionDescriptorDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontVersionDescriptorDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontVersionDescriptorDto> get serializer => _$FontVersionDescriptorDtoSerializer();
}

class _$FontVersionDescriptorDtoSerializer implements PrimitiveSerializer<FontVersionDescriptorDto> {
  @override
  final Iterable<Type> types = const [FontVersionDescriptorDto, _$FontVersionDescriptorDto];

  @override
  final String wireName = r'FontVersionDescriptorDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontVersionDescriptorDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fontVersion';
    yield serializers.serialize(
      object.fontVersion,
      specifiedType: const FullType(FontVersionDescriptorDtoFontVersionEnum),
    );
    yield r'versionId';
    yield serializers.serialize(
      object.versionId,
      specifiedType: const FullType(String),
    );
    yield r'familyId';
    yield serializers.serialize(
      object.familyId,
      specifiedType: const FullType(String),
    );
    yield r'versionNumber';
    yield serializers.serialize(
      object.versionNumber,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'designLanguage';
    yield serializers.serialize(
      object.designLanguage,
      specifiedType: const FullType(FontVersionDescriptorDtoDesignLanguageEnum),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(FontVersionDescriptorDtoStatusEnum),
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
    yield object.assetBasePath == null ? null : serializers.serialize(
      object.assetBasePath,
      specifiedType: const FullType.nullable(String),
    );
    yield r'manifest';
    yield object.manifest == null ? null : serializers.serialize(
      object.manifest,
      specifiedType: const FullType.nullable(FontAssetDto),
    );
    yield r'specimen';
    yield object.specimen == null ? null : serializers.serialize(
      object.specimen,
      specifiedType: const FullType.nullable(FontAssetDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontVersionDescriptorDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontVersionDescriptorDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fontVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontVersionDescriptorDtoFontVersionEnum),
          ) as FontVersionDescriptorDtoFontVersionEnum;
          result.fontVersion = valueDes;
          break;
        case r'versionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.versionId = valueDes;
          break;
        case r'familyId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.familyId = valueDes;
          break;
        case r'versionNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.versionNumber = valueDes;
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
            specifiedType: const FullType(FontVersionDescriptorDtoDesignLanguageEnum),
          ) as FontVersionDescriptorDtoDesignLanguageEnum;
          result.designLanguage = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontVersionDescriptorDtoStatusEnum),
          ) as FontVersionDescriptorDtoStatusEnum;
          result.status = valueDes;
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assetBasePath = valueDes;
          break;
        case r'manifest':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(FontAssetDto),
          ) as FontAssetDto?;
          if (valueDes == null) continue;
          result.manifest.replace(valueDes);
          break;
        case r'specimen':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(FontAssetDto),
          ) as FontAssetDto?;
          if (valueDes == null) continue;
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
  FontVersionDescriptorDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontVersionDescriptorDtoBuilder();
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

class FontVersionDescriptorDtoFontVersionEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 2)
  static const FontVersionDescriptorDtoFontVersionEnum n2 = _$fontVersionDescriptorDtoFontVersionEnum_n2;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontVersionDescriptorDtoFontVersionEnum unknownDefaultOpenApi = _$fontVersionDescriptorDtoFontVersionEnum_unknownDefaultOpenApi;

  static Serializer<FontVersionDescriptorDtoFontVersionEnum> get serializer => _$fontVersionDescriptorDtoFontVersionEnumSerializer;

  const FontVersionDescriptorDtoFontVersionEnum._(String name): super(name);

  static BuiltSet<FontVersionDescriptorDtoFontVersionEnum> get values => _$fontVersionDescriptorDtoFontVersionEnumValues;
  static FontVersionDescriptorDtoFontVersionEnum valueOf(String name) => _$fontVersionDescriptorDtoFontVersionEnumValueOf(name);
}

class FontVersionDescriptorDtoDesignLanguageEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'zh')
  static const FontVersionDescriptorDtoDesignLanguageEnum zh = _$fontVersionDescriptorDtoDesignLanguageEnum_zh;
  @BuiltValueEnumConst(wireName: r'ja')
  static const FontVersionDescriptorDtoDesignLanguageEnum ja = _$fontVersionDescriptorDtoDesignLanguageEnum_ja;
  @BuiltValueEnumConst(wireName: r'en')
  static const FontVersionDescriptorDtoDesignLanguageEnum en = _$fontVersionDescriptorDtoDesignLanguageEnum_en;
  @BuiltValueEnumConst(wireName: r'other')
  static const FontVersionDescriptorDtoDesignLanguageEnum other = _$fontVersionDescriptorDtoDesignLanguageEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontVersionDescriptorDtoDesignLanguageEnum unknownDefaultOpenApi = _$fontVersionDescriptorDtoDesignLanguageEnum_unknownDefaultOpenApi;

  static Serializer<FontVersionDescriptorDtoDesignLanguageEnum> get serializer => _$fontVersionDescriptorDtoDesignLanguageEnumSerializer;

  const FontVersionDescriptorDtoDesignLanguageEnum._(String name): super(name);

  static BuiltSet<FontVersionDescriptorDtoDesignLanguageEnum> get values => _$fontVersionDescriptorDtoDesignLanguageEnumValues;
  static FontVersionDescriptorDtoDesignLanguageEnum valueOf(String name) => _$fontVersionDescriptorDtoDesignLanguageEnumValueOf(name);
}

class FontVersionDescriptorDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'published')
  static const FontVersionDescriptorDtoStatusEnum published = _$fontVersionDescriptorDtoStatusEnum_published;
  @BuiltValueEnumConst(wireName: r'disabled')
  static const FontVersionDescriptorDtoStatusEnum disabled = _$fontVersionDescriptorDtoStatusEnum_disabled;
  @BuiltValueEnumConst(wireName: r'withdrawn')
  static const FontVersionDescriptorDtoStatusEnum withdrawn = _$fontVersionDescriptorDtoStatusEnum_withdrawn;
  @BuiltValueEnumConst(wireName: r'preview')
  static const FontVersionDescriptorDtoStatusEnum preview = _$fontVersionDescriptorDtoStatusEnum_preview;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontVersionDescriptorDtoStatusEnum unknownDefaultOpenApi = _$fontVersionDescriptorDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<FontVersionDescriptorDtoStatusEnum> get serializer => _$fontVersionDescriptorDtoStatusEnumSerializer;

  const FontVersionDescriptorDtoStatusEnum._(String name): super(name);

  static BuiltSet<FontVersionDescriptorDtoStatusEnum> get values => _$fontVersionDescriptorDtoStatusEnumValues;
  static FontVersionDescriptorDtoStatusEnum valueOf(String name) => _$fontVersionDescriptorDtoStatusEnumValueOf(name);
}
