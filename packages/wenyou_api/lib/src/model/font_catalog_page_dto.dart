//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_catalog_entry_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_catalog_page_dto.g.dart';

/// FontCatalogPageDto
///
/// Properties:
/// * [fontVersion]
/// * [releaseId]
/// * [revision]
/// * [items]
/// * [nextCursor]
@BuiltValue()
abstract class FontCatalogPageDto implements Built<FontCatalogPageDto, FontCatalogPageDtoBuilder> {
  @BuiltValueField(wireName: r'fontVersion')
  FontCatalogPageDtoFontVersionEnum get fontVersion;
  // enum fontVersionEnum {  2,  };

  @BuiltValueField(wireName: r'releaseId')
  String get releaseId;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'items')
  BuiltList<FontCatalogEntryDto> get items;

  @BuiltValueField(wireName: r'nextCursor')
  String? get nextCursor;

  FontCatalogPageDto._();

  factory FontCatalogPageDto([void updates(FontCatalogPageDtoBuilder b)]) = _$FontCatalogPageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontCatalogPageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontCatalogPageDto> get serializer => _$FontCatalogPageDtoSerializer();
}

class _$FontCatalogPageDtoSerializer implements PrimitiveSerializer<FontCatalogPageDto> {
  @override
  final Iterable<Type> types = const [FontCatalogPageDto, _$FontCatalogPageDto];

  @override
  final String wireName = r'FontCatalogPageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontCatalogPageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fontVersion';
    yield serializers.serialize(
      object.fontVersion,
      specifiedType: const FullType(FontCatalogPageDtoFontVersionEnum),
    );
    yield r'releaseId';
    yield serializers.serialize(
      object.releaseId,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(FontCatalogEntryDto)]),
    );
    yield r'nextCursor';
    yield object.nextCursor == null ? null : serializers.serialize(
      object.nextCursor,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontCatalogPageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontCatalogPageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fontVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontCatalogPageDtoFontVersionEnum),
          ) as FontCatalogPageDtoFontVersionEnum;
          result.fontVersion = valueDes;
          break;
        case r'releaseId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.releaseId = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FontCatalogEntryDto)]),
          ) as BuiltList<FontCatalogEntryDto>;
          result.items.replace(valueDes);
          break;
        case r'nextCursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontCatalogPageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontCatalogPageDtoBuilder();
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

class FontCatalogPageDtoFontVersionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'2')
  static const FontCatalogPageDtoFontVersionEnum n2 = _$fontCatalogPageDtoFontVersionEnum_n2;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontCatalogPageDtoFontVersionEnum unknownDefaultOpenApi = _$fontCatalogPageDtoFontVersionEnum_unknownDefaultOpenApi;

  static Serializer<FontCatalogPageDtoFontVersionEnum> get serializer => _$fontCatalogPageDtoFontVersionEnumSerializer;

  const FontCatalogPageDtoFontVersionEnum._(String name): super(name);

  static BuiltSet<FontCatalogPageDtoFontVersionEnum> get values => _$fontCatalogPageDtoFontVersionEnumValues;
  static FontCatalogPageDtoFontVersionEnum valueOf(String name) => _$fontCatalogPageDtoFontVersionEnumValueOf(name);
}
