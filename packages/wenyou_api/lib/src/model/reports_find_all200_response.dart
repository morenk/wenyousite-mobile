//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/report_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reports_find_all200_response.g.dart';

/// ReportsFindAll200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ReportsFindAll200Response implements ApiSuccessEnvelope, Built<ReportsFindAll200Response, ReportsFindAll200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ReportResponseDto> get data;

  ReportsFindAll200Response._();

  factory ReportsFindAll200Response([void updates(ReportsFindAll200ResponseBuilder b)]) = _$ReportsFindAll200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportsFindAll200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportsFindAll200Response> get serializer => _$ReportsFindAll200ResponseSerializer();
}

class _$ReportsFindAll200ResponseSerializer implements PrimitiveSerializer<ReportsFindAll200Response> {
  @override
  final Iterable<Type> types = const [ReportsFindAll200Response, _$ReportsFindAll200Response];

  @override
  final String wireName = r'ReportsFindAll200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(ReportResponseDto)]),
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
    ReportsFindAll200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReportsFindAll200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ReportResponseDto)]),
          ) as BuiltList<ReportResponseDto>;
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
  ReportsFindAll200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportsFindAll200ResponseBuilder();
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

class ReportsFindAll200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ReportsFindAll200ResponseCodeEnum number0 = _$reportsFindAll200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ReportsFindAll200ResponseCodeEnum unknownDefaultOpenApi = _$reportsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ReportsFindAll200ResponseCodeEnum> get serializer => _$reportsFindAll200ResponseCodeEnumSerializer;

  const ReportsFindAll200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ReportsFindAll200ResponseCodeEnum> get values => _$reportsFindAll200ResponseCodeEnumValues;
  static ReportsFindAll200ResponseCodeEnum valueOf(String name) => _$reportsFindAll200ResponseCodeEnumValueOf(name);
}
