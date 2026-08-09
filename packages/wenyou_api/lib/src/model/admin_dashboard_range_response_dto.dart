//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_dashboard_range_response_dto.g.dart';

/// AdminDashboardRangeResponseDto
///
/// Properties:
/// * [from]
/// * [to]
/// * [previousFrom]
/// * [previousTo]
/// * [timezone]
@BuiltValue()
abstract class AdminDashboardRangeResponseDto implements Built<AdminDashboardRangeResponseDto, AdminDashboardRangeResponseDtoBuilder> {
  @BuiltValueField(wireName: r'from')
  String get from;

  @BuiltValueField(wireName: r'to')
  String get to;

  @BuiltValueField(wireName: r'previousFrom')
  String get previousFrom;

  @BuiltValueField(wireName: r'previousTo')
  String get previousTo;

  @BuiltValueField(wireName: r'timezone')
  String get timezone;

  AdminDashboardRangeResponseDto._();

  factory AdminDashboardRangeResponseDto([void updates(AdminDashboardRangeResponseDtoBuilder b)]) = _$AdminDashboardRangeResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDashboardRangeResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDashboardRangeResponseDto> get serializer => _$AdminDashboardRangeResponseDtoSerializer();
}

class _$AdminDashboardRangeResponseDtoSerializer implements PrimitiveSerializer<AdminDashboardRangeResponseDto> {
  @override
  final Iterable<Type> types = const [AdminDashboardRangeResponseDto, _$AdminDashboardRangeResponseDto];

  @override
  final String wireName = r'AdminDashboardRangeResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDashboardRangeResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'from';
    yield serializers.serialize(
      object.from,
      specifiedType: const FullType(String),
    );
    yield r'to';
    yield serializers.serialize(
      object.to,
      specifiedType: const FullType(String),
    );
    yield r'previousFrom';
    yield serializers.serialize(
      object.previousFrom,
      specifiedType: const FullType(String),
    );
    yield r'previousTo';
    yield serializers.serialize(
      object.previousTo,
      specifiedType: const FullType(String),
    );
    yield r'timezone';
    yield serializers.serialize(
      object.timezone,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDashboardRangeResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDashboardRangeResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.from = valueDes;
          break;
        case r'to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.to = valueDes;
          break;
        case r'previousFrom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.previousFrom = valueDes;
          break;
        case r'previousTo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.previousTo = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.timezone = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDashboardRangeResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDashboardRangeResponseDtoBuilder();
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
