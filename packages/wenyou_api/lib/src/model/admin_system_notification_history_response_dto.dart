//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_system_notification_history_item_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_system_notification_history_response_dto.g.dart';

/// AdminSystemNotificationHistoryResponseDto
///
/// Properties:
/// * [data]
/// * [cursor]
/// * [hasMore]
@BuiltValue()
abstract class AdminSystemNotificationHistoryResponseDto implements Built<AdminSystemNotificationHistoryResponseDto, AdminSystemNotificationHistoryResponseDtoBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<AdminSystemNotificationHistoryItemDto> get data;

  @BuiltValueField(wireName: r'cursor')
  String? get cursor;

  @BuiltValueField(wireName: r'hasMore')
  bool get hasMore;

  AdminSystemNotificationHistoryResponseDto._();

  factory AdminSystemNotificationHistoryResponseDto([void updates(AdminSystemNotificationHistoryResponseDtoBuilder b)]) = _$AdminSystemNotificationHistoryResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminSystemNotificationHistoryResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminSystemNotificationHistoryResponseDto> get serializer => _$AdminSystemNotificationHistoryResponseDtoSerializer();
}

class _$AdminSystemNotificationHistoryResponseDtoSerializer implements PrimitiveSerializer<AdminSystemNotificationHistoryResponseDto> {
  @override
  final Iterable<Type> types = const [AdminSystemNotificationHistoryResponseDto, _$AdminSystemNotificationHistoryResponseDto];

  @override
  final String wireName = r'AdminSystemNotificationHistoryResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminSystemNotificationHistoryResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(AdminSystemNotificationHistoryItemDto)]),
    );
    yield r'cursor';
    yield object.cursor == null ? null : serializers.serialize(
      object.cursor,
      specifiedType: const FullType.nullable(String),
    );
    yield r'hasMore';
    yield serializers.serialize(
      object.hasMore,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminSystemNotificationHistoryResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminSystemNotificationHistoryResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminSystemNotificationHistoryItemDto)]),
          ) as BuiltList<AdminSystemNotificationHistoryItemDto>;
          result.data.replace(valueDes);
          break;
        case r'cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cursor = valueDes;
          break;
        case r'hasMore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminSystemNotificationHistoryResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminSystemNotificationHistoryResponseDtoBuilder();
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
