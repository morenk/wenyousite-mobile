//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_subthread_dto.g.dart';

/// UpdateSubthreadDto
///
/// Properties:
/// * [title] - 子贴标题
/// * [sortOrder] - 排序序号（仅非默认子贴可修改）
/// * [postingPolicy] - PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅玩家可发帖
/// * [version] - 乐观锁版本号（必填，过期返回 409）
@BuiltValue()
abstract class UpdateSubthreadDto implements Built<UpdateSubthreadDto, UpdateSubthreadDtoBuilder> {
  /// 子贴标题
  @BuiltValueField(wireName: r'title')
  String? get title;

  /// 排序序号（仅非默认子贴可修改）
  @BuiltValueField(wireName: r'sortOrder')
  num? get sortOrder;

  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅玩家可发帖
  @BuiltValueField(wireName: r'postingPolicy')
  UpdateSubthreadDtoPostingPolicyEnum? get postingPolicy;
  // enum postingPolicyEnum {  PARTICIPANTS,  COLLABORATORS,  PLAYERS,  };

  /// 乐观锁版本号（必填，过期返回 409）
  @BuiltValueField(wireName: r'version')
  num get version;

  UpdateSubthreadDto._();

  factory UpdateSubthreadDto([void updates(UpdateSubthreadDtoBuilder b)]) = _$UpdateSubthreadDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateSubthreadDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateSubthreadDto> get serializer => _$UpdateSubthreadDtoSerializer();
}

class _$UpdateSubthreadDtoSerializer implements PrimitiveSerializer<UpdateSubthreadDto> {
  @override
  final Iterable<Type> types = const [UpdateSubthreadDto, _$UpdateSubthreadDto];

  @override
  final String wireName = r'UpdateSubthreadDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateSubthreadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
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
        specifiedType: const FullType(UpdateSubthreadDtoPostingPolicyEnum),
      );
    }
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateSubthreadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateSubthreadDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
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
            specifiedType: const FullType(UpdateSubthreadDtoPostingPolicyEnum),
          ) as UpdateSubthreadDtoPostingPolicyEnum;
          result.postingPolicy = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateSubthreadDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateSubthreadDtoBuilder();
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

class UpdateSubthreadDtoPostingPolicyEnum extends EnumClass {

  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅玩家可发帖
  @BuiltValueEnumConst(wireName: r'PARTICIPANTS')
  static const UpdateSubthreadDtoPostingPolicyEnum PARTICIPANTS = _$updateSubthreadDtoPostingPolicyEnum_PARTICIPANTS;
  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅玩家可发帖
  @BuiltValueEnumConst(wireName: r'COLLABORATORS')
  static const UpdateSubthreadDtoPostingPolicyEnum COLLABORATORS = _$updateSubthreadDtoPostingPolicyEnum_COLLABORATORS;
  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅玩家可发帖
  @BuiltValueEnumConst(wireName: r'PLAYERS')
  static const UpdateSubthreadDtoPostingPolicyEnum PLAYERS = _$updateSubthreadDtoPostingPolicyEnum_PLAYERS;
  /// PARTICIPANTS=所有参与人可发帖, COLLABORATORS=仅协作者可发帖, PLAYERS=仅玩家可发帖
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const UpdateSubthreadDtoPostingPolicyEnum unknownDefaultOpenApi = _$updateSubthreadDtoPostingPolicyEnum_unknownDefaultOpenApi;

  static Serializer<UpdateSubthreadDtoPostingPolicyEnum> get serializer => _$updateSubthreadDtoPostingPolicyEnumSerializer;

  const UpdateSubthreadDtoPostingPolicyEnum._(String name): super(name);

  static BuiltSet<UpdateSubthreadDtoPostingPolicyEnum> get values => _$updateSubthreadDtoPostingPolicyEnumValues;
  static UpdateSubthreadDtoPostingPolicyEnum valueOf(String name) => _$updateSubthreadDtoPostingPolicyEnumValueOf(name);
}
