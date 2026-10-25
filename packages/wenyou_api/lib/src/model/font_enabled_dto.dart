//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_enabled_dto.g.dart';

/// FontEnabledDto
///
/// Properties:
/// * [enabled]
/// * [expectedFamilyRevision]
/// * [expectedCatalogRevision]
@BuiltValue()
abstract class FontEnabledDto implements Built<FontEnabledDto, FontEnabledDtoBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'expectedFamilyRevision')
  int get expectedFamilyRevision;

  @BuiltValueField(wireName: r'expectedCatalogRevision')
  int get expectedCatalogRevision;

  FontEnabledDto._();

  factory FontEnabledDto([void updates(FontEnabledDtoBuilder b)]) = _$FontEnabledDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontEnabledDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontEnabledDto> get serializer => _$FontEnabledDtoSerializer();
}

class _$FontEnabledDtoSerializer implements PrimitiveSerializer<FontEnabledDto> {
  @override
  final Iterable<Type> types = const [FontEnabledDto, _$FontEnabledDto];

  @override
  final String wireName = r'FontEnabledDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontEnabledDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    yield r'expectedFamilyRevision';
    yield serializers.serialize(
      object.expectedFamilyRevision,
      specifiedType: const FullType(int),
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
    FontEnabledDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontEnabledDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'expectedFamilyRevision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expectedFamilyRevision = valueDes;
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
  FontEnabledDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontEnabledDtoBuilder();
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
