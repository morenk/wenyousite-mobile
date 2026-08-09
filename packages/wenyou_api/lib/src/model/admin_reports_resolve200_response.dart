//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_report_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_reports_resolve200_response.g.dart';

/// AdminReportsResolve200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminReportsResolve200Response implements ApiSuccessEnvelope, Built<AdminReportsResolve200Response, AdminReportsResolve200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminReportResponseDto get data;

  AdminReportsResolve200Response._();

  factory AdminReportsResolve200Response([void updates(AdminReportsResolve200ResponseBuilder b)]) = _$AdminReportsResolve200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminReportsResolve200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminReportsResolve200Response> get serializer => _$AdminReportsResolve200ResponseSerializer();
}

class _$AdminReportsResolve200ResponseSerializer implements PrimitiveSerializer<AdminReportsResolve200Response> {
  @override
  final Iterable<Type> types = const [AdminReportsResolve200Response, _$AdminReportsResolve200Response];

  @override
  final String wireName = r'AdminReportsResolve200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminReportsResolve200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AdminReportResponseDto),
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
    AdminReportsResolve200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminReportsResolve200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminReportResponseDto),
          ) as AdminReportResponseDto;
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
  AdminReportsResolve200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminReportsResolve200ResponseBuilder();
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

class AdminReportsResolve200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminReportsResolve200ResponseCodeEnum number0 = _$adminReportsResolve200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminReportsResolve200ResponseCodeEnum unknownDefaultOpenApi = _$adminReportsResolve200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminReportsResolve200ResponseCodeEnum> get serializer => _$adminReportsResolve200ResponseCodeEnumSerializer;

  const AdminReportsResolve200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminReportsResolve200ResponseCodeEnum> get values => _$adminReportsResolve200ResponseCodeEnumValues;
  static AdminReportsResolve200ResponseCodeEnum valueOf(String name) => _$adminReportsResolve200ResponseCodeEnumValueOf(name);
}
