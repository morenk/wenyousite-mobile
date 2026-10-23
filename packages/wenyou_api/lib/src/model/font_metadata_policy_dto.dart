//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_metadata_policy_dto.g.dart';

/// FontMetadataPolicyDto
///
/// Properties:
/// * [revalidateAfterMs]
/// * [negativeCacheMs]
/// * [reservationBytes]
/// * [revalidateOnForeground]
/// * [revalidateOnPickerOpen]
/// * [coalesceUnknownVersions]
@BuiltValue()
abstract class FontMetadataPolicyDto implements Built<FontMetadataPolicyDto, FontMetadataPolicyDtoBuilder> {
  @BuiltValueField(wireName: r'revalidateAfterMs')
  FontMetadataPolicyDtoRevalidateAfterMsEnum get revalidateAfterMs;
  // enum revalidateAfterMsEnum {  300000,  };

  @BuiltValueField(wireName: r'negativeCacheMs')
  FontMetadataPolicyDtoNegativeCacheMsEnum get negativeCacheMs;
  // enum negativeCacheMsEnum {  30000,  };

  @BuiltValueField(wireName: r'reservationBytes')
  FontMetadataPolicyDtoReservationBytesEnum get reservationBytes;
  // enum reservationBytesEnum {  65536,  };

  @BuiltValueField(wireName: r'revalidateOnForeground')
  bool get revalidateOnForeground;

  @BuiltValueField(wireName: r'revalidateOnPickerOpen')
  bool get revalidateOnPickerOpen;

  @BuiltValueField(wireName: r'coalesceUnknownVersions')
  bool get coalesceUnknownVersions;

  FontMetadataPolicyDto._();

  factory FontMetadataPolicyDto([void updates(FontMetadataPolicyDtoBuilder b)]) = _$FontMetadataPolicyDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontMetadataPolicyDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontMetadataPolicyDto> get serializer => _$FontMetadataPolicyDtoSerializer();
}

class _$FontMetadataPolicyDtoSerializer implements PrimitiveSerializer<FontMetadataPolicyDto> {
  @override
  final Iterable<Type> types = const [FontMetadataPolicyDto, _$FontMetadataPolicyDto];

  @override
  final String wireName = r'FontMetadataPolicyDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontMetadataPolicyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'revalidateAfterMs';
    yield serializers.serialize(
      object.revalidateAfterMs,
      specifiedType: const FullType(FontMetadataPolicyDtoRevalidateAfterMsEnum),
    );
    yield r'negativeCacheMs';
    yield serializers.serialize(
      object.negativeCacheMs,
      specifiedType: const FullType(FontMetadataPolicyDtoNegativeCacheMsEnum),
    );
    yield r'reservationBytes';
    yield serializers.serialize(
      object.reservationBytes,
      specifiedType: const FullType(FontMetadataPolicyDtoReservationBytesEnum),
    );
    yield r'revalidateOnForeground';
    yield serializers.serialize(
      object.revalidateOnForeground,
      specifiedType: const FullType(bool),
    );
    yield r'revalidateOnPickerOpen';
    yield serializers.serialize(
      object.revalidateOnPickerOpen,
      specifiedType: const FullType(bool),
    );
    yield r'coalesceUnknownVersions';
    yield serializers.serialize(
      object.coalesceUnknownVersions,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontMetadataPolicyDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontMetadataPolicyDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'revalidateAfterMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontMetadataPolicyDtoRevalidateAfterMsEnum),
          ) as FontMetadataPolicyDtoRevalidateAfterMsEnum;
          result.revalidateAfterMs = valueDes;
          break;
        case r'negativeCacheMs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontMetadataPolicyDtoNegativeCacheMsEnum),
          ) as FontMetadataPolicyDtoNegativeCacheMsEnum;
          result.negativeCacheMs = valueDes;
          break;
        case r'reservationBytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontMetadataPolicyDtoReservationBytesEnum),
          ) as FontMetadataPolicyDtoReservationBytesEnum;
          result.reservationBytes = valueDes;
          break;
        case r'revalidateOnForeground':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.revalidateOnForeground = valueDes;
          break;
        case r'revalidateOnPickerOpen':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.revalidateOnPickerOpen = valueDes;
          break;
        case r'coalesceUnknownVersions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.coalesceUnknownVersions = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontMetadataPolicyDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontMetadataPolicyDtoBuilder();
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

class FontMetadataPolicyDtoRevalidateAfterMsEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'300000')
  static const FontMetadataPolicyDtoRevalidateAfterMsEnum n300000 = _$fontMetadataPolicyDtoRevalidateAfterMsEnum_n300000;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontMetadataPolicyDtoRevalidateAfterMsEnum unknownDefaultOpenApi = _$fontMetadataPolicyDtoRevalidateAfterMsEnum_unknownDefaultOpenApi;

  static Serializer<FontMetadataPolicyDtoRevalidateAfterMsEnum> get serializer => _$fontMetadataPolicyDtoRevalidateAfterMsEnumSerializer;

  const FontMetadataPolicyDtoRevalidateAfterMsEnum._(String name): super(name);

  static BuiltSet<FontMetadataPolicyDtoRevalidateAfterMsEnum> get values => _$fontMetadataPolicyDtoRevalidateAfterMsEnumValues;
  static FontMetadataPolicyDtoRevalidateAfterMsEnum valueOf(String name) => _$fontMetadataPolicyDtoRevalidateAfterMsEnumValueOf(name);
}

class FontMetadataPolicyDtoNegativeCacheMsEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'30000')
  static const FontMetadataPolicyDtoNegativeCacheMsEnum n30000 = _$fontMetadataPolicyDtoNegativeCacheMsEnum_n30000;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontMetadataPolicyDtoNegativeCacheMsEnum unknownDefaultOpenApi = _$fontMetadataPolicyDtoNegativeCacheMsEnum_unknownDefaultOpenApi;

  static Serializer<FontMetadataPolicyDtoNegativeCacheMsEnum> get serializer => _$fontMetadataPolicyDtoNegativeCacheMsEnumSerializer;

  const FontMetadataPolicyDtoNegativeCacheMsEnum._(String name): super(name);

  static BuiltSet<FontMetadataPolicyDtoNegativeCacheMsEnum> get values => _$fontMetadataPolicyDtoNegativeCacheMsEnumValues;
  static FontMetadataPolicyDtoNegativeCacheMsEnum valueOf(String name) => _$fontMetadataPolicyDtoNegativeCacheMsEnumValueOf(name);
}

class FontMetadataPolicyDtoReservationBytesEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'65536')
  static const FontMetadataPolicyDtoReservationBytesEnum n65536 = _$fontMetadataPolicyDtoReservationBytesEnum_n65536;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const FontMetadataPolicyDtoReservationBytesEnum unknownDefaultOpenApi = _$fontMetadataPolicyDtoReservationBytesEnum_unknownDefaultOpenApi;

  static Serializer<FontMetadataPolicyDtoReservationBytesEnum> get serializer => _$fontMetadataPolicyDtoReservationBytesEnumSerializer;

  const FontMetadataPolicyDtoReservationBytesEnum._(String name): super(name);

  static BuiltSet<FontMetadataPolicyDtoReservationBytesEnum> get values => _$fontMetadataPolicyDtoReservationBytesEnumValues;
  static FontMetadataPolicyDtoReservationBytesEnum valueOf(String name) => _$fontMetadataPolicyDtoReservationBytesEnumValueOf(name);
}
