//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_report_dto.g.dart';

/// CreateReportDto
///
/// Properties:
/// * [targetType] - 举报目标类型
/// * [targetId] - 举报目标 ID
/// * [reason] - 举报原因
@BuiltValue()
abstract class CreateReportDto implements Built<CreateReportDto, CreateReportDtoBuilder> {
  /// 举报目标类型
  @BuiltValueField(wireName: r'targetType')
  String get targetType;

  /// 举报目标 ID
  @BuiltValueField(wireName: r'targetId')
  String get targetId;

  /// 举报原因
  @BuiltValueField(wireName: r'reason')
  String get reason;

  CreateReportDto._();

  factory CreateReportDto([void updates(CreateReportDtoBuilder b)]) = _$CreateReportDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateReportDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateReportDto> get serializer => _$CreateReportDtoSerializer();
}

class _$CreateReportDtoSerializer implements PrimitiveSerializer<CreateReportDto> {
  @override
  final Iterable<Type> types = const [CreateReportDto, _$CreateReportDto];

  @override
  final String wireName = r'CreateReportDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateReportDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'targetType';
    yield serializers.serialize(
      object.targetType,
      specifiedType: const FullType(String),
    );
    yield r'targetId';
    yield serializers.serialize(
      object.targetId,
      specifiedType: const FullType(String),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateReportDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateReportDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'targetType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetType = valueDes;
          break;
        case r'targetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetId = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateReportDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateReportDtoBuilder();
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
