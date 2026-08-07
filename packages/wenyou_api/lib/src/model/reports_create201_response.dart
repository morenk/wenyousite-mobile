//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/report_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reports_create201_response.g.dart';

/// ReportsCreate201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ReportsCreate201Response implements ApiSuccessEnvelope, Built<ReportsCreate201Response, ReportsCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ReportResponseDto get data;

  ReportsCreate201Response._();

  factory ReportsCreate201Response([void updates(ReportsCreate201ResponseBuilder b)]) = _$ReportsCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportsCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportsCreate201Response> get serializer => _$ReportsCreate201ResponseSerializer();
}

class _$ReportsCreate201ResponseSerializer implements PrimitiveSerializer<ReportsCreate201Response> {
  @override
  final Iterable<Type> types = const [ReportsCreate201Response, _$ReportsCreate201Response];

  @override
  final String wireName = r'ReportsCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportsCreate201Response object, {
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
    ReportsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReportsCreate201ResponseBuilder result,
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
  ReportsCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportsCreate201ResponseBuilder();
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

class ReportsCreate201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ReportsCreate201ResponseCodeEnum number0 = _$reportsCreate201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ReportsCreate201ResponseCodeEnum unknownDefaultOpenApi = _$reportsCreate201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ReportsCreate201ResponseCodeEnum> get serializer => _$reportsCreate201ResponseCodeEnumSerializer;

  const ReportsCreate201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ReportsCreate201ResponseCodeEnum> get values => _$reportsCreate201ResponseCodeEnumValues;
  static ReportsCreate201ResponseCodeEnum valueOf(String name) => _$reportsCreate201ResponseCodeEnumValueOf(name);
}
