//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_dashboard_activity_metrics_dto.g.dart';

/// AdminDashboardActivityMetricsDto
///
/// Properties:
/// * [dau]
/// * [wau]
/// * [mau]
@BuiltValue()
abstract class AdminDashboardActivityMetricsDto implements Built<AdminDashboardActivityMetricsDto, AdminDashboardActivityMetricsDtoBuilder> {
  @BuiltValueField(wireName: r'dau')
  num get dau;

  @BuiltValueField(wireName: r'wau')
  num get wau;

  @BuiltValueField(wireName: r'mau')
  num get mau;

  AdminDashboardActivityMetricsDto._();

  factory AdminDashboardActivityMetricsDto([void updates(AdminDashboardActivityMetricsDtoBuilder b)]) = _$AdminDashboardActivityMetricsDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDashboardActivityMetricsDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDashboardActivityMetricsDto> get serializer => _$AdminDashboardActivityMetricsDtoSerializer();
}

class _$AdminDashboardActivityMetricsDtoSerializer implements PrimitiveSerializer<AdminDashboardActivityMetricsDto> {
  @override
  final Iterable<Type> types = const [AdminDashboardActivityMetricsDto, _$AdminDashboardActivityMetricsDto];

  @override
  final String wireName = r'AdminDashboardActivityMetricsDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDashboardActivityMetricsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'dau';
    yield serializers.serialize(
      object.dau,
      specifiedType: const FullType(num),
    );
    yield r'wau';
    yield serializers.serialize(
      object.wau,
      specifiedType: const FullType(num),
    );
    yield r'mau';
    yield serializers.serialize(
      object.mau,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDashboardActivityMetricsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDashboardActivityMetricsDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dau':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.dau = valueDes;
          break;
        case r'wau':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.wau = valueDes;
          break;
        case r'mau':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.mau = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDashboardActivityMetricsDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDashboardActivityMetricsDtoBuilder();
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
