//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/admin_dashboard_range_response_dto.dart';
import 'package:wenyou_api/src/model/admin_dashboard_timeseries_point_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_dashboard_timeseries_response_dto.g.dart';

/// AdminDashboardTimeseriesResponseDto
///
/// Properties:
/// * [range]
/// * [items]
@BuiltValue()
abstract class AdminDashboardTimeseriesResponseDto implements Built<AdminDashboardTimeseriesResponseDto, AdminDashboardTimeseriesResponseDtoBuilder> {
  @BuiltValueField(wireName: r'range')
  AdminDashboardRangeResponseDto get range;

  @BuiltValueField(wireName: r'items')
  BuiltList<AdminDashboardTimeseriesPointDto> get items;

  AdminDashboardTimeseriesResponseDto._();

  factory AdminDashboardTimeseriesResponseDto([void updates(AdminDashboardTimeseriesResponseDtoBuilder b)]) = _$AdminDashboardTimeseriesResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDashboardTimeseriesResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDashboardTimeseriesResponseDto> get serializer => _$AdminDashboardTimeseriesResponseDtoSerializer();
}

class _$AdminDashboardTimeseriesResponseDtoSerializer implements PrimitiveSerializer<AdminDashboardTimeseriesResponseDto> {
  @override
  final Iterable<Type> types = const [AdminDashboardTimeseriesResponseDto, _$AdminDashboardTimeseriesResponseDto];

  @override
  final String wireName = r'AdminDashboardTimeseriesResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDashboardTimeseriesResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'range';
    yield serializers.serialize(
      object.range,
      specifiedType: const FullType(AdminDashboardRangeResponseDto),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(AdminDashboardTimeseriesPointDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDashboardTimeseriesResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDashboardTimeseriesResponseDtoBuilder result,
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
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminDashboardTimeseriesPointDto)]),
          ) as BuiltList<AdminDashboardTimeseriesPointDto>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDashboardTimeseriesResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDashboardTimeseriesResponseDtoBuilder();
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
