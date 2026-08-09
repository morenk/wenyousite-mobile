//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/search_thread_owner_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/search_thread_count_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_thread_response_dto.g.dart';

/// SearchThreadResponseDto
///
/// Properties:
/// * [id] - 主题帖 ID
/// * [title] - 主题帖标题
/// * [category] - 动态分类 slug
/// * [createdAt] - 创建时间
/// * [owner] - 楼主信息
/// * [count] - 主题帖统计
/// * [coverImages] - 默认主贴正文中的普通图片 URL，按出现顺序返回，最多 3 张
@BuiltValue()
abstract class SearchThreadResponseDto implements Built<SearchThreadResponseDto, SearchThreadResponseDtoBuilder> {
  /// 主题帖 ID
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 主题帖标题
  @BuiltValueField(wireName: r'title')
  String get title;

  /// 动态分类 slug
  @BuiltValueField(wireName: r'category')
  String? get category;

  /// 创建时间
  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  /// 楼主信息
  @BuiltValueField(wireName: r'owner')
  SearchThreadOwnerResponseDto get owner;

  /// 主题帖统计
  @BuiltValueField(wireName: r'_count')
  SearchThreadCountResponseDto get count;

  /// 默认主贴正文中的普通图片 URL，按出现顺序返回，最多 3 张
  @BuiltValueField(wireName: r'coverImages')
  BuiltList<String> get coverImages;

  SearchThreadResponseDto._();

  factory SearchThreadResponseDto([void updates(SearchThreadResponseDtoBuilder b)]) = _$SearchThreadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchThreadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchThreadResponseDto> get serializer => _$SearchThreadResponseDtoSerializer();
}

class _$SearchThreadResponseDtoSerializer implements PrimitiveSerializer<SearchThreadResponseDto> {
  @override
  final Iterable<Type> types = const [SearchThreadResponseDto, _$SearchThreadResponseDto];

  @override
  final String wireName = r'SearchThreadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchThreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'category';
    yield object.category == null ? null : serializers.serialize(
      object.category,
      specifiedType: const FullType.nullable(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'owner';
    yield serializers.serialize(
      object.owner,
      specifiedType: const FullType(SearchThreadOwnerResponseDto),
    );
    yield r'_count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(SearchThreadCountResponseDto),
    );
    yield r'coverImages';
    yield serializers.serialize(
      object.coverImages,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchThreadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchThreadResponseDtoBuilder result,
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
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.category = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'owner':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SearchThreadOwnerResponseDto),
          ) as SearchThreadOwnerResponseDto;
          result.owner.replace(valueDes);
          break;
        case r'_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SearchThreadCountResponseDto),
          ) as SearchThreadCountResponseDto;
          result.count.replace(valueDes);
          break;
        case r'coverImages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.coverImages.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchThreadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchThreadResponseDtoBuilder();
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
