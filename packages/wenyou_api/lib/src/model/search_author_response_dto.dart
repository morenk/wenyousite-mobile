//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_author_response_dto.g.dart';

/// SearchAuthorResponseDto
///
/// Properties:
/// * [id] - 用户 ID
/// * [username] - 用户名
@BuiltValue()
abstract class SearchAuthorResponseDto implements Built<SearchAuthorResponseDto, SearchAuthorResponseDtoBuilder> {
  /// 用户 ID
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 用户名
  @BuiltValueField(wireName: r'username')
  String get username;

  SearchAuthorResponseDto._();

  factory SearchAuthorResponseDto([void updates(SearchAuthorResponseDtoBuilder b)]) = _$SearchAuthorResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchAuthorResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchAuthorResponseDto> get serializer => _$SearchAuthorResponseDtoSerializer();
}

class _$SearchAuthorResponseDtoSerializer implements PrimitiveSerializer<SearchAuthorResponseDto> {
  @override
  final Iterable<Type> types = const [SearchAuthorResponseDto, _$SearchAuthorResponseDto];

  @override
  final String wireName = r'SearchAuthorResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchAuthorResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchAuthorResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchAuthorResponseDtoBuilder result,
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
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchAuthorResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchAuthorResponseDtoBuilder();
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
