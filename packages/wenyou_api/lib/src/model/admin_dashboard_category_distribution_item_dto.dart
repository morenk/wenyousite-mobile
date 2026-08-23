//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_dashboard_category_distribution_item_dto.g.dart';

/// AdminDashboardCategoryDistributionItemDto
///
/// Properties:
/// * [key]
/// * [count]
/// * [name] - 当前分类名称
/// * [isActive] - 分类当前是否可供新建和筛选选择
@BuiltValue()
abstract class AdminDashboardCategoryDistributionItemDto implements Built<AdminDashboardCategoryDistributionItemDto, AdminDashboardCategoryDistributionItemDtoBuilder> {
  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'count')
  num get count;

  /// 当前分类名称
  @BuiltValueField(wireName: r'name')
  String get name;

  /// 分类当前是否可供新建和筛选选择
  @BuiltValueField(wireName: r'isActive')
  bool get isActive;

  AdminDashboardCategoryDistributionItemDto._();

  factory AdminDashboardCategoryDistributionItemDto([void updates(AdminDashboardCategoryDistributionItemDtoBuilder b)]) = _$AdminDashboardCategoryDistributionItemDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDashboardCategoryDistributionItemDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDashboardCategoryDistributionItemDto> get serializer => _$AdminDashboardCategoryDistributionItemDtoSerializer();
}

class _$AdminDashboardCategoryDistributionItemDtoSerializer implements PrimitiveSerializer<AdminDashboardCategoryDistributionItemDto> {
  @override
  final Iterable<Type> types = const [AdminDashboardCategoryDistributionItemDto, _$AdminDashboardCategoryDistributionItemDto];

  @override
  final String wireName = r'AdminDashboardCategoryDistributionItemDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDashboardCategoryDistributionItemDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(num),
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
    AdminDashboardCategoryDistributionItemDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDashboardCategoryDistributionItemDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
          break;
        case r'count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.count = valueDes;
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
  AdminDashboardCategoryDistributionItemDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDashboardCategoryDistributionItemDtoBuilder();
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
