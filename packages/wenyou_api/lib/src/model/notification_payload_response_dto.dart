//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/notification_liker_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_payload_response_dto.g.dart';

/// NotificationPayloadResponseDto
///
/// Properties:
/// * [schemaVersion]
/// * [action]
/// * [actorId]
/// * [actorName]
/// * [preview]
/// * [subthreadTitle]
/// * [threadTitle]
/// * [momentTitle]
/// * [totalCount]
/// * [likers]
/// * [grossAmount]
/// * [recipientAmount]
/// * [platformAmount]
/// * [previousLevel]
/// * [level]
/// * [experience]
@BuiltValue()
abstract class NotificationPayloadResponseDto implements Built<NotificationPayloadResponseDto, NotificationPayloadResponseDtoBuilder> {
  @BuiltValueField(wireName: r'schemaVersion')
  NotificationPayloadResponseDtoSchemaVersionEnum get schemaVersion;
  // enum schemaVersionEnum {  1,  };

  @BuiltValueField(wireName: r'action')
  String? get action;

  @BuiltValueField(wireName: r'actorId')
  String? get actorId;

  @BuiltValueField(wireName: r'actorName')
  String? get actorName;

  @BuiltValueField(wireName: r'preview')
  String? get preview;

  @BuiltValueField(wireName: r'subthreadTitle')
  String? get subthreadTitle;

  @BuiltValueField(wireName: r'threadTitle')
  String? get threadTitle;

  @BuiltValueField(wireName: r'momentTitle')
  String? get momentTitle;

  @BuiltValueField(wireName: r'totalCount')
  num? get totalCount;

  @BuiltValueField(wireName: r'likers')
  BuiltList<NotificationLikerResponseDto>? get likers;

  @BuiltValueField(wireName: r'grossAmount')
  String? get grossAmount;

  @BuiltValueField(wireName: r'recipientAmount')
  String? get recipientAmount;

  @BuiltValueField(wireName: r'platformAmount')
  String? get platformAmount;

  @BuiltValueField(wireName: r'previousLevel')
  num? get previousLevel;

  @BuiltValueField(wireName: r'level')
  num? get level;

  @BuiltValueField(wireName: r'experience')
  num? get experience;

  NotificationPayloadResponseDto._();

  factory NotificationPayloadResponseDto([void updates(NotificationPayloadResponseDtoBuilder b)]) = _$NotificationPayloadResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationPayloadResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationPayloadResponseDto> get serializer => _$NotificationPayloadResponseDtoSerializer();
}

class _$NotificationPayloadResponseDtoSerializer implements PrimitiveSerializer<NotificationPayloadResponseDto> {
  @override
  final Iterable<Type> types = const [NotificationPayloadResponseDto, _$NotificationPayloadResponseDto];

  @override
  final String wireName = r'NotificationPayloadResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationPayloadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'schemaVersion';
    yield serializers.serialize(
      object.schemaVersion,
      specifiedType: const FullType(NotificationPayloadResponseDtoSchemaVersionEnum),
    );
    if (object.action != null) {
      yield r'action';
      yield serializers.serialize(
        object.action,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.actorId != null) {
      yield r'actorId';
      yield serializers.serialize(
        object.actorId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.actorName != null) {
      yield r'actorName';
      yield serializers.serialize(
        object.actorName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.preview != null) {
      yield r'preview';
      yield serializers.serialize(
        object.preview,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.subthreadTitle != null) {
      yield r'subthreadTitle';
      yield serializers.serialize(
        object.subthreadTitle,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.threadTitle != null) {
      yield r'threadTitle';
      yield serializers.serialize(
        object.threadTitle,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.momentTitle != null) {
      yield r'momentTitle';
      yield serializers.serialize(
        object.momentTitle,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.totalCount != null) {
      yield r'totalCount';
      yield serializers.serialize(
        object.totalCount,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.likers != null) {
      yield r'likers';
      yield serializers.serialize(
        object.likers,
        specifiedType: const FullType(BuiltList, [FullType(NotificationLikerResponseDto)]),
      );
    }
    if (object.grossAmount != null) {
      yield r'grossAmount';
      yield serializers.serialize(
        object.grossAmount,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.recipientAmount != null) {
      yield r'recipientAmount';
      yield serializers.serialize(
        object.recipientAmount,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.platformAmount != null) {
      yield r'platformAmount';
      yield serializers.serialize(
        object.platformAmount,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.previousLevel != null) {
      yield r'previousLevel';
      yield serializers.serialize(
        object.previousLevel,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.level != null) {
      yield r'level';
      yield serializers.serialize(
        object.level,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.experience != null) {
      yield r'experience';
      yield serializers.serialize(
        object.experience,
        specifiedType: const FullType.nullable(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationPayloadResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationPayloadResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'schemaVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationPayloadResponseDtoSchemaVersionEnum),
          ) as NotificationPayloadResponseDtoSchemaVersionEnum;
          result.schemaVersion = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.action = valueDes;
          break;
        case r'actorId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.actorId = valueDes;
          break;
        case r'actorName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.actorName = valueDes;
          break;
        case r'preview':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.preview = valueDes;
          break;
        case r'subthreadTitle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.subthreadTitle = valueDes;
          break;
        case r'threadTitle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.threadTitle = valueDes;
          break;
        case r'momentTitle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.momentTitle = valueDes;
          break;
        case r'totalCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.totalCount = valueDes;
          break;
        case r'likers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(NotificationLikerResponseDto)]),
          ) as BuiltList<NotificationLikerResponseDto>;
          result.likers.replace(valueDes);
          break;
        case r'grossAmount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.grossAmount = valueDes;
          break;
        case r'recipientAmount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.recipientAmount = valueDes;
          break;
        case r'platformAmount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.platformAmount = valueDes;
          break;
        case r'previousLevel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.previousLevel = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.level = valueDes;
          break;
        case r'experience':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.experience = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationPayloadResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationPayloadResponseDtoBuilder();
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

class NotificationPayloadResponseDtoSchemaVersionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'1')
  static const NotificationPayloadResponseDtoSchemaVersionEnum n1 = _$notificationPayloadResponseDtoSchemaVersionEnum_n1;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const NotificationPayloadResponseDtoSchemaVersionEnum unknownDefaultOpenApi = _$notificationPayloadResponseDtoSchemaVersionEnum_unknownDefaultOpenApi;

  static Serializer<NotificationPayloadResponseDtoSchemaVersionEnum> get serializer => _$notificationPayloadResponseDtoSchemaVersionEnumSerializer;

  const NotificationPayloadResponseDtoSchemaVersionEnum._(String name): super(name);

  static BuiltSet<NotificationPayloadResponseDtoSchemaVersionEnum> get values => _$notificationPayloadResponseDtoSchemaVersionEnumValues;
  static NotificationPayloadResponseDtoSchemaVersionEnum valueOf(String name) => _$notificationPayloadResponseDtoSchemaVersionEnumValueOf(name);
}
