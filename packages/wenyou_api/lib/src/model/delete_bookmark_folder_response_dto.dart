//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_bookmark_folder_response_dto.g.dart';

/// DeleteBookmarkFolderResponseDto
///
/// Properties:
/// * [deletedFolderId] - 已删除的自定义收藏夹 ID
/// * [destinationFolderId] - 接收全部收藏的同类型默认收藏夹 ID
@BuiltValue()
abstract class DeleteBookmarkFolderResponseDto implements Built<DeleteBookmarkFolderResponseDto, DeleteBookmarkFolderResponseDtoBuilder> {
  /// 已删除的自定义收藏夹 ID
  @BuiltValueField(wireName: r'deletedFolderId')
  String get deletedFolderId;

  /// 接收全部收藏的同类型默认收藏夹 ID
  @BuiltValueField(wireName: r'destinationFolderId')
  String get destinationFolderId;

  DeleteBookmarkFolderResponseDto._();

  factory DeleteBookmarkFolderResponseDto([void updates(DeleteBookmarkFolderResponseDtoBuilder b)]) = _$DeleteBookmarkFolderResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeleteBookmarkFolderResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteBookmarkFolderResponseDto> get serializer => _$DeleteBookmarkFolderResponseDtoSerializer();
}

class _$DeleteBookmarkFolderResponseDtoSerializer implements PrimitiveSerializer<DeleteBookmarkFolderResponseDto> {
  @override
  final Iterable<Type> types = const [DeleteBookmarkFolderResponseDto, _$DeleteBookmarkFolderResponseDto];

  @override
  final String wireName = r'DeleteBookmarkFolderResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteBookmarkFolderResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'deletedFolderId';
    yield serializers.serialize(
      object.deletedFolderId,
      specifiedType: const FullType(String),
    );
    yield r'destinationFolderId';
    yield serializers.serialize(
      object.destinationFolderId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeleteBookmarkFolderResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeleteBookmarkFolderResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'deletedFolderId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deletedFolderId = valueDes;
          break;
        case r'destinationFolderId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.destinationFolderId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeleteBookmarkFolderResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeleteBookmarkFolderResponseDtoBuilder();
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
