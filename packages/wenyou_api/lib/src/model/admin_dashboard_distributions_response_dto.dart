//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_dashboard_distribution_item_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_dashboard_distributions_response_dto.g.dart';

/// AdminDashboardDistributionsResponseDto
///
/// Properties:
/// * [usersByRole]
/// * [reportsByStatus]
/// * [reportsByReason]
/// * [threadsByCategory]
/// * [activeSanctionsByType]
@BuiltValue()
abstract class AdminDashboardDistributionsResponseDto implements Built<AdminDashboardDistributionsResponseDto, AdminDashboardDistributionsResponseDtoBuilder> {
  @BuiltValueField(wireName: r'usersByRole')
  BuiltList<AdminDashboardDistributionItemDto> get usersByRole;

  @BuiltValueField(wireName: r'reportsByStatus')
  BuiltList<AdminDashboardDistributionItemDto> get reportsByStatus;

  @BuiltValueField(wireName: r'reportsByReason')
  BuiltList<AdminDashboardDistributionItemDto> get reportsByReason;

  @BuiltValueField(wireName: r'threadsByCategory')
  BuiltList<AdminDashboardDistributionItemDto> get threadsByCategory;

  @BuiltValueField(wireName: r'activeSanctionsByType')
  BuiltList<AdminDashboardDistributionItemDto> get activeSanctionsByType;

  AdminDashboardDistributionsResponseDto._();

  factory AdminDashboardDistributionsResponseDto([void updates(AdminDashboardDistributionsResponseDtoBuilder b)]) = _$AdminDashboardDistributionsResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDashboardDistributionsResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDashboardDistributionsResponseDto> get serializer => _$AdminDashboardDistributionsResponseDtoSerializer();
}

class _$AdminDashboardDistributionsResponseDtoSerializer implements PrimitiveSerializer<AdminDashboardDistributionsResponseDto> {
  @override
  final Iterable<Type> types = const [AdminDashboardDistributionsResponseDto, _$AdminDashboardDistributionsResponseDto];

  @override
  final String wireName = r'AdminDashboardDistributionsResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDashboardDistributionsResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'usersByRole';
    yield serializers.serialize(
      object.usersByRole,
      specifiedType: const FullType(BuiltList, [FullType(AdminDashboardDistributionItemDto)]),
    );
    yield r'reportsByStatus';
    yield serializers.serialize(
      object.reportsByStatus,
      specifiedType: const FullType(BuiltList, [FullType(AdminDashboardDistributionItemDto)]),
    );
    yield r'reportsByReason';
    yield serializers.serialize(
      object.reportsByReason,
      specifiedType: const FullType(BuiltList, [FullType(AdminDashboardDistributionItemDto)]),
    );
    yield r'threadsByCategory';
    yield serializers.serialize(
      object.threadsByCategory,
      specifiedType: const FullType(BuiltList, [FullType(AdminDashboardDistributionItemDto)]),
    );
    yield r'activeSanctionsByType';
    yield serializers.serialize(
      object.activeSanctionsByType,
      specifiedType: const FullType(BuiltList, [FullType(AdminDashboardDistributionItemDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDashboardDistributionsResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDashboardDistributionsResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'usersByRole':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminDashboardDistributionItemDto)]),
          ) as BuiltList<AdminDashboardDistributionItemDto>;
          result.usersByRole.replace(valueDes);
          break;
        case r'reportsByStatus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminDashboardDistributionItemDto)]),
          ) as BuiltList<AdminDashboardDistributionItemDto>;
          result.reportsByStatus.replace(valueDes);
          break;
        case r'reportsByReason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminDashboardDistributionItemDto)]),
          ) as BuiltList<AdminDashboardDistributionItemDto>;
          result.reportsByReason.replace(valueDes);
          break;
        case r'threadsByCategory':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminDashboardDistributionItemDto)]),
          ) as BuiltList<AdminDashboardDistributionItemDto>;
          result.threadsByCategory.replace(valueDes);
          break;
        case r'activeSanctionsByType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminDashboardDistributionItemDto)]),
          ) as BuiltList<AdminDashboardDistributionItemDto>;
          result.activeSanctionsByType.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDashboardDistributionsResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDashboardDistributionsResponseDtoBuilder();
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
