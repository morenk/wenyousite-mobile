//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_session_info_dto.g.dart';

/// AdminSessionInfoDto
///
/// Properties:
/// * [id]
/// * [expiresAt]
/// * [idleMinutes] - 有效闲置上限（分钟）；短会话默认30，记住设备为10080且只受固定七天绝对期限约束
/// * [createdAt]
/// * [lastActiveAt]
/// * [elevatedUntil]
@BuiltValue()
abstract class AdminSessionInfoDto implements Built<AdminSessionInfoDto, AdminSessionInfoDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  /// 有效闲置上限（分钟）；短会话默认30，记住设备为10080且只受固定七天绝对期限约束
  @BuiltValueField(wireName: r'idleMinutes')
  num get idleMinutes;

  @BuiltValueField(wireName: r'createdAt')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'lastActiveAt')
  DateTime? get lastActiveAt;

  @BuiltValueField(wireName: r'elevatedUntil')
  DateTime? get elevatedUntil;

  AdminSessionInfoDto._();

  factory AdminSessionInfoDto([void updates(AdminSessionInfoDtoBuilder b)]) = _$AdminSessionInfoDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminSessionInfoDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminSessionInfoDto> get serializer => _$AdminSessionInfoDtoSerializer();
}

class _$AdminSessionInfoDtoSerializer implements PrimitiveSerializer<AdminSessionInfoDto> {
  @override
  final Iterable<Type> types = const [AdminSessionInfoDto, _$AdminSessionInfoDto];

  @override
  final String wireName = r'AdminSessionInfoDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminSessionInfoDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'idleMinutes';
    yield serializers.serialize(
      object.idleMinutes,
      specifiedType: const FullType(num),
    );
    if (object.createdAt != null) {
      yield r'createdAt';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.lastActiveAt != null) {
      yield r'lastActiveAt';
      yield serializers.serialize(
        object.lastActiveAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.elevatedUntil != null) {
      yield r'elevatedUntil';
      yield serializers.serialize(
        object.elevatedUntil,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminSessionInfoDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminSessionInfoDtoBuilder result,
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
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'idleMinutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.idleMinutes = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'lastActiveAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastActiveAt = valueDes;
          break;
        case r'elevatedUntil':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.elevatedUntil = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminSessionInfoDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminSessionInfoDtoBuilder();
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
