//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_audience_dto.g.dart';

/// NotificationAudienceDto
///
/// Properties:
/// * [roles]
/// * [emailVerified]
@BuiltValue()
abstract class NotificationAudienceDto implements Built<NotificationAudienceDto, NotificationAudienceDtoBuilder> {
  @BuiltValueField(wireName: r'roles')
  BuiltList<NotificationAudienceDtoRolesEnum>? get roles;
  // enum rolesEnum {  USER,  ADMIN,  SUPER_ADMIN,  };

  @BuiltValueField(wireName: r'emailVerified')
  bool? get emailVerified;

  NotificationAudienceDto._();

  factory NotificationAudienceDto([void updates(NotificationAudienceDtoBuilder b)]) = _$NotificationAudienceDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationAudienceDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationAudienceDto> get serializer => _$NotificationAudienceDtoSerializer();
}

class _$NotificationAudienceDtoSerializer implements PrimitiveSerializer<NotificationAudienceDto> {
  @override
  final Iterable<Type> types = const [NotificationAudienceDto, _$NotificationAudienceDto];

  @override
  final String wireName = r'NotificationAudienceDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationAudienceDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.roles != null) {
      yield r'roles';
      yield serializers.serialize(
        object.roles,
        specifiedType: const FullType(BuiltList, [FullType(NotificationAudienceDtoRolesEnum)]),
      );
    }
    if (object.emailVerified != null) {
      yield r'emailVerified';
      yield serializers.serialize(
        object.emailVerified,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationAudienceDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationAudienceDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'roles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(NotificationAudienceDtoRolesEnum)]),
          ) as BuiltList<NotificationAudienceDtoRolesEnum>;
          result.roles.replace(valueDes);
          break;
        case r'emailVerified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.emailVerified = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationAudienceDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationAudienceDtoBuilder();
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

class NotificationAudienceDtoRolesEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const NotificationAudienceDtoRolesEnum USER = _$notificationAudienceDtoRolesEnum_USER;
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const NotificationAudienceDtoRolesEnum ADMIN = _$notificationAudienceDtoRolesEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN')
  static const NotificationAudienceDtoRolesEnum SUPER_ADMIN = _$notificationAudienceDtoRolesEnum_SUPER_ADMIN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const NotificationAudienceDtoRolesEnum unknownDefaultOpenApi = _$notificationAudienceDtoRolesEnum_unknownDefaultOpenApi;

  static Serializer<NotificationAudienceDtoRolesEnum> get serializer => _$notificationAudienceDtoRolesEnumSerializer;

  const NotificationAudienceDtoRolesEnum._(String name): super(name);

  static BuiltSet<NotificationAudienceDtoRolesEnum> get values => _$notificationAudienceDtoRolesEnumValues;
  static NotificationAudienceDtoRolesEnum valueOf(String name) => _$notificationAudienceDtoRolesEnumValueOf(name);
}
