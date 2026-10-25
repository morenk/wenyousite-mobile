//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_original_asset_dto.g.dart';

/// FontOriginalAssetDto
///
/// Properties:
/// * [fontId]
/// * [sha256] - 必须匹配 manifest 中已授权原件的固定 SHA
/// * [bytes]
/// * [maxResidentCopies] - 同一注册域并发预留／驻留原件至多一份，不按时间窗口续增
@BuiltValue()
abstract class FontOriginalAssetDto implements Built<FontOriginalAssetDto, FontOriginalAssetDtoBuilder> {
  @BuiltValueField(wireName: r'fontId')
  FontOriginalAssetDtoFontIdEnum get fontId;
  // enum fontIdEnum {  xiaocheng-lafeng,  };

  /// 必须匹配 manifest 中已授权原件的固定 SHA
  @BuiltValueField(wireName: r'sha256')
  String get sha256;

  @BuiltValueField(wireName: r'bytes')
  FontOriginalAssetDtoBytesEnum get bytes;
  // enum bytesEnum {  18410600,  };

  /// 同一注册域并发预留／驻留原件至多一份，不按时间窗口续增
  @BuiltValueField(wireName: r'maxResidentCopies')
  FontOriginalAssetDtoMaxResidentCopiesEnum get maxResidentCopies;
  // enum maxResidentCopiesEnum {  1,  };

  FontOriginalAssetDto._();

  factory FontOriginalAssetDto([void updates(FontOriginalAssetDtoBuilder b)]) = _$FontOriginalAssetDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontOriginalAssetDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontOriginalAssetDto> get serializer => _$FontOriginalAssetDtoSerializer();
}

class _$FontOriginalAssetDtoSerializer implements PrimitiveSerializer<FontOriginalAssetDto> {
  @override
  final Iterable<Type> types = const [FontOriginalAssetDto, _$FontOriginalAssetDto];

  @override
  final String wireName = r'FontOriginalAssetDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontOriginalAssetDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fontId';
    yield serializers.serialize(
      object.fontId,
      specifiedType: const FullType(FontOriginalAssetDtoFontIdEnum),
    );
    yield r'sha256';
    yield serializers.serialize(
      object.sha256,
      specifiedType: const FullType(String),
    );
    yield r'bytes';
    yield serializers.serialize(
      object.bytes,
      specifiedType: const FullType(FontOriginalAssetDtoBytesEnum),
    );
    yield r'maxResidentCopies';
    yield serializers.serialize(
      object.maxResidentCopies,
      specifiedType: const FullType(FontOriginalAssetDtoMaxResidentCopiesEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontOriginalAssetDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontOriginalAssetDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fontId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontOriginalAssetDtoFontIdEnum),
          ) as FontOriginalAssetDtoFontIdEnum;
          result.fontId = valueDes;
          break;
        case r'sha256':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sha256 = valueDes;
          break;
        case r'bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontOriginalAssetDtoBytesEnum),
          ) as FontOriginalAssetDtoBytesEnum;
          result.bytes = valueDes;
          break;
        case r'maxResidentCopies':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontOriginalAssetDtoMaxResidentCopiesEnum),
          ) as FontOriginalAssetDtoMaxResidentCopiesEnum;
          result.maxResidentCopies = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontOriginalAssetDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontOriginalAssetDtoBuilder();
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

class FontOriginalAssetDtoFontIdEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'xiaocheng-lafeng')
  static const FontOriginalAssetDtoFontIdEnum xiaochengLafeng = _$fontOriginalAssetDtoFontIdEnum_xiaochengLafeng;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontOriginalAssetDtoFontIdEnum unknownDefaultOpenApi = _$fontOriginalAssetDtoFontIdEnum_unknownDefaultOpenApi;

  static Serializer<FontOriginalAssetDtoFontIdEnum> get serializer => _$fontOriginalAssetDtoFontIdEnumSerializer;

  const FontOriginalAssetDtoFontIdEnum._(String name): super(name);

  static BuiltSet<FontOriginalAssetDtoFontIdEnum> get values => _$fontOriginalAssetDtoFontIdEnumValues;
  static FontOriginalAssetDtoFontIdEnum valueOf(String name) => _$fontOriginalAssetDtoFontIdEnumValueOf(name);
}

class FontOriginalAssetDtoBytesEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'18410600')
  static const FontOriginalAssetDtoBytesEnum n18410600 = _$fontOriginalAssetDtoBytesEnum_n18410600;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontOriginalAssetDtoBytesEnum unknownDefaultOpenApi = _$fontOriginalAssetDtoBytesEnum_unknownDefaultOpenApi;

  static Serializer<FontOriginalAssetDtoBytesEnum> get serializer => _$fontOriginalAssetDtoBytesEnumSerializer;

  const FontOriginalAssetDtoBytesEnum._(String name): super(name);

  static BuiltSet<FontOriginalAssetDtoBytesEnum> get values => _$fontOriginalAssetDtoBytesEnumValues;
  static FontOriginalAssetDtoBytesEnum valueOf(String name) => _$fontOriginalAssetDtoBytesEnumValueOf(name);
}

class FontOriginalAssetDtoMaxResidentCopiesEnum extends EnumClass {

  /// 同一注册域并发预留／驻留原件至多一份，不按时间窗口续增
  @BuiltValueEnumConst(wireName: r'1')
  static const FontOriginalAssetDtoMaxResidentCopiesEnum n1 = _$fontOriginalAssetDtoMaxResidentCopiesEnum_n1;
  /// 同一注册域并发预留／驻留原件至多一份，不按时间窗口续增
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontOriginalAssetDtoMaxResidentCopiesEnum unknownDefaultOpenApi = _$fontOriginalAssetDtoMaxResidentCopiesEnum_unknownDefaultOpenApi;

  static Serializer<FontOriginalAssetDtoMaxResidentCopiesEnum> get serializer => _$fontOriginalAssetDtoMaxResidentCopiesEnumSerializer;

  const FontOriginalAssetDtoMaxResidentCopiesEnum._(String name): super(name);

  static BuiltSet<FontOriginalAssetDtoMaxResidentCopiesEnum> get values => _$fontOriginalAssetDtoMaxResidentCopiesEnumValues;
  static FontOriginalAssetDtoMaxResidentCopiesEnum valueOf(String name) => _$fontOriginalAssetDtoMaxResidentCopiesEnumValueOf(name);
}
