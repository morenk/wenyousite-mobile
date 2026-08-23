//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_thread_dto.g.dart';

/// UpdateThreadDto
///
/// Properties:
/// * [title]
/// * [category] - 管理员配置的分类 slug；服务端会去除首尾空白并转为大写
/// * [status]
/// * [visibility] - 可见性（PUBLIC=公开, PRIVATE=仅成员）
/// * [published] - 设为 true 发布草稿。发布时校验 title/category 是否填写、是否至少有一个子贴含楼层。发布后通知粉丝
/// * [version] - 乐观锁版本号（必填，前端先 fetch 获取当前 version，过期返回 409）
@BuiltValue()
abstract class UpdateThreadDto implements Built<UpdateThreadDto, UpdateThreadDtoBuilder> {
  @BuiltValueField(wireName: r'title')
  String? get title;

  /// 管理员配置的分类 slug；服务端会去除首尾空白并转为大写
  @BuiltValueField(wireName: r'category')
  String? get category;

  @BuiltValueField(wireName: r'status')
  UpdateThreadDtoStatusEnum? get status;
  // enum statusEnum {  RECRUITING,  CLOSED,  FINISHED,  };

  /// 可见性（PUBLIC=公开, PRIVATE=仅成员）
  @BuiltValueField(wireName: r'visibility')
  UpdateThreadDtoVisibilityEnum? get visibility;
  // enum visibilityEnum {  PUBLIC,  PRIVATE,  };

  /// 设为 true 发布草稿。发布时校验 title/category 是否填写、是否至少有一个子贴含楼层。发布后通知粉丝
  @BuiltValueField(wireName: r'published')
  bool? get published;

  /// 乐观锁版本号（必填，前端先 fetch 获取当前 version，过期返回 409）
  @BuiltValueField(wireName: r'version')
  num get version;

  UpdateThreadDto._();

  factory UpdateThreadDto([void updates(UpdateThreadDtoBuilder b)]) = _$UpdateThreadDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateThreadDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateThreadDto> get serializer => _$UpdateThreadDtoSerializer();
}

class _$UpdateThreadDtoSerializer implements PrimitiveSerializer<UpdateThreadDto> {
  @override
  final Iterable<Type> types = const [UpdateThreadDto, _$UpdateThreadDto];

  @override
  final String wireName = r'UpdateThreadDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateThreadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.category != null) {
      yield r'category';
      yield serializers.serialize(
        object.category,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(UpdateThreadDtoStatusEnum),
      );
    }
    if (object.visibility != null) {
      yield r'visibility';
      yield serializers.serialize(
        object.visibility,
        specifiedType: const FullType(UpdateThreadDtoVisibilityEnum),
      );
    }
    if (object.published != null) {
      yield r'published';
      yield serializers.serialize(
        object.published,
        specifiedType: const FullType(bool),
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
    UpdateThreadDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateThreadDtoBuilder result,
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
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.category = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateThreadDtoStatusEnum),
          ) as UpdateThreadDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'visibility':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateThreadDtoVisibilityEnum),
          ) as UpdateThreadDtoVisibilityEnum;
          result.visibility = valueDes;
          break;
        case r'published':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.published = valueDes;
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
  UpdateThreadDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateThreadDtoBuilder();
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

class UpdateThreadDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'RECRUITING')
  static const UpdateThreadDtoStatusEnum RECRUITING = _$updateThreadDtoStatusEnum_RECRUITING;
  @BuiltValueEnumConst(wireName: r'CLOSED')
  static const UpdateThreadDtoStatusEnum CLOSED = _$updateThreadDtoStatusEnum_CLOSED;
  @BuiltValueEnumConst(wireName: r'FINISHED')
  static const UpdateThreadDtoStatusEnum FINISHED = _$updateThreadDtoStatusEnum_FINISHED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const UpdateThreadDtoStatusEnum unknownDefaultOpenApi = _$updateThreadDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<UpdateThreadDtoStatusEnum> get serializer => _$updateThreadDtoStatusEnumSerializer;

  const UpdateThreadDtoStatusEnum._(String name): super(name);

  static BuiltSet<UpdateThreadDtoStatusEnum> get values => _$updateThreadDtoStatusEnumValues;
  static UpdateThreadDtoStatusEnum valueOf(String name) => _$updateThreadDtoStatusEnumValueOf(name);
}

class UpdateThreadDtoVisibilityEnum extends EnumClass {

  /// 可见性（PUBLIC=公开, PRIVATE=仅成员）
  @BuiltValueEnumConst(wireName: r'PUBLIC')
  static const UpdateThreadDtoVisibilityEnum PUBLIC = _$updateThreadDtoVisibilityEnum_PUBLIC;
  /// 可见性（PUBLIC=公开, PRIVATE=仅成员）
  @BuiltValueEnumConst(wireName: r'PRIVATE')
  static const UpdateThreadDtoVisibilityEnum PRIVATE = _$updateThreadDtoVisibilityEnum_PRIVATE;
  /// 可见性（PUBLIC=公开, PRIVATE=仅成员）
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const UpdateThreadDtoVisibilityEnum unknownDefaultOpenApi = _$updateThreadDtoVisibilityEnum_unknownDefaultOpenApi;

  static Serializer<UpdateThreadDtoVisibilityEnum> get serializer => _$updateThreadDtoVisibilityEnumSerializer;

  const UpdateThreadDtoVisibilityEnum._(String name): super(name);

  static BuiltSet<UpdateThreadDtoVisibilityEnum> get values => _$updateThreadDtoVisibilityEnumValues;
  static UpdateThreadDtoVisibilityEnum valueOf(String name) => _$updateThreadDtoVisibilityEnumValueOf(name);
}
