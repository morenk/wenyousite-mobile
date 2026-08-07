//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bookmark_thread_count_response_dto.g.dart';

/// BookmarkThreadCountResponseDto
///
/// Properties:
/// * [members]
/// * [posts]
@BuiltValue()
abstract class BookmarkThreadCountResponseDto implements Built<BookmarkThreadCountResponseDto, BookmarkThreadCountResponseDtoBuilder> {
  @BuiltValueField(wireName: r'members')
  num get members;

  @BuiltValueField(wireName: r'posts')
  num get posts;

  BookmarkThreadCountResponseDto._();

  factory BookmarkThreadCountResponseDto([void updates(BookmarkThreadCountResponseDtoBuilder b)]) = _$BookmarkThreadCountResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BookmarkThreadCountResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BookmarkThreadCountResponseDto> get serializer => _$BookmarkThreadCountResponseDtoSerializer();
}

class _$BookmarkThreadCountResponseDtoSerializer implements PrimitiveSerializer<BookmarkThreadCountResponseDto> {
  @override
  final Iterable<Type> types = const [BookmarkThreadCountResponseDto, _$BookmarkThreadCountResponseDto];

  @override
  final String wireName = r'BookmarkThreadCountResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BookmarkThreadCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'members';
    yield serializers.serialize(
      object.members,
      specifiedType: const FullType(num),
    );
    yield r'posts';
    yield serializers.serialize(
      object.posts,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BookmarkThreadCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BookmarkThreadCountResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'members':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.members = valueDes;
          break;
        case r'posts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.posts = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BookmarkThreadCountResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BookmarkThreadCountResponseDtoBuilder();
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
