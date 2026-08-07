//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'import_sticker_media_dto.g.dart';

/// ImportStickerMediaDto
///
/// Properties:
/// * [mediaId] - 已处理完成、且属于当前用户的媒体 ID
/// * [clientRequestId] - 导入幂等键
@BuiltValue()
abstract class ImportStickerMediaDto implements Built<ImportStickerMediaDto, ImportStickerMediaDtoBuilder> {
  /// 已处理完成、且属于当前用户的媒体 ID
  @BuiltValueField(wireName: r'mediaId')
  String get mediaId;

  /// 导入幂等键
  @BuiltValueField(wireName: r'clientRequestId')
  String get clientRequestId;

  ImportStickerMediaDto._();

  factory ImportStickerMediaDto([void updates(ImportStickerMediaDtoBuilder b)]) = _$ImportStickerMediaDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ImportStickerMediaDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ImportStickerMediaDto> get serializer => _$ImportStickerMediaDtoSerializer();
}

class _$ImportStickerMediaDtoSerializer implements PrimitiveSerializer<ImportStickerMediaDto> {
  @override
  final Iterable<Type> types = const [ImportStickerMediaDto, _$ImportStickerMediaDto];

  @override
  final String wireName = r'ImportStickerMediaDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ImportStickerMediaDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mediaId';
    yield serializers.serialize(
      object.mediaId,
      specifiedType: const FullType(String),
    );
    yield r'clientRequestId';
    yield serializers.serialize(
      object.clientRequestId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ImportStickerMediaDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ImportStickerMediaDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mediaId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaId = valueDes;
          break;
        case r'clientRequestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientRequestId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ImportStickerMediaDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ImportStickerMediaDtoBuilder();
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
