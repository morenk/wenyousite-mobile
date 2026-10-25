//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_publish_dto.g.dart';

/// FontPublishDto
///
/// Properties:
/// * [versionId]
/// * [expectedFamilyRevision]
/// * [expectedCatalogRevision]
@BuiltValue()
abstract class FontPublishDto implements Built<FontPublishDto, FontPublishDtoBuilder> {
  @BuiltValueField(wireName: r'versionId')
  String get versionId;

  @BuiltValueField(wireName: r'expectedFamilyRevision')
  int get expectedFamilyRevision;

  @BuiltValueField(wireName: r'expectedCatalogRevision')
  int get expectedCatalogRevision;

  FontPublishDto._();

  factory FontPublishDto([void updates(FontPublishDtoBuilder b)]) = _$FontPublishDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontPublishDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontPublishDto> get serializer => _$FontPublishDtoSerializer();
}

class _$FontPublishDtoSerializer implements PrimitiveSerializer<FontPublishDto> {
  @override
  final Iterable<Type> types = const [FontPublishDto, _$FontPublishDto];

  @override
  final String wireName = r'FontPublishDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontPublishDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'versionId';
    yield serializers.serialize(
      object.versionId,
      specifiedType: const FullType(String),
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
    FontPublishDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontPublishDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'versionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.versionId = valueDes;
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
  FontPublishDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontPublishDtoBuilder();
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
