//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_moment_comment_response_dto.g.dart';

/// NotificationMomentCommentResponseDto
///
/// Properties:
/// * [id]
/// * [parentCommentId]
/// * [deletedAt]
@BuiltValue()
abstract class NotificationMomentCommentResponseDto implements Built<NotificationMomentCommentResponseDto, NotificationMomentCommentResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'parentCommentId')
  String? get parentCommentId;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime? get deletedAt;

  NotificationMomentCommentResponseDto._();

  factory NotificationMomentCommentResponseDto([void updates(NotificationMomentCommentResponseDtoBuilder b)]) = _$NotificationMomentCommentResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationMomentCommentResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationMomentCommentResponseDto> get serializer => _$NotificationMomentCommentResponseDtoSerializer();
}

class _$NotificationMomentCommentResponseDtoSerializer implements PrimitiveSerializer<NotificationMomentCommentResponseDto> {
  @override
  final Iterable<Type> types = const [NotificationMomentCommentResponseDto, _$NotificationMomentCommentResponseDto];

  @override
  final String wireName = r'NotificationMomentCommentResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationMomentCommentResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'parentCommentId';
    yield object.parentCommentId == null ? null : serializers.serialize(
      object.parentCommentId,
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
    NotificationMomentCommentResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationMomentCommentResponseDtoBuilder result,
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
        case r'parentCommentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentCommentId = valueDes;
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
  NotificationMomentCommentResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationMomentCommentResponseDtoBuilder();
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
