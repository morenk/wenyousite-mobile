//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_hidden_content_user_response_dto.g.dart';

/// AdminHiddenContentUserResponseDto
///
/// Properties:
/// * [id]
/// * [username]
@BuiltValue()
abstract class AdminHiddenContentUserResponseDto implements Built<AdminHiddenContentUserResponseDto, AdminHiddenContentUserResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  AdminHiddenContentUserResponseDto._();

  factory AdminHiddenContentUserResponseDto([void updates(AdminHiddenContentUserResponseDtoBuilder b)]) = _$AdminHiddenContentUserResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminHiddenContentUserResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminHiddenContentUserResponseDto> get serializer => _$AdminHiddenContentUserResponseDtoSerializer();
}

class _$AdminHiddenContentUserResponseDtoSerializer implements PrimitiveSerializer<AdminHiddenContentUserResponseDto> {
  @override
  final Iterable<Type> types = const [AdminHiddenContentUserResponseDto, _$AdminHiddenContentUserResponseDto];

  @override
  final String wireName = r'AdminHiddenContentUserResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminHiddenContentUserResponseDto object, {
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
    AdminHiddenContentUserResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminHiddenContentUserResponseDtoBuilder result,
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
  AdminHiddenContentUserResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminHiddenContentUserResponseDtoBuilder();
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
