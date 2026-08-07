//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_subthread_dto.g.dart';

/// CreateSubthreadDto
///
/// Properties:
/// * [clientRequestId] - 客户端创建幂等键；同一次提交和网络重试必须复用
/// * [title] - 子贴标题
/// * [content] - 子贴正文（kind=BODY，可选，留空仅创建空子贴）
/// * [sortOrder] - 排序序号，越小越靠前
/// * [postingPolicy] - PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅被标记为玩家的参与人可发帖
@BuiltValue()
abstract class CreateSubthreadDto implements Built<CreateSubthreadDto, CreateSubthreadDtoBuilder> {
  /// 客户端创建幂等键；同一次提交和网络重试必须复用
  @BuiltValueField(wireName: r'clientRequestId')
  String? get clientRequestId;

  /// 子贴标题
  @BuiltValueField(wireName: r'title')
  String get title;

  /// 子贴正文（kind=BODY，可选，留空仅创建空子贴）
  @BuiltValueField(wireName: r'content')
  String? get content;

  /// 排序序号，越小越靠前
  @BuiltValueField(wireName: r'sortOrder')
  num? get sortOrder;

  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅被标记为玩家的参与人可发帖
  @BuiltValueField(wireName: r'postingPolicy')
  CreateSubthreadDtoPostingPolicyEnum? get postingPolicy;
  // enum postingPolicyEnum {  PARTICIPANTS,  COLLABORATORS,  PLAYERS,  };

  CreateSubthreadDto._();

  factory CreateSubthreadDto([void updates(CreateSubthreadDtoBuilder b)]) = _$CreateSubthreadDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateSubthreadDtoBuilder b) => b
      ..postingPolicy = CreateSubthreadDtoPostingPolicyEnum.valueOf('PARTICIPANTS');

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateSubthreadDto> get serializer => _$CreateSubthreadDtoSerializer();
}

class _$CreateSubthreadDtoSerializer implements PrimitiveSerializer<CreateSubthreadDto> {
  @override
  final Iterable<Type> types = const [CreateSubthreadDto, _$CreateSubthreadDto];

  @override
  final String wireName = r'CreateSubthreadDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateSubthreadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.clientRequestId != null) {
      yield r'clientRequestId';
      yield serializers.serialize(
        object.clientRequestId,
        specifiedType: const FullType(String),
      );
    }
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
    if (object.sortOrder != null) {
      yield r'sortOrder';
      yield serializers.serialize(
        object.sortOrder,
        specifiedType: const FullType(num),
      );
    }
    if (object.postingPolicy != null) {
      yield r'postingPolicy';
      yield serializers.serialize(
        object.postingPolicy,
        specifiedType: const FullType(CreateSubthreadDtoPostingPolicyEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateSubthreadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateSubthreadDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clientRequestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientRequestId = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'sortOrder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.sortOrder = valueDes;
          break;
        case r'postingPolicy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateSubthreadDtoPostingPolicyEnum),
          ) as CreateSubthreadDtoPostingPolicyEnum;
          result.postingPolicy = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateSubthreadDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateSubthreadDtoBuilder();
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

class CreateSubthreadDtoPostingPolicyEnum extends EnumClass {

  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅被标记为玩家的参与人可发帖
  @BuiltValueEnumConst(wireName: r'PARTICIPANTS')
  static const CreateSubthreadDtoPostingPolicyEnum PARTICIPANTS = _$createSubthreadDtoPostingPolicyEnum_PARTICIPANTS;
  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅被标记为玩家的参与人可发帖
  @BuiltValueEnumConst(wireName: r'COLLABORATORS')
  static const CreateSubthreadDtoPostingPolicyEnum COLLABORATORS = _$createSubthreadDtoPostingPolicyEnum_COLLABORATORS;
  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅被标记为玩家的参与人可发帖
  @BuiltValueEnumConst(wireName: r'PLAYERS')
  static const CreateSubthreadDtoPostingPolicyEnum PLAYERS = _$createSubthreadDtoPostingPolicyEnum_PLAYERS;
  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅被标记为玩家的参与人可发帖
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CreateSubthreadDtoPostingPolicyEnum unknownDefaultOpenApi = _$createSubthreadDtoPostingPolicyEnum_unknownDefaultOpenApi;

  static Serializer<CreateSubthreadDtoPostingPolicyEnum> get serializer => _$createSubthreadDtoPostingPolicyEnumSerializer;

  const CreateSubthreadDtoPostingPolicyEnum._(String name): super(name);

  static BuiltSet<CreateSubthreadDtoPostingPolicyEnum> get values => _$createSubthreadDtoPostingPolicyEnumValues;
  static CreateSubthreadDtoPostingPolicyEnum valueOf(String name) => _$createSubthreadDtoPostingPolicyEnumValueOf(name);
}
