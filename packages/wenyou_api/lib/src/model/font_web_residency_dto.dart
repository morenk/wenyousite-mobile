//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_web_residency_dto.g.dart';

/// FontWebResidencyDto
///
/// Properties:
/// * [mode]
/// * [scope] - 同一文档的多个阅读窗口共用一个运行时
/// * [maxFamilies] - 当前目录全部家族均可参与活动集合，不是历史累计次数；原件也占一个名额
/// * [maxFaces] - 活动与待注册 face 数；只有实际解除注册并释放引用后才归还
/// * [maxSfntBytes] - 普通片按移动 SFNT 字节预占；经哈希校验后与 WOFF2.totalSfntSize 取较大值，解码前补足；不是压缩字节或引擎 RSS
/// * [originalSfntBytes] - 固定原件独占的驻留输入额度，不可借给其他资源
@BuiltValue()
abstract class FontWebResidencyDto implements Built<FontWebResidencyDto, FontWebResidencyDtoBuilder> {
  @BuiltValueField(wireName: r'mode')
  FontWebResidencyDtoModeEnum get mode;
  // enum modeEnum {  lease-lru,  };

  /// 同一文档的多个阅读窗口共用一个运行时
  @BuiltValueField(wireName: r'scope')
  FontWebResidencyDtoScopeEnum get scope;
  // enum scopeEnum {  document,  };

  /// 当前目录全部家族均可参与活动集合，不是历史累计次数；原件也占一个名额
  @BuiltValueField(wireName: r'maxFamilies')
  FontWebResidencyDtoMaxFamiliesEnum get maxFamilies;
  // enum maxFamiliesEnum {  29,  };

  /// 活动与待注册 face 数；只有实际解除注册并释放引用后才归还
  @BuiltValueField(wireName: r'maxFaces')
  FontWebResidencyDtoMaxFacesEnum get maxFaces;
  // enum maxFacesEnum {  64,  };

  /// 普通片按移动 SFNT 字节预占；经哈希校验后与 WOFF2.totalSfntSize 取较大值，解码前补足；不是压缩字节或引擎 RSS
  @BuiltValueField(wireName: r'maxSfntBytes')
  FontWebResidencyDtoMaxSfntBytesEnum get maxSfntBytes;
  // enum maxSfntBytesEnum {  16777216,  };

  /// 固定原件独占的驻留输入额度，不可借给其他资源
  @BuiltValueField(wireName: r'originalSfntBytes')
  FontWebResidencyDtoOriginalSfntBytesEnum get originalSfntBytes;
  // enum originalSfntBytesEnum {  18410600,  };

  FontWebResidencyDto._();

  factory FontWebResidencyDto([void updates(FontWebResidencyDtoBuilder b)]) = _$FontWebResidencyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontWebResidencyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontWebResidencyDto> get serializer => _$FontWebResidencyDtoSerializer();
}

class _$FontWebResidencyDtoSerializer implements PrimitiveSerializer<FontWebResidencyDto> {
  @override
  final Iterable<Type> types = const [FontWebResidencyDto, _$FontWebResidencyDto];

  @override
  final String wireName = r'FontWebResidencyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontWebResidencyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mode';
    yield serializers.serialize(
      object.mode,
      specifiedType: const FullType(FontWebResidencyDtoModeEnum),
    );
    yield r'scope';
    yield serializers.serialize(
      object.scope,
      specifiedType: const FullType(FontWebResidencyDtoScopeEnum),
    );
    yield r'maxFamilies';
    yield serializers.serialize(
      object.maxFamilies,
      specifiedType: const FullType(FontWebResidencyDtoMaxFamiliesEnum),
    );
    yield r'maxFaces';
    yield serializers.serialize(
      object.maxFaces,
      specifiedType: const FullType(FontWebResidencyDtoMaxFacesEnum),
    );
    yield r'maxSfntBytes';
    yield serializers.serialize(
      object.maxSfntBytes,
      specifiedType: const FullType(FontWebResidencyDtoMaxSfntBytesEnum),
    );
    yield r'originalSfntBytes';
    yield serializers.serialize(
      object.originalSfntBytes,
      specifiedType: const FullType(FontWebResidencyDtoOriginalSfntBytesEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontWebResidencyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontWebResidencyDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontWebResidencyDtoModeEnum),
          ) as FontWebResidencyDtoModeEnum;
          result.mode = valueDes;
          break;
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontWebResidencyDtoScopeEnum),
          ) as FontWebResidencyDtoScopeEnum;
          result.scope = valueDes;
          break;
        case r'maxFamilies':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontWebResidencyDtoMaxFamiliesEnum),
          ) as FontWebResidencyDtoMaxFamiliesEnum;
          result.maxFamilies = valueDes;
          break;
        case r'maxFaces':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontWebResidencyDtoMaxFacesEnum),
          ) as FontWebResidencyDtoMaxFacesEnum;
          result.maxFaces = valueDes;
          break;
        case r'maxSfntBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontWebResidencyDtoMaxSfntBytesEnum),
          ) as FontWebResidencyDtoMaxSfntBytesEnum;
          result.maxSfntBytes = valueDes;
          break;
        case r'originalSfntBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontWebResidencyDtoOriginalSfntBytesEnum),
          ) as FontWebResidencyDtoOriginalSfntBytesEnum;
          result.originalSfntBytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontWebResidencyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontWebResidencyDtoBuilder();
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

class FontWebResidencyDtoModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'lease-lru')
  static const FontWebResidencyDtoModeEnum leaseLru = _$fontWebResidencyDtoModeEnum_leaseLru;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontWebResidencyDtoModeEnum unknownDefaultOpenApi = _$fontWebResidencyDtoModeEnum_unknownDefaultOpenApi;

  static Serializer<FontWebResidencyDtoModeEnum> get serializer => _$fontWebResidencyDtoModeEnumSerializer;

  const FontWebResidencyDtoModeEnum._(String name): super(name);

  static BuiltSet<FontWebResidencyDtoModeEnum> get values => _$fontWebResidencyDtoModeEnumValues;
  static FontWebResidencyDtoModeEnum valueOf(String name) => _$fontWebResidencyDtoModeEnumValueOf(name);
}

class FontWebResidencyDtoScopeEnum extends EnumClass {

  /// 同一文档的多个阅读窗口共用一个运行时
  @BuiltValueEnumConst(wireName: r'document')
  static const FontWebResidencyDtoScopeEnum document = _$fontWebResidencyDtoScopeEnum_document;
  /// 同一文档的多个阅读窗口共用一个运行时
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontWebResidencyDtoScopeEnum unknownDefaultOpenApi = _$fontWebResidencyDtoScopeEnum_unknownDefaultOpenApi;

  static Serializer<FontWebResidencyDtoScopeEnum> get serializer => _$fontWebResidencyDtoScopeEnumSerializer;

  const FontWebResidencyDtoScopeEnum._(String name): super(name);

  static BuiltSet<FontWebResidencyDtoScopeEnum> get values => _$fontWebResidencyDtoScopeEnumValues;
  static FontWebResidencyDtoScopeEnum valueOf(String name) => _$fontWebResidencyDtoScopeEnumValueOf(name);
}

class FontWebResidencyDtoMaxFamiliesEnum extends EnumClass {

  /// 当前目录全部家族均可参与活动集合，不是历史累计次数；原件也占一个名额
  @BuiltValueEnumConst(wireName: r'29')
  static const FontWebResidencyDtoMaxFamiliesEnum n29 = _$fontWebResidencyDtoMaxFamiliesEnum_n29;
  /// 当前目录全部家族均可参与活动集合，不是历史累计次数；原件也占一个名额
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontWebResidencyDtoMaxFamiliesEnum unknownDefaultOpenApi = _$fontWebResidencyDtoMaxFamiliesEnum_unknownDefaultOpenApi;

  static Serializer<FontWebResidencyDtoMaxFamiliesEnum> get serializer => _$fontWebResidencyDtoMaxFamiliesEnumSerializer;

  const FontWebResidencyDtoMaxFamiliesEnum._(String name): super(name);

  static BuiltSet<FontWebResidencyDtoMaxFamiliesEnum> get values => _$fontWebResidencyDtoMaxFamiliesEnumValues;
  static FontWebResidencyDtoMaxFamiliesEnum valueOf(String name) => _$fontWebResidencyDtoMaxFamiliesEnumValueOf(name);
}

class FontWebResidencyDtoMaxFacesEnum extends EnumClass {

  /// 活动与待注册 face 数；只有实际解除注册并释放引用后才归还
  @BuiltValueEnumConst(wireName: r'64')
  static const FontWebResidencyDtoMaxFacesEnum n64 = _$fontWebResidencyDtoMaxFacesEnum_n64;
  /// 活动与待注册 face 数；只有实际解除注册并释放引用后才归还
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontWebResidencyDtoMaxFacesEnum unknownDefaultOpenApi = _$fontWebResidencyDtoMaxFacesEnum_unknownDefaultOpenApi;

  static Serializer<FontWebResidencyDtoMaxFacesEnum> get serializer => _$fontWebResidencyDtoMaxFacesEnumSerializer;

  const FontWebResidencyDtoMaxFacesEnum._(String name): super(name);

  static BuiltSet<FontWebResidencyDtoMaxFacesEnum> get values => _$fontWebResidencyDtoMaxFacesEnumValues;
  static FontWebResidencyDtoMaxFacesEnum valueOf(String name) => _$fontWebResidencyDtoMaxFacesEnumValueOf(name);
}

class FontWebResidencyDtoMaxSfntBytesEnum extends EnumClass {

  /// 普通片按移动 SFNT 字节预占；经哈希校验后与 WOFF2.totalSfntSize 取较大值，解码前补足；不是压缩字节或引擎 RSS
  @BuiltValueEnumConst(wireName: r'16777216')
  static const FontWebResidencyDtoMaxSfntBytesEnum n16777216 = _$fontWebResidencyDtoMaxSfntBytesEnum_n16777216;
  /// 普通片按移动 SFNT 字节预占；经哈希校验后与 WOFF2.totalSfntSize 取较大值，解码前补足；不是压缩字节或引擎 RSS
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontWebResidencyDtoMaxSfntBytesEnum unknownDefaultOpenApi = _$fontWebResidencyDtoMaxSfntBytesEnum_unknownDefaultOpenApi;

  static Serializer<FontWebResidencyDtoMaxSfntBytesEnum> get serializer => _$fontWebResidencyDtoMaxSfntBytesEnumSerializer;

  const FontWebResidencyDtoMaxSfntBytesEnum._(String name): super(name);

  static BuiltSet<FontWebResidencyDtoMaxSfntBytesEnum> get values => _$fontWebResidencyDtoMaxSfntBytesEnumValues;
  static FontWebResidencyDtoMaxSfntBytesEnum valueOf(String name) => _$fontWebResidencyDtoMaxSfntBytesEnumValueOf(name);
}

class FontWebResidencyDtoOriginalSfntBytesEnum extends EnumClass {

  /// 固定原件独占的驻留输入额度，不可借给其他资源
  @BuiltValueEnumConst(wireName: r'18410600')
  static const FontWebResidencyDtoOriginalSfntBytesEnum n18410600 = _$fontWebResidencyDtoOriginalSfntBytesEnum_n18410600;
  /// 固定原件独占的驻留输入额度，不可借给其他资源
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontWebResidencyDtoOriginalSfntBytesEnum unknownDefaultOpenApi = _$fontWebResidencyDtoOriginalSfntBytesEnum_unknownDefaultOpenApi;

  static Serializer<FontWebResidencyDtoOriginalSfntBytesEnum> get serializer => _$fontWebResidencyDtoOriginalSfntBytesEnumSerializer;

  const FontWebResidencyDtoOriginalSfntBytesEnum._(String name): super(name);

  static BuiltSet<FontWebResidencyDtoOriginalSfntBytesEnum> get values => _$fontWebResidencyDtoOriginalSfntBytesEnumValues;
  static FontWebResidencyDtoOriginalSfntBytesEnum valueOf(String name) => _$fontWebResidencyDtoOriginalSfntBytesEnumValueOf(name);
}
