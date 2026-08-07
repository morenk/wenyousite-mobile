//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_user_response_dto.g.dart';

/// SearchUserResponseDto
///
/// Properties:
/// * [id] - 用户 ID
/// * [username] - 用户名
/// * [avatar] - 头像 URL
/// * [bio] - 个人简介
@BuiltValue()
abstract class SearchUserResponseDto implements Built<SearchUserResponseDto, SearchUserResponseDtoBuilder> {
  /// 用户 ID
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 用户名
  @BuiltValueField(wireName: r'username')
  String get username;

  /// 头像 URL
  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  /// 个人简介
  @BuiltValueField(wireName: r'bio')
  String? get bio;

  SearchUserResponseDto._();

  factory SearchUserResponseDto([void updates(SearchUserResponseDtoBuilder b)]) = _$SearchUserResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchUserResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchUserResponseDto> get serializer => _$SearchUserResponseDtoSerializer();
}

class _$SearchUserResponseDtoSerializer implements PrimitiveSerializer<SearchUserResponseDto> {
  @override
  final Iterable<Type> types = const [SearchUserResponseDto, _$SearchUserResponseDto];

  @override
  final String wireName = r'SearchUserResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchUserResponseDto object, {
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
    yield r'bio';
    yield object.bio == null ? null : serializers.serialize(
      object.bio,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchUserResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchUserResponseDtoBuilder result,
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
        case r'bio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bio = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchUserResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchUserResponseDtoBuilder();
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
