//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_thread_count_response_dto.g.dart';

/// SearchThreadCountResponseDto
///
/// Properties:
/// * [members] - 参与人数
/// * [posts] - 帖子数
/// * [players] - 已标记玩家数
@BuiltValue()
abstract class SearchThreadCountResponseDto implements Built<SearchThreadCountResponseDto, SearchThreadCountResponseDtoBuilder> {
  /// 参与人数
  @BuiltValueField(wireName: r'members')
  num get members;

  /// 帖子数
  @BuiltValueField(wireName: r'posts')
  num get posts;

  /// 已标记玩家数
  @BuiltValueField(wireName: r'players')
  num get players;

  SearchThreadCountResponseDto._();

  factory SearchThreadCountResponseDto([void updates(SearchThreadCountResponseDtoBuilder b)]) = _$SearchThreadCountResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchThreadCountResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchThreadCountResponseDto> get serializer => _$SearchThreadCountResponseDtoSerializer();
}

class _$SearchThreadCountResponseDtoSerializer implements PrimitiveSerializer<SearchThreadCountResponseDto> {
  @override
  final Iterable<Type> types = const [SearchThreadCountResponseDto, _$SearchThreadCountResponseDto];

  @override
  final String wireName = r'SearchThreadCountResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchThreadCountResponseDto object, {
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
    yield r'players';
    yield serializers.serialize(
      object.players,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchThreadCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchThreadCountResponseDtoBuilder result,
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
        case r'players':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.players = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchThreadCountResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchThreadCountResponseDtoBuilder();
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
