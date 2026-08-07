//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'unread_notification_count_response_dto.g.dart';

/// UnreadNotificationCountResponseDto
///
/// Properties:
/// * [unreadCount]
@BuiltValue()
abstract class UnreadNotificationCountResponseDto implements Built<UnreadNotificationCountResponseDto, UnreadNotificationCountResponseDtoBuilder> {
  @BuiltValueField(wireName: r'unreadCount')
  num get unreadCount;

  UnreadNotificationCountResponseDto._();

  factory UnreadNotificationCountResponseDto([void updates(UnreadNotificationCountResponseDtoBuilder b)]) = _$UnreadNotificationCountResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UnreadNotificationCountResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UnreadNotificationCountResponseDto> get serializer => _$UnreadNotificationCountResponseDtoSerializer();
}

class _$UnreadNotificationCountResponseDtoSerializer implements PrimitiveSerializer<UnreadNotificationCountResponseDto> {
  @override
  final Iterable<Type> types = const [UnreadNotificationCountResponseDto, _$UnreadNotificationCountResponseDto];

  @override
  final String wireName = r'UnreadNotificationCountResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UnreadNotificationCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'unreadCount';
    yield serializers.serialize(
      object.unreadCount,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UnreadNotificationCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UnreadNotificationCountResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'unreadCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.unreadCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UnreadNotificationCountResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UnreadNotificationCountResponseDtoBuilder();
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
