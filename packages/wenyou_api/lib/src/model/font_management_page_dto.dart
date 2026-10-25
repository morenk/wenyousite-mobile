//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_management_item_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_management_page_dto.g.dart';

/// FontManagementPageDto
///
/// Properties:
/// * [items]
/// * [total] - 先对全量家族筛选，再计算匹配数量。
/// * [listingRevision]
/// * [catalogRevision]
/// * [nextCursor]
@BuiltValue()
abstract class FontManagementPageDto implements Built<FontManagementPageDto, FontManagementPageDtoBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<FontManagementItemDto> get items;

  /// 先对全量家族筛选，再计算匹配数量。
  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'listingRevision')
  int get listingRevision;

  @BuiltValueField(wireName: r'catalogRevision')
  int get catalogRevision;

  @BuiltValueField(wireName: r'nextCursor')
  String? get nextCursor;

  FontManagementPageDto._();

  factory FontManagementPageDto([void updates(FontManagementPageDtoBuilder b)]) = _$FontManagementPageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontManagementPageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontManagementPageDto> get serializer => _$FontManagementPageDtoSerializer();
}

class _$FontManagementPageDtoSerializer implements PrimitiveSerializer<FontManagementPageDto> {
  @override
  final Iterable<Type> types = const [FontManagementPageDto, _$FontManagementPageDto];

  @override
  final String wireName = r'FontManagementPageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontManagementPageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(FontManagementItemDto)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'listingRevision';
    yield serializers.serialize(
      object.listingRevision,
      specifiedType: const FullType(int),
    );
    yield r'catalogRevision';
    yield serializers.serialize(
      object.catalogRevision,
      specifiedType: const FullType(int),
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
    FontManagementPageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontManagementPageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FontManagementItemDto)]),
          ) as BuiltList<FontManagementItemDto>;
          result.items.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        case r'listingRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.listingRevision = valueDes;
          break;
        case r'catalogRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.catalogRevision = valueDes;
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
  FontManagementPageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontManagementPageDtoBuilder();
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
