//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'text_font_manifest_dto.g.dart';

/// TextFontManifestDto
///
/// Properties:
/// * [path] - 相对于 assetBaseUrl 的不可变路径；不得解释为任意外链
/// * [sha256]
/// * [bytes]
@BuiltValue()
abstract class TextFontManifestDto implements Built<TextFontManifestDto, TextFontManifestDtoBuilder> {
  /// 相对于 assetBaseUrl 的不可变路径；不得解释为任意外链
  @BuiltValueField(wireName: r'path')
  String get path;

  @BuiltValueField(wireName: r'sha256')
  String get sha256;

  @BuiltValueField(wireName: r'bytes')
  int get bytes;

  TextFontManifestDto._();

  factory TextFontManifestDto([void updates(TextFontManifestDtoBuilder b)]) = _$TextFontManifestDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TextFontManifestDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TextFontManifestDto> get serializer => _$TextFontManifestDtoSerializer();
}

class _$TextFontManifestDtoSerializer implements PrimitiveSerializer<TextFontManifestDto> {
  @override
  final Iterable<Type> types = const [TextFontManifestDto, _$TextFontManifestDto];

  @override
  final String wireName = r'TextFontManifestDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TextFontManifestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'path';
    yield serializers.serialize(
      object.path,
      specifiedType: const FullType(String),
    );
    yield r'sha256';
    yield serializers.serialize(
      object.sha256,
      specifiedType: const FullType(String),
    );
    yield r'bytes';
    yield serializers.serialize(
      object.bytes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TextFontManifestDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TextFontManifestDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.path = valueDes;
          break;
        case r'sha256':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sha256 = valueDes;
          break;
        case r'bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TextFontManifestDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TextFontManifestDtoBuilder();
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
