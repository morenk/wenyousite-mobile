//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_liker_response_dto.g.dart';

/// NotificationLikerResponseDto
///
/// Properties:
/// * [userId]
/// * [username]
@BuiltValue()
abstract class NotificationLikerResponseDto implements Built<NotificationLikerResponseDto, NotificationLikerResponseDtoBuilder> {
  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'username')
  String get username;

  NotificationLikerResponseDto._();

  factory NotificationLikerResponseDto([void updates(NotificationLikerResponseDtoBuilder b)]) = _$NotificationLikerResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationLikerResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationLikerResponseDto> get serializer => _$NotificationLikerResponseDtoSerializer();
}

class _$NotificationLikerResponseDtoSerializer implements PrimitiveSerializer<NotificationLikerResponseDto> {
  @override
  final Iterable<Type> types = const [NotificationLikerResponseDto, _$NotificationLikerResponseDto];

  @override
  final String wireName = r'NotificationLikerResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationLikerResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'userId';
    yield serializers.serialize(
      object.userId,
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
    NotificationLikerResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationLikerResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
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
  NotificationLikerResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationLikerResponseDtoBuilder();
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
