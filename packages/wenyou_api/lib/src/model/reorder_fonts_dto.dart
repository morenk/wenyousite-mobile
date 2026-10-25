//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/font_order_group_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reorder_fonts_dto.g.dart';

/// ReorderFontsDto
///
/// Properties:
/// * [groups] - 本次变更的语言组，语言不得重复；所有组一次事务提交。
/// * [expectedCatalogRevision]
@BuiltValue()
abstract class ReorderFontsDto implements Built<ReorderFontsDto, ReorderFontsDtoBuilder> {
  /// 本次变更的语言组，语言不得重复；所有组一次事务提交。
  @BuiltValueField(wireName: r'groups')
  BuiltList<FontOrderGroupDto> get groups;

  @BuiltValueField(wireName: r'expectedCatalogRevision')
  int get expectedCatalogRevision;

  ReorderFontsDto._();

  factory ReorderFontsDto([void updates(ReorderFontsDtoBuilder b)]) = _$ReorderFontsDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReorderFontsDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReorderFontsDto> get serializer => _$ReorderFontsDtoSerializer();
}

class _$ReorderFontsDtoSerializer implements PrimitiveSerializer<ReorderFontsDto> {
  @override
  final Iterable<Type> types = const [ReorderFontsDto, _$ReorderFontsDto];

  @override
  final String wireName = r'ReorderFontsDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReorderFontsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'groups';
    yield serializers.serialize(
      object.groups,
      specifiedType: const FullType(BuiltList, [FullType(FontOrderGroupDto)]),
    );
    yield r'expectedCatalogRevision';
    yield serializers.serialize(
      object.expectedCatalogRevision,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReorderFontsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReorderFontsDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'groups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FontOrderGroupDto)]),
          ) as BuiltList<FontOrderGroupDto>;
          result.groups.replace(valueDes);
          break;
        case r'expectedCatalogRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expectedCatalogRevision = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReorderFontsDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReorderFontsDtoBuilder();
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
