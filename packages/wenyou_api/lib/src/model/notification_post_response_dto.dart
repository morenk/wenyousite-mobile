//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_post_response_dto.g.dart';

/// NotificationPostResponseDto
///
/// Properties:
/// * [id]
/// * [floorNumber]
/// * [parentPostId]
/// * [deletedAt]
@BuiltValue()
abstract class NotificationPostResponseDto implements Built<NotificationPostResponseDto, NotificationPostResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'floorNumber')
  num? get floorNumber;

  @BuiltValueField(wireName: r'parentPostId')
  String? get parentPostId;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime? get deletedAt;

  NotificationPostResponseDto._();

  factory NotificationPostResponseDto([void updates(NotificationPostResponseDtoBuilder b)]) = _$NotificationPostResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationPostResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationPostResponseDto> get serializer => _$NotificationPostResponseDtoSerializer();
}

class _$NotificationPostResponseDtoSerializer implements PrimitiveSerializer<NotificationPostResponseDto> {
  @override
  final Iterable<Type> types = const [NotificationPostResponseDto, _$NotificationPostResponseDto];

  @override
  final String wireName = r'NotificationPostResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationPostResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'floorNumber';
    yield object.floorNumber == null ? null : serializers.serialize(
      object.floorNumber,
      specifiedType: const FullType.nullable(num),
    );
    yield r'parentPostId';
    yield object.parentPostId == null ? null : serializers.serialize(
      object.parentPostId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'deletedAt';
    yield object.deletedAt == null ? null : serializers.serialize(
      object.deletedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationPostResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationPostResponseDtoBuilder result,
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
        case r'floorNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.floorNumber = valueDes;
          break;
        case r'parentPostId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentPostId = valueDes;
          break;
        case r'deletedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationPostResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationPostResponseDtoBuilder();
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
