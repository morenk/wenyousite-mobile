//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_rights_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_configuration_dto.g.dart';

/// FontConfigurationDto
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
@BuiltValue()
abstract class FontConfigurationDto implements Built<FontConfigurationDto, FontConfigurationDtoBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'designLanguage')
  FontConfigurationDtoDesignLanguageEnum get designLanguage;
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

  FontConfigurationDto._();

  factory FontConfigurationDto([void updates(FontConfigurationDtoBuilder b)]) = _$FontConfigurationDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontConfigurationDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontConfigurationDto> get serializer => _$FontConfigurationDtoSerializer();
}

class _$FontConfigurationDtoSerializer implements PrimitiveSerializer<FontConfigurationDto> {
  @override
  final Iterable<Type> types = const [FontConfigurationDto, _$FontConfigurationDto];

  @override
  final String wireName = r'FontConfigurationDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontConfigurationDto object, {
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
      specifiedType: const FullType(FontConfigurationDtoDesignLanguageEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    FontConfigurationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontConfigurationDtoBuilder result,
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
            specifiedType: const FullType(FontConfigurationDtoDesignLanguageEnum),
          ) as FontConfigurationDtoDesignLanguageEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontConfigurationDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontConfigurationDtoBuilder();
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

class FontConfigurationDtoDesignLanguageEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'zh')
  static const FontConfigurationDtoDesignLanguageEnum zh = _$fontConfigurationDtoDesignLanguageEnum_zh;
  @BuiltValueEnumConst(wireName: r'ja')
  static const FontConfigurationDtoDesignLanguageEnum ja = _$fontConfigurationDtoDesignLanguageEnum_ja;
  @BuiltValueEnumConst(wireName: r'en')
  static const FontConfigurationDtoDesignLanguageEnum en = _$fontConfigurationDtoDesignLanguageEnum_en;
  @BuiltValueEnumConst(wireName: r'other')
  static const FontConfigurationDtoDesignLanguageEnum other = _$fontConfigurationDtoDesignLanguageEnum_other;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontConfigurationDtoDesignLanguageEnum unknownDefaultOpenApi = _$fontConfigurationDtoDesignLanguageEnum_unknownDefaultOpenApi;

  static Serializer<FontConfigurationDtoDesignLanguageEnum> get serializer => _$fontConfigurationDtoDesignLanguageEnumSerializer;

  const FontConfigurationDtoDesignLanguageEnum._(String name): super(name);

  static BuiltSet<FontConfigurationDtoDesignLanguageEnum> get values => _$fontConfigurationDtoDesignLanguageEnumValues;
  static FontConfigurationDtoDesignLanguageEnum valueOf(String name) => _$fontConfigurationDtoDesignLanguageEnumValueOf(name);
}
