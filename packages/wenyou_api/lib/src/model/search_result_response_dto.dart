//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/search_user_response_dto.dart';
import 'package:wenyou_api/src/model/search_thread_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/search_post_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_result_response_dto.g.dart';

/// SearchResultResponseDto
///
/// Properties:
/// * [users] - 用户名匹配结果，最多 20 条
/// * [threads] - 公开主题帖标题匹配结果，最多 50 条
/// * [posts] - 公开楼层正文兼容匹配结果，最多 20 条
@BuiltValue()
abstract class SearchResultResponseDto implements Built<SearchResultResponseDto, SearchResultResponseDtoBuilder> {
  /// 用户名匹配结果，最多 20 条
  @BuiltValueField(wireName: r'users')
  BuiltList<SearchUserResponseDto> get users;

  /// 公开主题帖标题匹配结果，最多 50 条
  @BuiltValueField(wireName: r'threads')
  BuiltList<SearchThreadResponseDto> get threads;

  /// 公开楼层正文兼容匹配结果，最多 20 条
  @BuiltValueField(wireName: r'posts')
  BuiltList<SearchPostResponseDto> get posts;

  SearchResultResponseDto._();

  factory SearchResultResponseDto([void updates(SearchResultResponseDtoBuilder b)]) = _$SearchResultResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchResultResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchResultResponseDto> get serializer => _$SearchResultResponseDtoSerializer();
}

class _$SearchResultResponseDtoSerializer implements PrimitiveSerializer<SearchResultResponseDto> {
  @override
  final Iterable<Type> types = const [SearchResultResponseDto, _$SearchResultResponseDto];

  @override
  final String wireName = r'SearchResultResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchResultResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'users';
    yield serializers.serialize(
      object.users,
      specifiedType: const FullType(BuiltList, [FullType(SearchUserResponseDto)]),
    );
    yield r'threads';
    yield serializers.serialize(
      object.threads,
      specifiedType: const FullType(BuiltList, [FullType(SearchThreadResponseDto)]),
    );
    yield r'posts';
    yield serializers.serialize(
      object.posts,
      specifiedType: const FullType(BuiltList, [FullType(SearchPostResponseDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchResultResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchResultResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'users':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SearchUserResponseDto)]),
          ) as BuiltList<SearchUserResponseDto>;
          result.users.replace(valueDes);
          break;
        case r'threads':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SearchThreadResponseDto)]),
          ) as BuiltList<SearchThreadResponseDto>;
          result.threads.replace(valueDes);
          break;
        case r'posts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SearchPostResponseDto)]),
          ) as BuiltList<SearchPostResponseDto>;
          result.posts.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchResultResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchResultResponseDtoBuilder();
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
