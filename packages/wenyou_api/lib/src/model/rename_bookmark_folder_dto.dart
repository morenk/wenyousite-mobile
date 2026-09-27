//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rename_bookmark_folder_dto.g.dart';

/// RenameBookmarkFolderDto
///
/// Properties:
/// * [name] - trim 后为 1–24 个字符；仅可重命名自定义收藏夹
@BuiltValue()
abstract class RenameBookmarkFolderDto implements Built<RenameBookmarkFolderDto, RenameBookmarkFolderDtoBuilder> {
  /// trim 后为 1–24 个字符；仅可重命名自定义收藏夹
  @BuiltValueField(wireName: r'name')
  String get name;

  RenameBookmarkFolderDto._();

  factory RenameBookmarkFolderDto([void updates(RenameBookmarkFolderDtoBuilder b)]) = _$RenameBookmarkFolderDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RenameBookmarkFolderDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RenameBookmarkFolderDto> get serializer => _$RenameBookmarkFolderDtoSerializer();
}

class _$RenameBookmarkFolderDtoSerializer implements PrimitiveSerializer<RenameBookmarkFolderDto> {
  @override
  final Iterable<Type> types = const [RenameBookmarkFolderDto, _$RenameBookmarkFolderDto];

  @override
  final String wireName = r'RenameBookmarkFolderDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RenameBookmarkFolderDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RenameBookmarkFolderDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RenameBookmarkFolderDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RenameBookmarkFolderDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RenameBookmarkFolderDtoBuilder();
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
