//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_dashboard_range_response_dto.dart';
import 'package:wenyou_api/src/model/admin_dashboard_period_metrics_dto.dart';
import 'package:wenyou_api/src/model/admin_dashboard_snapshot_dto.dart';
import 'package:wenyou_api/src/model/admin_dashboard_activity_metrics_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_dashboard_overview_response_dto.g.dart';

/// AdminDashboardOverviewResponseDto
///
/// Properties:
/// * [range]
/// * [activity]
/// * [current]
/// * [previous]
/// * [snapshot]
@BuiltValue()
abstract class AdminDashboardOverviewResponseDto implements Built<AdminDashboardOverviewResponseDto, AdminDashboardOverviewResponseDtoBuilder> {
  @BuiltValueField(wireName: r'range')
  AdminDashboardRangeResponseDto get range;

  @BuiltValueField(wireName: r'activity')
  AdminDashboardActivityMetricsDto get activity;

  @BuiltValueField(wireName: r'current')
  AdminDashboardPeriodMetricsDto get current;

  @BuiltValueField(wireName: r'previous')
  AdminDashboardPeriodMetricsDto get previous;

  @BuiltValueField(wireName: r'snapshot')
  AdminDashboardSnapshotDto get snapshot;

  AdminDashboardOverviewResponseDto._();

  factory AdminDashboardOverviewResponseDto([void updates(AdminDashboardOverviewResponseDtoBuilder b)]) = _$AdminDashboardOverviewResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDashboardOverviewResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDashboardOverviewResponseDto> get serializer => _$AdminDashboardOverviewResponseDtoSerializer();
}

class _$AdminDashboardOverviewResponseDtoSerializer implements PrimitiveSerializer<AdminDashboardOverviewResponseDto> {
  @override
  final Iterable<Type> types = const [AdminDashboardOverviewResponseDto, _$AdminDashboardOverviewResponseDto];

  @override
  final String wireName = r'AdminDashboardOverviewResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDashboardOverviewResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'range';
    yield serializers.serialize(
      object.range,
      specifiedType: const FullType(AdminDashboardRangeResponseDto),
    );
    yield r'activity';
    yield serializers.serialize(
      object.activity,
      specifiedType: const FullType(AdminDashboardActivityMetricsDto),
    );
    yield r'current';
    yield serializers.serialize(
      object.current,
      specifiedType: const FullType(AdminDashboardPeriodMetricsDto),
    );
    yield r'previous';
    yield serializers.serialize(
      object.previous,
      specifiedType: const FullType(AdminDashboardPeriodMetricsDto),
    );
    yield r'snapshot';
    yield serializers.serialize(
      object.snapshot,
      specifiedType: const FullType(AdminDashboardSnapshotDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDashboardOverviewResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDashboardOverviewResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'range':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminDashboardRangeResponseDto),
          ) as AdminDashboardRangeResponseDto;
          result.range.replace(valueDes);
          break;
        case r'activity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminDashboardActivityMetricsDto),
          ) as AdminDashboardActivityMetricsDto;
          result.activity.replace(valueDes);
          break;
        case r'current':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminDashboardPeriodMetricsDto),
          ) as AdminDashboardPeriodMetricsDto;
          result.current.replace(valueDes);
          break;
        case r'previous':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminDashboardPeriodMetricsDto),
          ) as AdminDashboardPeriodMetricsDto;
          result.previous.replace(valueDes);
          break;
        case r'snapshot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminDashboardSnapshotDto),
          ) as AdminDashboardSnapshotDto;
          result.snapshot.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDashboardOverviewResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDashboardOverviewResponseDtoBuilder();
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
