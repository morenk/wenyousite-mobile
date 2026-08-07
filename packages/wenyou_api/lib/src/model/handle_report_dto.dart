//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'handle_report_dto.g.dart';

/// HandleReportDto
///
/// Properties:
/// * [status] - 处理状态
@BuiltValue()
abstract class HandleReportDto implements Built<HandleReportDto, HandleReportDtoBuilder> {
  /// 处理状态
  @BuiltValueField(wireName: r'status')
  HandleReportDtoStatusEnum get status;
  // enum statusEnum {  RESOLVED,  DISMISSED,  };

  HandleReportDto._();

  factory HandleReportDto([void updates(HandleReportDtoBuilder b)]) = _$HandleReportDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HandleReportDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HandleReportDto> get serializer => _$HandleReportDtoSerializer();
}

class _$HandleReportDtoSerializer implements PrimitiveSerializer<HandleReportDto> {
  @override
  final Iterable<Type> types = const [HandleReportDto, _$HandleReportDto];

  @override
  final String wireName = r'HandleReportDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HandleReportDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(HandleReportDtoStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HandleReportDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HandleReportDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HandleReportDtoStatusEnum),
          ) as HandleReportDtoStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HandleReportDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HandleReportDtoBuilder();
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

class HandleReportDtoStatusEnum extends EnumClass {

  /// 处理状态
  @BuiltValueEnumConst(wireName: r'RESOLVED')
  static const HandleReportDtoStatusEnum RESOLVED = _$handleReportDtoStatusEnum_RESOLVED;
  /// 处理状态
  @BuiltValueEnumConst(wireName: r'DISMISSED')
  static const HandleReportDtoStatusEnum DISMISSED = _$handleReportDtoStatusEnum_DISMISSED;
  /// 处理状态
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const HandleReportDtoStatusEnum unknownDefaultOpenApi = _$handleReportDtoStatusEnum_unknownDefaultOpenApi;

  static Serializer<HandleReportDtoStatusEnum> get serializer => _$handleReportDtoStatusEnumSerializer;

  const HandleReportDtoStatusEnum._(String name): super(name);

  static BuiltSet<HandleReportDtoStatusEnum> get values => _$handleReportDtoStatusEnumValues;
  static HandleReportDtoStatusEnum valueOf(String name) => _$handleReportDtoStatusEnumValueOf(name);
}
