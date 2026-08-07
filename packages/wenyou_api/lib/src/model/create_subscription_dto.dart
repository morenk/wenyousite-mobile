//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_subscription_dto.g.dart';

/// CreateSubscriptionDto
///
/// Properties:
/// * [threadId] - 要订阅的主题帖 ID
/// * [type] - THREAD=楼主或协作者发布的官方更新, USER=指定普通玩家在帖内的新发言
/// * [targetUserId] - 目标玩家 ID（type=USER 时必填；必须是本帖已标记玩家的普通参与人）
@BuiltValue()
abstract class CreateSubscriptionDto implements Built<CreateSubscriptionDto, CreateSubscriptionDtoBuilder> {
  /// 要订阅的主题帖 ID
  @BuiltValueField(wireName: r'threadId')
  String get threadId;

  /// THREAD=楼主或协作者发布的官方更新, USER=指定普通玩家在帖内的新发言
  @BuiltValueField(wireName: r'type')
  CreateSubscriptionDtoTypeEnum get type;
  // enum typeEnum {  THREAD,  USER,  };

  /// 目标玩家 ID（type=USER 时必填；必须是本帖已标记玩家的普通参与人）
  @BuiltValueField(wireName: r'targetUserId')
  String? get targetUserId;

  CreateSubscriptionDto._();

  factory CreateSubscriptionDto([void updates(CreateSubscriptionDtoBuilder b)]) = _$CreateSubscriptionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateSubscriptionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateSubscriptionDto> get serializer => _$CreateSubscriptionDtoSerializer();
}

class _$CreateSubscriptionDtoSerializer implements PrimitiveSerializer<CreateSubscriptionDto> {
  @override
  final Iterable<Type> types = const [CreateSubscriptionDto, _$CreateSubscriptionDto];

  @override
  final String wireName = r'CreateSubscriptionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateSubscriptionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'threadId';
    yield serializers.serialize(
      object.threadId,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(CreateSubscriptionDtoTypeEnum),
    );
    if (object.targetUserId != null) {
      yield r'targetUserId';
      yield serializers.serialize(
        object.targetUserId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateSubscriptionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateSubscriptionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'threadId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.threadId = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateSubscriptionDtoTypeEnum),
          ) as CreateSubscriptionDtoTypeEnum;
          result.type = valueDes;
          break;
        case r'targetUserId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetUserId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateSubscriptionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateSubscriptionDtoBuilder();
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

class CreateSubscriptionDtoTypeEnum extends EnumClass {

  /// THREAD=楼主或协作者发布的官方更新, USER=指定普通玩家在帖内的新发言
  @BuiltValueEnumConst(wireName: r'THREAD')
  static const CreateSubscriptionDtoTypeEnum THREAD = _$createSubscriptionDtoTypeEnum_THREAD;
  /// THREAD=楼主或协作者发布的官方更新, USER=指定普通玩家在帖内的新发言
  @BuiltValueEnumConst(wireName: r'USER')
  static const CreateSubscriptionDtoTypeEnum USER = _$createSubscriptionDtoTypeEnum_USER;
  /// THREAD=楼主或协作者发布的官方更新, USER=指定普通玩家在帖内的新发言
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CreateSubscriptionDtoTypeEnum unknownDefaultOpenApi = _$createSubscriptionDtoTypeEnum_unknownDefaultOpenApi;

  static Serializer<CreateSubscriptionDtoTypeEnum> get serializer => _$createSubscriptionDtoTypeEnumSerializer;

  const CreateSubscriptionDtoTypeEnum._(String name): super(name);

  static BuiltSet<CreateSubscriptionDtoTypeEnum> get values => _$createSubscriptionDtoTypeEnumValues;
  static CreateSubscriptionDtoTypeEnum valueOf(String name) => _$createSubscriptionDtoTypeEnumValueOf(name);
}
