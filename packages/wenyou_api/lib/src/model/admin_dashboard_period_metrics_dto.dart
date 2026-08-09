//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_dashboard_period_metrics_dto.g.dart';

/// AdminDashboardPeriodMetricsDto
///
/// Properties:
/// * [activeUsers] - 区间内至少活跃一天的去重普通用户数
/// * [newUsers]
/// * [publishedThreads]
/// * [newPosts] - 新增楼层数，不包含主题正文 BODY
/// * [reportsReceived]
/// * [reportsHandled]
@BuiltValue()
abstract class AdminDashboardPeriodMetricsDto implements Built<AdminDashboardPeriodMetricsDto, AdminDashboardPeriodMetricsDtoBuilder> {
  /// 区间内至少活跃一天的去重普通用户数
  @BuiltValueField(wireName: r'activeUsers')
  num get activeUsers;

  @BuiltValueField(wireName: r'newUsers')
  num get newUsers;

  @BuiltValueField(wireName: r'publishedThreads')
  num get publishedThreads;

  /// 新增楼层数，不包含主题正文 BODY
  @BuiltValueField(wireName: r'newPosts')
  num get newPosts;

  @BuiltValueField(wireName: r'reportsReceived')
  num get reportsReceived;

  @BuiltValueField(wireName: r'reportsHandled')
  num get reportsHandled;

  AdminDashboardPeriodMetricsDto._();

  factory AdminDashboardPeriodMetricsDto([void updates(AdminDashboardPeriodMetricsDtoBuilder b)]) = _$AdminDashboardPeriodMetricsDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDashboardPeriodMetricsDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDashboardPeriodMetricsDto> get serializer => _$AdminDashboardPeriodMetricsDtoSerializer();
}

class _$AdminDashboardPeriodMetricsDtoSerializer implements PrimitiveSerializer<AdminDashboardPeriodMetricsDto> {
  @override
  final Iterable<Type> types = const [AdminDashboardPeriodMetricsDto, _$AdminDashboardPeriodMetricsDto];

  @override
  final String wireName = r'AdminDashboardPeriodMetricsDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDashboardPeriodMetricsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'activeUsers';
    yield serializers.serialize(
      object.activeUsers,
      specifiedType: const FullType(num),
    );
    yield r'newUsers';
    yield serializers.serialize(
      object.newUsers,
      specifiedType: const FullType(num),
    );
    yield r'publishedThreads';
    yield serializers.serialize(
      object.publishedThreads,
      specifiedType: const FullType(num),
    );
    yield r'newPosts';
    yield serializers.serialize(
      object.newPosts,
      specifiedType: const FullType(num),
    );
    yield r'reportsReceived';
    yield serializers.serialize(
      object.reportsReceived,
      specifiedType: const FullType(num),
    );
    yield r'reportsHandled';
    yield serializers.serialize(
      object.reportsHandled,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDashboardPeriodMetricsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDashboardPeriodMetricsDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'activeUsers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.activeUsers = valueDes;
          break;
        case r'newUsers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.newUsers = valueDes;
          break;
        case r'publishedThreads':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.publishedThreads = valueDes;
          break;
        case r'newPosts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.newPosts = valueDes;
          break;
        case r'reportsReceived':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.reportsReceived = valueDes;
          break;
        case r'reportsHandled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.reportsHandled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDashboardPeriodMetricsDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDashboardPeriodMetricsDtoBuilder();
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
