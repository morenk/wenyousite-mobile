//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_rights_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_font_configuration_dto.g.dart';

/// UpdateFontConfigurationDto
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
/// * [expectedFamilyRevision]
@BuiltValue()
abstract class UpdateFontConfigurationDto implements Built<UpdateFontConfigurationDto, UpdateFontConfigurationDtoBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'designLanguage')
  UpdateFontConfigurationDtoDesignLanguageEnum get designLanguage;
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

  @BuiltValueField(wireName: r'expectedFamilyRevision')
  int get expectedFamilyRevision;

  UpdateFontConfigurationDto._();

  factory UpdateFontConfigurationDto([void updates(UpdateFontConfigurationDtoBuilder b)]) = _$UpdateFontConfigurationDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateFontConfigurationDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateFontConfigurationDto> get serializer => _$UpdateFontConfigurationDtoSerializer();
}

class _$UpdateFontConfigurationDtoSerializer implements PrimitiveSerializer<UpdateFontConfigurationDto> {
  @override
  final Iterable<Type> types = const [UpdateFontConfigurationDto, _$UpdateFontConfigurationDto];

  @override
  final String wireName = r'UpdateFontConfigurationDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateFontConfigurationDto object, {
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
      specifiedType: const FullType(UpdateFontConfigurationDtoDesignLanguageEnum),
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
    yield r'expectedFamilyRevision';
    yield serializers.serialize(
      object.expectedFamilyRevision,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateFontConfigurationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateFontConfigurationDtoBuilder result,
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
            specifiedType: const FullType(UpdateFontConfigurationDtoDesignLanguageEnum),
          ) as UpdateFontConfigurationDtoDesignLanguageEnum;
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
        case r'expectedFamilyRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expectedFamilyRevision = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateFontConfigurationDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateFontConfigurationDtoBuilder();
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

class UpdateFontConfigurationDtoDesignLanguageEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'zh')
  static const UpdateFontConfigurationDtoDesignLanguageEnum zh = _$updateFontConfigurationDtoDesignLanguageEnum_zh;
  @BuiltValueEnumConst(wireName: r'ja')
  static const UpdateFontConfigurationDtoDesignLanguageEnum ja = _$updateFontConfigurationDtoDesignLanguageEnum_ja;
  @BuiltValueEnumConst(wireName: r'en')
  static const UpdateFontConfigurationDtoDesignLanguageEnum en = _$updateFontConfigurationDtoDesignLanguageEnum_en;
  @BuiltValueEnumConst(wireName: r'other')
  static const UpdateFontConfigurationDtoDesignLanguageEnum other = _$updateFontConfigurationDtoDesignLanguageEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const UpdateFontConfigurationDtoDesignLanguageEnum unknownDefaultOpenApi = _$updateFontConfigurationDtoDesignLanguageEnum_unknownDefaultOpenApi;

  static Serializer<UpdateFontConfigurationDtoDesignLanguageEnum> get serializer => _$updateFontConfigurationDtoDesignLanguageEnumSerializer;

  const UpdateFontConfigurationDtoDesignLanguageEnum._(String name): super(name);

  static BuiltSet<UpdateFontConfigurationDtoDesignLanguageEnum> get values => _$updateFontConfigurationDtoDesignLanguageEnumValues;
  static UpdateFontConfigurationDtoDesignLanguageEnum valueOf(String name) => _$updateFontConfigurationDtoDesignLanguageEnumValueOf(name);
}
