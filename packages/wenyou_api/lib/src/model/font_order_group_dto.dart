//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_order_item_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_order_group_dto.g.dart';

/// FontOrderGroupDto
///
/// Properties:
/// * [language] - 当前已发布版本的语言，与公开目录一致。
/// * [items] - 此语言全部当前可选家族，数组顺序为最终展示顺序；不能只提交当前分页或搜索结果。
@BuiltValue()
abstract class FontOrderGroupDto implements Built<FontOrderGroupDto, FontOrderGroupDtoBuilder> {
  /// 当前已发布版本的语言，与公开目录一致。
  @BuiltValueField(wireName: r'language')
  FontOrderGroupDtoLanguageEnum get language;
  // enum languageEnum {  zh,  ja,  en,  other,  };

  /// 此语言全部当前可选家族，数组顺序为最终展示顺序；不能只提交当前分页或搜索结果。
  @BuiltValueField(wireName: r'items')
  BuiltList<FontOrderItemDto> get items;

  FontOrderGroupDto._();

  factory FontOrderGroupDto([void updates(FontOrderGroupDtoBuilder b)]) = _$FontOrderGroupDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontOrderGroupDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontOrderGroupDto> get serializer => _$FontOrderGroupDtoSerializer();
}

class _$FontOrderGroupDtoSerializer implements PrimitiveSerializer<FontOrderGroupDto> {
  @override
  final Iterable<Type> types = const [FontOrderGroupDto, _$FontOrderGroupDto];

  @override
  final String wireName = r'FontOrderGroupDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontOrderGroupDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'language';
    yield serializers.serialize(
      object.language,
      specifiedType: const FullType(FontOrderGroupDtoLanguageEnum),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(FontOrderItemDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontOrderGroupDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontOrderGroupDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'language':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontOrderGroupDtoLanguageEnum),
          ) as FontOrderGroupDtoLanguageEnum;
          result.language = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FontOrderItemDto)]),
          ) as BuiltList<FontOrderItemDto>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontOrderGroupDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontOrderGroupDtoBuilder();
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

class FontOrderGroupDtoLanguageEnum extends EnumClass {

  /// 当前已发布版本的语言，与公开目录一致。
  @BuiltValueEnumConst(wireName: r'zh')
  static const FontOrderGroupDtoLanguageEnum zh = _$fontOrderGroupDtoLanguageEnum_zh;
  /// 当前已发布版本的语言，与公开目录一致。
  @BuiltValueEnumConst(wireName: r'ja')
  static const FontOrderGroupDtoLanguageEnum ja = _$fontOrderGroupDtoLanguageEnum_ja;
  /// 当前已发布版本的语言，与公开目录一致。
  @BuiltValueEnumConst(wireName: r'en')
  static const FontOrderGroupDtoLanguageEnum en = _$fontOrderGroupDtoLanguageEnum_en;
  /// 当前已发布版本的语言，与公开目录一致。
  @BuiltValueEnumConst(wireName: r'other')
  static const FontOrderGroupDtoLanguageEnum other = _$fontOrderGroupDtoLanguageEnum_other;
  /// 当前已发布版本的语言，与公开目录一致。
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontOrderGroupDtoLanguageEnum unknownDefaultOpenApi = _$fontOrderGroupDtoLanguageEnum_unknownDefaultOpenApi;

  static Serializer<FontOrderGroupDtoLanguageEnum> get serializer => _$fontOrderGroupDtoLanguageEnumSerializer;

  const FontOrderGroupDtoLanguageEnum._(String name): super(name);

  static BuiltSet<FontOrderGroupDtoLanguageEnum> get values => _$fontOrderGroupDtoLanguageEnumValues;
  static FontOrderGroupDtoLanguageEnum valueOf(String name) => _$fontOrderGroupDtoLanguageEnumValueOf(name);
}
