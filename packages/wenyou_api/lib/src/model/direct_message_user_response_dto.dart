//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'direct_message_user_response_dto.g.dart';

/// DirectMessageUserResponseDto
///
/// Properties:
/// * [id]
/// * [username]
/// * [avatar]
/// * [isDeactivated]
@BuiltValue()
abstract class DirectMessageUserResponseDto implements Built<DirectMessageUserResponseDto, DirectMessageUserResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  @BuiltValueField(wireName: r'isDeactivated')
  bool get isDeactivated;

  DirectMessageUserResponseDto._();

  factory DirectMessageUserResponseDto([void updates(DirectMessageUserResponseDtoBuilder b)]) = _$DirectMessageUserResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DirectMessageUserResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DirectMessageUserResponseDto> get serializer => _$DirectMessageUserResponseDtoSerializer();
}

class _$DirectMessageUserResponseDtoSerializer implements PrimitiveSerializer<DirectMessageUserResponseDto> {
  @override
  final Iterable<Type> types = const [DirectMessageUserResponseDto, _$DirectMessageUserResponseDto];

  @override
  final String wireName = r'DirectMessageUserResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DirectMessageUserResponseDto object, {
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
    yield r'isDeactivated';
    yield serializers.serialize(
      object.isDeactivated,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DirectMessageUserResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DirectMessageUserResponseDtoBuilder result,
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
        case r'isDeactivated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDeactivated = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DirectMessageUserResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DirectMessageUserResponseDtoBuilder();
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
