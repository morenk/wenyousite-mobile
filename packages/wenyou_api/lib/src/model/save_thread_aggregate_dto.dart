//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'save_thread_aggregate_dto.g.dart';

/// SaveThreadAggregateDto
///
/// Properties:
/// * [title]
/// * [category] - 管理员配置的分类 slug；服务端会去除首尾空白并转为大写
/// * [status]
/// * [visibility]
/// * [published] - 仅允许从草稿发布，不允许撤回
/// * [version] - 主题帖乐观锁版本
/// * [defaultSubthreadVersion] - 默认子贴乐观锁版本
/// * [bodyVersion] - 已有默认正文的乐观锁版本
/// * [content] - 默认子贴 Markdown 正文
/// * [tagNames]
@BuiltValue()
abstract class SaveThreadAggregateDto implements Built<SaveThreadAggregateDto, SaveThreadAggregateDtoBuilder> {
  @BuiltValueField(wireName: r'title')
  String? get title;

  /// 管理员配置的分类 slug；服务端会去除首尾空白并转为大写
  @BuiltValueField(wireName: r'category')
  String? get category;

  @BuiltValueField(wireName: r'status')
  SaveThreadAggregateDtoStatusEnum? get status;
  // enum statusEnum {  RECRUITING,  CLOSED,  FINISHED,  };

  @BuiltValueField(wireName: r'visibility')
  SaveThreadAggregateDtoVisibilityEnum? get visibility;
  // enum visibilityEnum {  PUBLIC,  PRIVATE,  };

  /// 仅允许从草稿发布，不允许撤回
  @BuiltValueField(wireName: r'published')
  bool? get published;

  /// 主题帖乐观锁版本
  @BuiltValueField(wireName: r'version')
  num get version;

  /// 默认子贴乐观锁版本
  @BuiltValueField(wireName: r'defaultSubthreadVersion')
  num get defaultSubthreadVersion;

  /// 已有默认正文的乐观锁版本
  @BuiltValueField(wireName: r'bodyVersion')
  num? get bodyVersion;

  /// 默认子贴 Markdown 正文
  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'tagNames')
  BuiltList<String> get tagNames;

  SaveThreadAggregateDto._();

  factory SaveThreadAggregateDto([void updates(SaveThreadAggregateDtoBuilder b)]) = _$SaveThreadAggregateDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SaveThreadAggregateDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SaveThreadAggregateDto> get serializer => _$SaveThreadAggregateDtoSerializer();
}

class _$SaveThreadAggregateDtoSerializer implements PrimitiveSerializer<SaveThreadAggregateDto> {
  @override
  final Iterable<Type> types = const [SaveThreadAggregateDto, _$SaveThreadAggregateDto];

  @override
  final String wireName = r'SaveThreadAggregateDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SaveThreadAggregateDto object, {
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
        specifiedType: const FullType(SaveThreadAggregateDtoStatusEnum),
      );
    }
    if (object.visibility != null) {
      yield r'visibility';
      yield serializers.serialize(
        object.visibility,
        specifiedType: const FullType(SaveThreadAggregateDtoVisibilityEnum),
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
    yield r'defaultSubthreadVersion';
    yield serializers.serialize(
      object.defaultSubthreadVersion,
      specifiedType: const FullType(num),
    );
    if (object.bodyVersion != null) {
      yield r'bodyVersion';
      yield serializers.serialize(
        object.bodyVersion,
        specifiedType: const FullType(num),
      );
    }
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'tagNames';
    yield serializers.serialize(
      object.tagNames,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SaveThreadAggregateDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SaveThreadAggregateDtoBuilder result,
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
            specifiedType: const FullType(SaveThreadAggregateDtoStatusEnum),
          ) as SaveThreadAggregateDtoStatusEnum;
          result.status = valueDes;
          break;
        case r'visibility':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SaveThreadAggregateDtoVisibilityEnum),
          ) as SaveThreadAggregateDtoVisibilityEnum;
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
        case r'defaultSubthreadVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.defaultSubthreadVersion = valueDes;
          break;
        case r'bodyVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.bodyVersion = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'tagNames':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.tagNames.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SaveThreadAggregateDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SaveThreadAggregateDtoBuilder();
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

class SaveThreadAggregateDtoStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'RECRUITING')
  static const SaveThreadAggregateDtoStatusEnum RECRUITING = _$saveThreadAggregateDtoStatusEnum_RECRUITING;
  @BuiltValueEnumConst(wireName: r'CLOSED')
  static const SaveThreadAggregateDtoStatusEnum CLOSED = _$saveThreadAggregateDtoStatusEnum_CLOSED;
  @BuiltValueEnumConst(wireName: r'FINISHED')
  static const SaveThreadAggregateDtoStatusEnum FINISHED = _$saveThreadAggregateDtoStatusEnum_FINISHED;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const SaveThreadAggregateDtoStatusEnum unknownDefaultOpenApi = _$saveThreadAggregateDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<SaveThreadAggregateDtoStatusEnum> get serializer => _$saveThreadAggregateDtoStatusEnumSerializer;

  const SaveThreadAggregateDtoStatusEnum._(String name): super(name);

  static BuiltSet<SaveThreadAggregateDtoStatusEnum> get values => _$saveThreadAggregateDtoStatusEnumValues;
  static SaveThreadAggregateDtoStatusEnum valueOf(String name) => _$saveThreadAggregateDtoStatusEnumValueOf(name);
}

class SaveThreadAggregateDtoVisibilityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PUBLIC')
  static const SaveThreadAggregateDtoVisibilityEnum PUBLIC = _$saveThreadAggregateDtoVisibilityEnum_PUBLIC;
  @BuiltValueEnumConst(wireName: r'PRIVATE')
  static const SaveThreadAggregateDtoVisibilityEnum PRIVATE = _$saveThreadAggregateDtoVisibilityEnum_PRIVATE;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const SaveThreadAggregateDtoVisibilityEnum unknownDefaultOpenApi = _$saveThreadAggregateDtoVisibilityEnum_unknownDefaultOpenApi;

  static Serializer<SaveThreadAggregateDtoVisibilityEnum> get serializer => _$saveThreadAggregateDtoVisibilityEnumSerializer;

  const SaveThreadAggregateDtoVisibilityEnum._(String name): super(name);

  static BuiltSet<SaveThreadAggregateDtoVisibilityEnum> get values => _$saveThreadAggregateDtoVisibilityEnumValues;
  static SaveThreadAggregateDtoVisibilityEnum valueOf(String name) => _$saveThreadAggregateDtoVisibilityEnumValueOf(name);
}
