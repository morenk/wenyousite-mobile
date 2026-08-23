//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_category_info_dto.g.dart';

/// ThreadCategoryInfoDto
///
/// Properties:
/// * [slug]
/// * [name] - 分类注册表中的当前名称
/// * [isActive] - 当前是否允许新主题选择该分类
@BuiltValue()
abstract class ThreadCategoryInfoDto implements Built<ThreadCategoryInfoDto, ThreadCategoryInfoDtoBuilder> {
  @BuiltValueField(wireName: r'slug')
  String get slug;

  /// 分类注册表中的当前名称
  @BuiltValueField(wireName: r'name')
  String get name;

  /// 当前是否允许新主题选择该分类
  @BuiltValueField(wireName: r'isActive')
  bool get isActive;

  ThreadCategoryInfoDto._();

  factory ThreadCategoryInfoDto([void updates(ThreadCategoryInfoDtoBuilder b)]) = _$ThreadCategoryInfoDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadCategoryInfoDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadCategoryInfoDto> get serializer => _$ThreadCategoryInfoDtoSerializer();
}

class _$ThreadCategoryInfoDtoSerializer implements PrimitiveSerializer<ThreadCategoryInfoDto> {
  @override
  final Iterable<Type> types = const [ThreadCategoryInfoDto, _$ThreadCategoryInfoDto];

  @override
  final String wireName = r'ThreadCategoryInfoDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadCategoryInfoDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slug';
    yield serializers.serialize(
      object.slug,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'isActive';
    yield serializers.serialize(
      object.isActive,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ThreadCategoryInfoDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadCategoryInfoDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slug':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.slug = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'isActive':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isActive = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ThreadCategoryInfoDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadCategoryInfoDtoBuilder();
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
