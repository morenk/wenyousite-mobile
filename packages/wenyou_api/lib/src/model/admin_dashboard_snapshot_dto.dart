//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_dashboard_snapshot_dto.g.dart';

/// AdminDashboardSnapshotDto
///
/// Properties:
/// * [totalUsers]
/// * [pendingReports]
/// * [activeSuspensions]
/// * [activeBans]
@BuiltValue()
abstract class AdminDashboardSnapshotDto implements Built<AdminDashboardSnapshotDto, AdminDashboardSnapshotDtoBuilder> {
  @BuiltValueField(wireName: r'totalUsers')
  num get totalUsers;

  @BuiltValueField(wireName: r'pendingReports')
  num get pendingReports;

  @BuiltValueField(wireName: r'activeSuspensions')
  num get activeSuspensions;

  @BuiltValueField(wireName: r'activeBans')
  num get activeBans;

  AdminDashboardSnapshotDto._();

  factory AdminDashboardSnapshotDto([void updates(AdminDashboardSnapshotDtoBuilder b)]) = _$AdminDashboardSnapshotDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDashboardSnapshotDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDashboardSnapshotDto> get serializer => _$AdminDashboardSnapshotDtoSerializer();
}

class _$AdminDashboardSnapshotDtoSerializer implements PrimitiveSerializer<AdminDashboardSnapshotDto> {
  @override
  final Iterable<Type> types = const [AdminDashboardSnapshotDto, _$AdminDashboardSnapshotDto];

  @override
  final String wireName = r'AdminDashboardSnapshotDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDashboardSnapshotDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'totalUsers';
    yield serializers.serialize(
      object.totalUsers,
      specifiedType: const FullType(num),
    );
    yield r'pendingReports';
    yield serializers.serialize(
      object.pendingReports,
      specifiedType: const FullType(num),
    );
    yield r'activeSuspensions';
    yield serializers.serialize(
      object.activeSuspensions,
      specifiedType: const FullType(num),
    );
    yield r'activeBans';
    yield serializers.serialize(
      object.activeBans,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDashboardSnapshotDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDashboardSnapshotDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'totalUsers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.totalUsers = valueDes;
          break;
        case r'pendingReports':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.pendingReports = valueDes;
          break;
        case r'activeSuspensions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.activeSuspensions = valueDes;
          break;
        case r'activeBans':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.activeBans = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDashboardSnapshotDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDashboardSnapshotDtoBuilder();
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
