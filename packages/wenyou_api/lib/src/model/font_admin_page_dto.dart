//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/font_family_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_admin_page_dto.g.dart';

/// FontAdminPageDto
///
/// Properties:
/// * [items]
/// * [nextAfter]
@BuiltValue()
abstract class FontAdminPageDto implements Built<FontAdminPageDto, FontAdminPageDtoBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<FontFamilyDto> get items;

  @BuiltValueField(wireName: r'nextAfter')
  String? get nextAfter;

  FontAdminPageDto._();

  factory FontAdminPageDto([void updates(FontAdminPageDtoBuilder b)]) = _$FontAdminPageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontAdminPageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontAdminPageDto> get serializer => _$FontAdminPageDtoSerializer();
}

class _$FontAdminPageDtoSerializer implements PrimitiveSerializer<FontAdminPageDto> {
  @override
  final Iterable<Type> types = const [FontAdminPageDto, _$FontAdminPageDto];

  @override
  final String wireName = r'FontAdminPageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontAdminPageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(FontFamilyDto)]),
    );
    yield r'nextAfter';
    yield object.nextAfter == null ? null : serializers.serialize(
      object.nextAfter,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontAdminPageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontAdminPageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FontFamilyDto)]),
          ) as BuiltList<FontFamilyDto>;
          result.items.replace(valueDes);
          break;
        case r'nextAfter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextAfter = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontAdminPageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontAdminPageDtoBuilder();
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
