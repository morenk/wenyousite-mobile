//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'text_font_family_dto.g.dart';

/// TextFontFamilyDto
///
/// Properties:
/// * [id] - 正文 data-wenyou-font-v1 使用的固定身份
/// * [name]
/// * [designLanguage] - 主要设计语言，仅用于目录分组；不表示字符覆盖完整，也不依据名称或汉字数量推断。
/// * [availability] - ready 表示构建产物已核验；实际加载还须 assetBaseUrl。pendingSource/pendingLicense 不可选择或新增写入。
@BuiltValue()
abstract class TextFontFamilyDto implements Built<TextFontFamilyDto, TextFontFamilyDtoBuilder> {
  /// 正文 data-wenyou-font-v1 使用的固定身份
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  /// 主要设计语言，仅用于目录分组；不表示字符覆盖完整，也不依据名称或汉字数量推断。
  @BuiltValueField(wireName: r'designLanguage')
  TextFontFamilyDtoDesignLanguageEnum get designLanguage;
  // enum designLanguageEnum {  zh,  ja,  en,  };

  /// ready 表示构建产物已核验；实际加载还须 assetBaseUrl。pendingSource/pendingLicense 不可选择或新增写入。
  @BuiltValueField(wireName: r'availability')
  TextFontFamilyDtoAvailabilityEnum get availability;
  // enum availabilityEnum {  ready,  pendingSource,  pendingLicense,  };

  TextFontFamilyDto._();

  factory TextFontFamilyDto([void updates(TextFontFamilyDtoBuilder b)]) = _$TextFontFamilyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TextFontFamilyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TextFontFamilyDto> get serializer => _$TextFontFamilyDtoSerializer();
}

class _$TextFontFamilyDtoSerializer implements PrimitiveSerializer<TextFontFamilyDto> {
  @override
  final Iterable<Type> types = const [TextFontFamilyDto, _$TextFontFamilyDto];

  @override
  final String wireName = r'TextFontFamilyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TextFontFamilyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
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
      specifiedType: const FullType(TextFontFamilyDtoDesignLanguageEnum),
    );
    yield r'availability';
    yield serializers.serialize(
      object.availability,
      specifiedType: const FullType(TextFontFamilyDtoAvailabilityEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TextFontFamilyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TextFontFamilyDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
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
            specifiedType: const FullType(TextFontFamilyDtoDesignLanguageEnum),
          ) as TextFontFamilyDtoDesignLanguageEnum;
          result.designLanguage = valueDes;
          break;
        case r'availability':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TextFontFamilyDtoAvailabilityEnum),
          ) as TextFontFamilyDtoAvailabilityEnum;
          result.availability = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TextFontFamilyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TextFontFamilyDtoBuilder();
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

class TextFontFamilyDtoDesignLanguageEnum extends EnumClass {

  /// 主要设计语言，仅用于目录分组；不表示字符覆盖完整，也不依据名称或汉字数量推断。
  @BuiltValueEnumConst(wireName: r'zh')
  static const TextFontFamilyDtoDesignLanguageEnum zh = _$textFontFamilyDtoDesignLanguageEnum_zh;
  /// 主要设计语言，仅用于目录分组；不表示字符覆盖完整，也不依据名称或汉字数量推断。
  @BuiltValueEnumConst(wireName: r'ja')
  static const TextFontFamilyDtoDesignLanguageEnum ja = _$textFontFamilyDtoDesignLanguageEnum_ja;
  /// 主要设计语言，仅用于目录分组；不表示字符覆盖完整，也不依据名称或汉字数量推断。
  @BuiltValueEnumConst(wireName: r'en')
  static const TextFontFamilyDtoDesignLanguageEnum en = _$textFontFamilyDtoDesignLanguageEnum_en;
  /// 主要设计语言，仅用于目录分组；不表示字符覆盖完整，也不依据名称或汉字数量推断。
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const TextFontFamilyDtoDesignLanguageEnum unknownDefaultOpenApi = _$textFontFamilyDtoDesignLanguageEnum_unknownDefaultOpenApi;

  static Serializer<TextFontFamilyDtoDesignLanguageEnum> get serializer => _$textFontFamilyDtoDesignLanguageEnumSerializer;

  const TextFontFamilyDtoDesignLanguageEnum._(String name): super(name);

  static BuiltSet<TextFontFamilyDtoDesignLanguageEnum> get values => _$textFontFamilyDtoDesignLanguageEnumValues;
  static TextFontFamilyDtoDesignLanguageEnum valueOf(String name) => _$textFontFamilyDtoDesignLanguageEnumValueOf(name);
}

class TextFontFamilyDtoAvailabilityEnum extends EnumClass {

  /// ready 表示构建产物已核验；实际加载还须 assetBaseUrl。pendingSource/pendingLicense 不可选择或新增写入。
  @BuiltValueEnumConst(wireName: r'ready')
  static const TextFontFamilyDtoAvailabilityEnum ready = _$textFontFamilyDtoAvailabilityEnum_ready;
  /// ready 表示构建产物已核验；实际加载还须 assetBaseUrl。pendingSource/pendingLicense 不可选择或新增写入。
  @BuiltValueEnumConst(wireName: r'pendingSource')
  static const TextFontFamilyDtoAvailabilityEnum pendingSource = _$textFontFamilyDtoAvailabilityEnum_pendingSource;
  /// ready 表示构建产物已核验；实际加载还须 assetBaseUrl。pendingSource/pendingLicense 不可选择或新增写入。
  @BuiltValueEnumConst(wireName: r'pendingLicense')
  static const TextFontFamilyDtoAvailabilityEnum pendingLicense = _$textFontFamilyDtoAvailabilityEnum_pendingLicense;
  /// ready 表示构建产物已核验；实际加载还须 assetBaseUrl。pendingSource/pendingLicense 不可选择或新增写入。
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const TextFontFamilyDtoAvailabilityEnum unknownDefaultOpenApi = _$textFontFamilyDtoAvailabilityEnum_unknownDefaultOpenApi;

  static Serializer<TextFontFamilyDtoAvailabilityEnum> get serializer => _$textFontFamilyDtoAvailabilityEnumSerializer;

  const TextFontFamilyDtoAvailabilityEnum._(String name): super(name);

  static BuiltSet<TextFontFamilyDtoAvailabilityEnum> get values => _$textFontFamilyDtoAvailabilityEnumValues;
  static TextFontFamilyDtoAvailabilityEnum valueOf(String name) => _$textFontFamilyDtoAvailabilityEnumValueOf(name);
}
