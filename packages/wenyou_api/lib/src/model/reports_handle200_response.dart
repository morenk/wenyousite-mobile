//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/report_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reports_handle200_response.g.dart';

/// ReportsHandle200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ReportsHandle200Response implements ApiSuccessEnvelope, Built<ReportsHandle200Response, ReportsHandle200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ReportResponseDto get data;

  ReportsHandle200Response._();

  factory ReportsHandle200Response([void updates(ReportsHandle200ResponseBuilder b)]) = _$ReportsHandle200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportsHandle200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportsHandle200Response> get serializer => _$ReportsHandle200ResponseSerializer();
}

class _$ReportsHandle200ResponseSerializer implements PrimitiveSerializer<ReportsHandle200Response> {
  @override
  final Iterable<Type> types = const [ReportsHandle200Response, _$ReportsHandle200Response];

  @override
  final String wireName = r'ReportsHandle200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportsHandle200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ReportResponseDto),
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
    ReportsHandle200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReportsHandle200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReportResponseDto),
          ) as ReportResponseDto;
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
  ReportsHandle200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportsHandle200ResponseBuilder();
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

class ReportsHandle200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ReportsHandle200ResponseCodeEnum number0 = _$reportsHandle200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ReportsHandle200ResponseCodeEnum unknownDefaultOpenApi = _$reportsHandle200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ReportsHandle200ResponseCodeEnum> get serializer => _$reportsHandle200ResponseCodeEnumSerializer;

  const ReportsHandle200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ReportsHandle200ResponseCodeEnum> get values => _$reportsHandle200ResponseCodeEnumValues;
  static ReportsHandle200ResponseCodeEnum valueOf(String name) => _$reportsHandle200ResponseCodeEnumValueOf(name);
}
