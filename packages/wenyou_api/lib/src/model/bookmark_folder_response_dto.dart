//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bookmark_folder_response_dto.g.dart';

/// BookmarkFolderResponseDto
///
/// Properties:
/// * [id]
/// * [name]
/// * [isDefault]
/// * [bookmarkCount]
/// * [momentBookmarkCount] - 该收藏夹中的动态收藏数量
/// * [createdAt]
@BuiltValue()
abstract class BookmarkFolderResponseDto implements Built<BookmarkFolderResponseDto, BookmarkFolderResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'isDefault')
  bool get isDefault;

  @BuiltValueField(wireName: r'bookmarkCount')
  num get bookmarkCount;

  /// 该收藏夹中的动态收藏数量
  @BuiltValueField(wireName: r'momentBookmarkCount')
  num get momentBookmarkCount;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  BookmarkFolderResponseDto._();

  factory BookmarkFolderResponseDto([void updates(BookmarkFolderResponseDtoBuilder b)]) = _$BookmarkFolderResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BookmarkFolderResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BookmarkFolderResponseDto> get serializer => _$BookmarkFolderResponseDtoSerializer();
}

class _$BookmarkFolderResponseDtoSerializer implements PrimitiveSerializer<BookmarkFolderResponseDto> {
  @override
  final Iterable<Type> types = const [BookmarkFolderResponseDto, _$BookmarkFolderResponseDto];

  @override
  final String wireName = r'BookmarkFolderResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BookmarkFolderResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'isDefault';
    yield serializers.serialize(
      object.isDefault,
      specifiedType: const FullType(bool),
    );
    yield r'bookmarkCount';
    yield serializers.serialize(
      object.bookmarkCount,
      specifiedType: const FullType(num),
    );
    yield r'momentBookmarkCount';
    yield serializers.serialize(
      object.momentBookmarkCount,
      specifiedType: const FullType(num),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BookmarkFolderResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BookmarkFolderResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'isDefault':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDefault = valueDes;
          break;
        case r'bookmarkCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.bookmarkCount = valueDes;
          break;
        case r'momentBookmarkCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.momentBookmarkCount = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BookmarkFolderResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BookmarkFolderResponseDtoBuilder();
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
