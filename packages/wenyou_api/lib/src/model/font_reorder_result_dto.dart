//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_reorder_result_dto.g.dart';

/// FontReorderResultDto
///
/// Properties:
/// * [catalogRevision]
/// * [listingRevision]
/// * [changed] - 顺序未变为 false，不产生修订或审计；有变化后客户端刷新列表。
@BuiltValue()
abstract class FontReorderResultDto implements Built<FontReorderResultDto, FontReorderResultDtoBuilder> {
  @BuiltValueField(wireName: r'catalogRevision')
  int get catalogRevision;

  @BuiltValueField(wireName: r'listingRevision')
  int get listingRevision;

  /// 顺序未变为 false，不产生修订或审计；有变化后客户端刷新列表。
  @BuiltValueField(wireName: r'changed')
  bool get changed;

  FontReorderResultDto._();

  factory FontReorderResultDto([void updates(FontReorderResultDtoBuilder b)]) = _$FontReorderResultDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontReorderResultDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontReorderResultDto> get serializer => _$FontReorderResultDtoSerializer();
}

class _$FontReorderResultDtoSerializer implements PrimitiveSerializer<FontReorderResultDto> {
  @override
  final Iterable<Type> types = const [FontReorderResultDto, _$FontReorderResultDto];

  @override
  final String wireName = r'FontReorderResultDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontReorderResultDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'catalogRevision';
    yield serializers.serialize(
      object.catalogRevision,
      specifiedType: const FullType(int),
    );
    yield r'listingRevision';
    yield serializers.serialize(
      object.listingRevision,
      specifiedType: const FullType(int),
    );
    yield r'changed';
    yield serializers.serialize(
      object.changed,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontReorderResultDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontReorderResultDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'catalogRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.catalogRevision = valueDes;
          break;
        case r'listingRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.listingRevision = valueDes;
          break;
        case r'changed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.changed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontReorderResultDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontReorderResultDtoBuilder();
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
