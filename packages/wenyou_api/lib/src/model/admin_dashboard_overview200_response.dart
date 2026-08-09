//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_dashboard_overview_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_dashboard_overview200_response.g.dart';

/// AdminDashboardOverview200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminDashboardOverview200Response implements ApiSuccessEnvelope, Built<AdminDashboardOverview200Response, AdminDashboardOverview200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminDashboardOverviewResponseDto get data;

  AdminDashboardOverview200Response._();

  factory AdminDashboardOverview200Response([void updates(AdminDashboardOverview200ResponseBuilder b)]) = _$AdminDashboardOverview200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDashboardOverview200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDashboardOverview200Response> get serializer => _$AdminDashboardOverview200ResponseSerializer();
}

class _$AdminDashboardOverview200ResponseSerializer implements PrimitiveSerializer<AdminDashboardOverview200Response> {
  @override
  final Iterable<Type> types = const [AdminDashboardOverview200Response, _$AdminDashboardOverview200Response];

  @override
  final String wireName = r'AdminDashboardOverview200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDashboardOverview200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminDashboardOverviewResponseDto),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDashboardOverview200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDashboardOverview200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminDashboardOverviewResponseDto),
          ) as AdminDashboardOverviewResponseDto;
          result.data.replace(valueDes);
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
          ) as ApiSuccessEnvelopeCodeEnum;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDashboardOverview200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDashboardOverview200ResponseBuilder();
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

class AdminDashboardOverview200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminDashboardOverview200ResponseCodeEnum number0 = _$adminDashboardOverview200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminDashboardOverview200ResponseCodeEnum unknownDefaultOpenApi = _$adminDashboardOverview200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminDashboardOverview200ResponseCodeEnum> get serializer => _$adminDashboardOverview200ResponseCodeEnumSerializer;

  const AdminDashboardOverview200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminDashboardOverview200ResponseCodeEnum> get values => _$adminDashboardOverview200ResponseCodeEnumValues;
  static AdminDashboardOverview200ResponseCodeEnum valueOf(String name) => _$adminDashboardOverview200ResponseCodeEnumValueOf(name);
}
