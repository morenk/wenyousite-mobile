//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_thread_owner_response_dto.g.dart';

/// SearchThreadOwnerResponseDto
///
/// Properties:
/// * [id] - 用户 ID
/// * [username] - 用户名
/// * [avatar] - 头像 URL
@BuiltValue()
abstract class SearchThreadOwnerResponseDto implements Built<SearchThreadOwnerResponseDto, SearchThreadOwnerResponseDtoBuilder> {
  /// 用户 ID
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 用户名
  @BuiltValueField(wireName: r'username')
  String get username;

  /// 头像 URL
  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  SearchThreadOwnerResponseDto._();

  factory SearchThreadOwnerResponseDto([void updates(SearchThreadOwnerResponseDtoBuilder b)]) = _$SearchThreadOwnerResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchThreadOwnerResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchThreadOwnerResponseDto> get serializer => _$SearchThreadOwnerResponseDtoSerializer();
}

class _$SearchThreadOwnerResponseDtoSerializer implements PrimitiveSerializer<SearchThreadOwnerResponseDto> {
  @override
  final Iterable<Type> types = const [SearchThreadOwnerResponseDto, _$SearchThreadOwnerResponseDto];

  @override
  final String wireName = r'SearchThreadOwnerResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchThreadOwnerResponseDto object, {
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
    yield r'avatar';
    yield object.avatar == null ? null : serializers.serialize(
      object.avatar,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchThreadOwnerResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchThreadOwnerResponseDtoBuilder result,
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
        case r'avatar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatar = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchThreadOwnerResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchThreadOwnerResponseDtoBuilder();
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
