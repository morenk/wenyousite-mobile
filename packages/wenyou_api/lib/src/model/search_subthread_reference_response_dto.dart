//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_subthread_reference_response_dto.g.dart';

/// SearchSubthreadReferenceResponseDto
///
/// Properties:
/// * [id] - 子贴 ID
/// * [title] - 子贴标题
@BuiltValue()
abstract class SearchSubthreadReferenceResponseDto implements Built<SearchSubthreadReferenceResponseDto, SearchSubthreadReferenceResponseDtoBuilder> {
  /// 子贴 ID
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 子贴标题
  @BuiltValueField(wireName: r'title')
  String get title;

  SearchSubthreadReferenceResponseDto._();

  factory SearchSubthreadReferenceResponseDto([void updates(SearchSubthreadReferenceResponseDtoBuilder b)]) = _$SearchSubthreadReferenceResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchSubthreadReferenceResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchSubthreadReferenceResponseDto> get serializer => _$SearchSubthreadReferenceResponseDtoSerializer();
}

class _$SearchSubthreadReferenceResponseDtoSerializer implements PrimitiveSerializer<SearchSubthreadReferenceResponseDto> {
  @override
  final Iterable<Type> types = const [SearchSubthreadReferenceResponseDto, _$SearchSubthreadReferenceResponseDto];

  @override
  final String wireName = r'SearchSubthreadReferenceResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchSubthreadReferenceResponseDto object, {
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
    SearchSubthreadReferenceResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchSubthreadReferenceResponseDtoBuilder result,
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
  SearchSubthreadReferenceResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchSubthreadReferenceResponseDtoBuilder();
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
