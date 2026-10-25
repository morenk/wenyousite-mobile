//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_rights_dto.g.dart';

/// FontRightsDto
///
/// Properties:
/// * [redistribution]
/// * [conversion]
/// * [subsetting]
@BuiltValue()
abstract class FontRightsDto implements Built<FontRightsDto, FontRightsDtoBuilder> {
  @BuiltValueField(wireName: r'redistribution')
  bool get redistribution;

  @BuiltValueField(wireName: r'conversion')
  bool get conversion;

  @BuiltValueField(wireName: r'subsetting')
  bool get subsetting;

  FontRightsDto._();

  factory FontRightsDto([void updates(FontRightsDtoBuilder b)]) = _$FontRightsDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontRightsDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontRightsDto> get serializer => _$FontRightsDtoSerializer();
}

class _$FontRightsDtoSerializer implements PrimitiveSerializer<FontRightsDto> {
  @override
  final Iterable<Type> types = const [FontRightsDto, _$FontRightsDto];

  @override
  final String wireName = r'FontRightsDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontRightsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'redistribution';
    yield serializers.serialize(
      object.redistribution,
      specifiedType: const FullType(bool),
    );
    yield r'conversion';
    yield serializers.serialize(
      object.conversion,
      specifiedType: const FullType(bool),
    );
    yield r'subsetting';
    yield serializers.serialize(
      object.subsetting,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontRightsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontRightsDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'redistribution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.redistribution = valueDes;
          break;
        case r'conversion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.conversion = valueDes;
          break;
        case r'subsetting':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.subsetting = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontRightsDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontRightsDtoBuilder();
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
