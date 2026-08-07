//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/search_author_response_dto.dart';
import 'package:wenyou_api/src/model/search_subthread_reference_response_dto.dart';
import 'package:wenyou_api/src/model/search_thread_reference_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_post_response_dto.g.dart';

/// SearchPostResponseDto
///
/// Properties:
/// * [id] - 帖子 ID
/// * [floorNumber] - 楼层号；楼中楼为 null
/// * [parentPostId] - 父楼层 ID；主楼层为 null
/// * [content] - Markdown 正文
/// * [createdAt] - 创建时间
/// * [author] - 作者信息
/// * [thread] - 所属主题帖
/// * [subthread] - 所属子贴
@BuiltValue()
abstract class SearchPostResponseDto implements Built<SearchPostResponseDto, SearchPostResponseDtoBuilder> {
  /// 帖子 ID
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 楼层号；楼中楼为 null
  @BuiltValueField(wireName: r'floorNumber')
  num? get floorNumber;

  /// 父楼层 ID；主楼层为 null
  @BuiltValueField(wireName: r'parentPostId')
  String? get parentPostId;

  /// Markdown 正文
  @BuiltValueField(wireName: r'content')
  String get content;

  /// 创建时间
  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  /// 作者信息
  @BuiltValueField(wireName: r'author')
  SearchAuthorResponseDto get author;

  /// 所属主题帖
  @BuiltValueField(wireName: r'thread')
  SearchThreadReferenceResponseDto get thread;

  /// 所属子贴
  @BuiltValueField(wireName: r'subthread')
  SearchSubthreadReferenceResponseDto get subthread;

  SearchPostResponseDto._();

  factory SearchPostResponseDto([void updates(SearchPostResponseDtoBuilder b)]) = _$SearchPostResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchPostResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchPostResponseDto> get serializer => _$SearchPostResponseDtoSerializer();
}

class _$SearchPostResponseDtoSerializer implements PrimitiveSerializer<SearchPostResponseDto> {
  @override
  final Iterable<Type> types = const [SearchPostResponseDto, _$SearchPostResponseDto];

  @override
  final String wireName = r'SearchPostResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchPostResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'floorNumber';
    yield object.floorNumber == null ? null : serializers.serialize(
      object.floorNumber,
      specifiedType: const FullType.nullable(num),
    );
    yield r'parentPostId';
    yield object.parentPostId == null ? null : serializers.serialize(
      object.parentPostId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'author';
    yield serializers.serialize(
      object.author,
      specifiedType: const FullType(SearchAuthorResponseDto),
    );
    yield r'thread';
    yield serializers.serialize(
      object.thread,
      specifiedType: const FullType(SearchThreadReferenceResponseDto),
    );
    yield r'subthread';
    yield serializers.serialize(
      object.subthread,
      specifiedType: const FullType(SearchSubthreadReferenceResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchPostResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchPostResponseDtoBuilder result,
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
        case r'floorNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.floorNumber = valueDes;
          break;
        case r'parentPostId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentPostId = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'author':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SearchAuthorResponseDto),
          ) as SearchAuthorResponseDto;
          result.author.replace(valueDes);
          break;
        case r'thread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SearchThreadReferenceResponseDto),
          ) as SearchThreadReferenceResponseDto;
          result.thread.replace(valueDes);
          break;
        case r'subthread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SearchSubthreadReferenceResponseDto),
          ) as SearchSubthreadReferenceResponseDto;
          result.subthread.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchPostResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchPostResponseDtoBuilder();
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
