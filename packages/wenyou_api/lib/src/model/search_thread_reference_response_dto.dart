//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_thread_reference_response_dto.g.dart';

/// SearchThreadReferenceResponseDto
///
/// Properties:
/// * [id] - 主题帖 ID
/// * [title] - 主题帖标题
@BuiltValue()
abstract class SearchThreadReferenceResponseDto implements Built<SearchThreadReferenceResponseDto, SearchThreadReferenceResponseDtoBuilder> {
  /// 主题帖 ID
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 主题帖标题
  @BuiltValueField(wireName: r'title')
  String get title;

  SearchThreadReferenceResponseDto._();

  factory SearchThreadReferenceResponseDto([void updates(SearchThreadReferenceResponseDtoBuilder b)]) = _$SearchThreadReferenceResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchThreadReferenceResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchThreadReferenceResponseDto> get serializer => _$SearchThreadReferenceResponseDtoSerializer();
}

class _$SearchThreadReferenceResponseDtoSerializer implements PrimitiveSerializer<SearchThreadReferenceResponseDto> {
  @override
  final Iterable<Type> types = const [SearchThreadReferenceResponseDto, _$SearchThreadReferenceResponseDto];

  @override
  final String wireName = r'SearchThreadReferenceResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchThreadReferenceResponseDto object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchThreadReferenceResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchThreadReferenceResponseDtoBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchThreadReferenceResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchThreadReferenceResponseDtoBuilder();
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
