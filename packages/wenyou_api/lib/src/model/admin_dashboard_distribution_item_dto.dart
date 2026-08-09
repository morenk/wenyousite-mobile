//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_dashboard_distribution_item_dto.g.dart';

/// AdminDashboardDistributionItemDto
///
/// Properties:
/// * [key]
/// * [count]
@BuiltValue()
abstract class AdminDashboardDistributionItemDto implements Built<AdminDashboardDistributionItemDto, AdminDashboardDistributionItemDtoBuilder> {
  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'count')
  num get count;

  AdminDashboardDistributionItemDto._();

  factory AdminDashboardDistributionItemDto([void updates(AdminDashboardDistributionItemDtoBuilder b)]) = _$AdminDashboardDistributionItemDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDashboardDistributionItemDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDashboardDistributionItemDto> get serializer => _$AdminDashboardDistributionItemDtoSerializer();
}

class _$AdminDashboardDistributionItemDtoSerializer implements PrimitiveSerializer<AdminDashboardDistributionItemDto> {
  @override
  final Iterable<Type> types = const [AdminDashboardDistributionItemDto, _$AdminDashboardDistributionItemDto];

  @override
  final String wireName = r'AdminDashboardDistributionItemDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDashboardDistributionItemDto object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDashboardDistributionItemDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDashboardDistributionItemDtoBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDashboardDistributionItemDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDashboardDistributionItemDtoBuilder();
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
