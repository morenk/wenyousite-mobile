//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invite_link_response_dto.g.dart';

/// InviteLinkResponseDto
///
/// Properties:
/// * [id]
/// * [threadId]
/// * [token]
/// * [createdAt]
@BuiltValue()
abstract class InviteLinkResponseDto implements Built<InviteLinkResponseDto, InviteLinkResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  @BuiltValueField(wireName: r'token')
  String get token;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  InviteLinkResponseDto._();

  factory InviteLinkResponseDto([void updates(InviteLinkResponseDtoBuilder b)]) = _$InviteLinkResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InviteLinkResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InviteLinkResponseDto> get serializer => _$InviteLinkResponseDtoSerializer();
}

class _$InviteLinkResponseDtoSerializer implements PrimitiveSerializer<InviteLinkResponseDto> {
  @override
  final Iterable<Type> types = const [InviteLinkResponseDto, _$InviteLinkResponseDto];

  @override
  final String wireName = r'InviteLinkResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InviteLinkResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'threadId';
    yield serializers.serialize(
      object.threadId,
      specifiedType: const FullType(String),
    );
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InviteLinkResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InviteLinkResponseDtoBuilder result,
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
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.threadId = valueDes;
          break;
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InviteLinkResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InviteLinkResponseDtoBuilder();
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
