//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_dashboard_timeseries_point_dto.g.dart';

/// AdminDashboardTimeseriesPointDto
///
/// Properties:
/// * [date]
/// * [dau]
/// * [newUsers]
/// * [publishedThreads]
/// * [newPosts]
/// * [reportsReceived]
/// * [reportsHandled]
@BuiltValue()
abstract class AdminDashboardTimeseriesPointDto implements Built<AdminDashboardTimeseriesPointDto, AdminDashboardTimeseriesPointDtoBuilder> {
  @BuiltValueField(wireName: r'date')
  String get date;

  @BuiltValueField(wireName: r'dau')
  num get dau;

  @BuiltValueField(wireName: r'newUsers')
  num get newUsers;

  @BuiltValueField(wireName: r'publishedThreads')
  num get publishedThreads;

  @BuiltValueField(wireName: r'newPosts')
  num get newPosts;

  @BuiltValueField(wireName: r'reportsReceived')
  num get reportsReceived;

  @BuiltValueField(wireName: r'reportsHandled')
  num get reportsHandled;

  AdminDashboardTimeseriesPointDto._();

  factory AdminDashboardTimeseriesPointDto([void updates(AdminDashboardTimeseriesPointDtoBuilder b)]) = _$AdminDashboardTimeseriesPointDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDashboardTimeseriesPointDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDashboardTimeseriesPointDto> get serializer => _$AdminDashboardTimeseriesPointDtoSerializer();
}

class _$AdminDashboardTimeseriesPointDtoSerializer implements PrimitiveSerializer<AdminDashboardTimeseriesPointDto> {
  @override
  final Iterable<Type> types = const [AdminDashboardTimeseriesPointDto, _$AdminDashboardTimeseriesPointDto];

  @override
  final String wireName = r'AdminDashboardTimeseriesPointDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDashboardTimeseriesPointDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(String),
    );
    yield r'dau';
    yield serializers.serialize(
      object.dau,
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
    AdminDashboardTimeseriesPointDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDashboardTimeseriesPointDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.date = valueDes;
          break;
        case r'dau':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.dau = valueDes;
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
  AdminDashboardTimeseriesPointDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDashboardTimeseriesPointDtoBuilder();
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
