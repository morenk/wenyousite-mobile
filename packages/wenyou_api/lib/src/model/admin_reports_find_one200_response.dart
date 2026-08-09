//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/admin_report_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_reports_find_one200_response.g.dart';

/// AdminReportsFindOne200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class AdminReportsFindOne200Response implements ApiSuccessEnvelope, Built<AdminReportsFindOne200Response, AdminReportsFindOne200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AdminReportResponseDto get data;

  AdminReportsFindOne200Response._();

  factory AdminReportsFindOne200Response([void updates(AdminReportsFindOne200ResponseBuilder b)]) = _$AdminReportsFindOne200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminReportsFindOne200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminReportsFindOne200Response> get serializer => _$AdminReportsFindOne200ResponseSerializer();
}

class _$AdminReportsFindOne200ResponseSerializer implements PrimitiveSerializer<AdminReportsFindOne200Response> {
  @override
  final Iterable<Type> types = const [AdminReportsFindOne200Response, _$AdminReportsFindOne200Response];

  @override
  final String wireName = r'AdminReportsFindOne200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminReportsFindOne200Response object, {
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
    AdminReportsFindOne200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminReportsFindOne200ResponseBuilder result,
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
  AdminReportsFindOne200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminReportsFindOne200ResponseBuilder();
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

class AdminReportsFindOne200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const AdminReportsFindOne200ResponseCodeEnum number0 = _$adminReportsFindOne200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const AdminReportsFindOne200ResponseCodeEnum unknownDefaultOpenApi = _$adminReportsFindOne200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<AdminReportsFindOne200ResponseCodeEnum> get serializer => _$adminReportsFindOne200ResponseCodeEnumSerializer;

  const AdminReportsFindOne200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<AdminReportsFindOne200ResponseCodeEnum> get values => _$adminReportsFindOne200ResponseCodeEnumValues;
  static AdminReportsFindOne200ResponseCodeEnum valueOf(String name) => _$adminReportsFindOne200ResponseCodeEnumValueOf(name);
}
