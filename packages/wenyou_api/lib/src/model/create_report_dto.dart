//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_report_dto.g.dart';

/// CreateReportDto
///
/// Properties:
/// * [targetType]
/// * [targetId]
/// * [reasonCode]
/// * [details] - 选择 OTHER 时必填
@BuiltValue()
abstract class CreateReportDto implements Built<CreateReportDto, CreateReportDtoBuilder> {
  @BuiltValueField(wireName: r'targetType')
  CreateReportDtoTargetTypeEnum get targetType;
  // enum targetTypeEnum {  USER,  THREAD,  POST,  MOMENT,  MOMENT_COMMENT,  };

  @BuiltValueField(wireName: r'targetId')
  String get targetId;

  @BuiltValueField(wireName: r'reasonCode')
  CreateReportDtoReasonCodeEnum get reasonCode;
  // enum reasonCodeEnum {  SPAM,  HARASSMENT,  HATE_OR_THREATS,  SEXUAL_CONTENT,  VIOLENT_CONTENT,  PERSONAL_INFORMATION,  ILLEGAL_CONTENT,  OTHER,  };

  /// 选择 OTHER 时必填
  @BuiltValueField(wireName: r'details')
  String? get details;

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
      specifiedType: const FullType(CreateReportDtoTargetTypeEnum),
    );
    yield r'targetId';
    yield serializers.serialize(
      object.targetId,
      specifiedType: const FullType(String),
    );
    yield r'reasonCode';
    yield serializers.serialize(
      object.reasonCode,
      specifiedType: const FullType(CreateReportDtoReasonCodeEnum),
    );
    if (object.details != null) {
      yield r'details';
      yield serializers.serialize(
        object.details,
        specifiedType: const FullType(String),
      );
    }
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
            specifiedType: const FullType(CreateReportDtoTargetTypeEnum),
          ) as CreateReportDtoTargetTypeEnum;
          result.targetType = valueDes;
          break;
        case r'targetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetId = valueDes;
          break;
        case r'reasonCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateReportDtoReasonCodeEnum),
          ) as CreateReportDtoReasonCodeEnum;
          result.reasonCode = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.details = valueDes;
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

class CreateReportDtoTargetTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const CreateReportDtoTargetTypeEnum USER = _$createReportDtoTargetTypeEnum_USER;
  @BuiltValueEnumConst(wireName: r'THREAD')
  static const CreateReportDtoTargetTypeEnum THREAD = _$createReportDtoTargetTypeEnum_THREAD;
  @BuiltValueEnumConst(wireName: r'POST')
  static const CreateReportDtoTargetTypeEnum POST = _$createReportDtoTargetTypeEnum_POST;
  @BuiltValueEnumConst(wireName: r'MOMENT')
  static const CreateReportDtoTargetTypeEnum MOMENT = _$createReportDtoTargetTypeEnum_MOMENT;
  @BuiltValueEnumConst(wireName: r'MOMENT_COMMENT')
  static const CreateReportDtoTargetTypeEnum MOMENT_COMMENT = _$createReportDtoTargetTypeEnum_MOMENT_COMMENT;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CreateReportDtoTargetTypeEnum unknownDefaultOpenApi = _$createReportDtoTargetTypeEnum_unknownDefaultOpenApi;

  static Serializer<CreateReportDtoTargetTypeEnum> get serializer => _$createReportDtoTargetTypeEnumSerializer;

  const CreateReportDtoTargetTypeEnum._(String name): super(name);

  static BuiltSet<CreateReportDtoTargetTypeEnum> get values => _$createReportDtoTargetTypeEnumValues;
  static CreateReportDtoTargetTypeEnum valueOf(String name) => _$createReportDtoTargetTypeEnumValueOf(name);
}

class CreateReportDtoReasonCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SPAM')
  static const CreateReportDtoReasonCodeEnum SPAM = _$createReportDtoReasonCodeEnum_SPAM;
  @BuiltValueEnumConst(wireName: r'HARASSMENT')
  static const CreateReportDtoReasonCodeEnum HARASSMENT = _$createReportDtoReasonCodeEnum_HARASSMENT;
  @BuiltValueEnumConst(wireName: r'HATE_OR_THREATS')
  static const CreateReportDtoReasonCodeEnum HATE_OR_THREATS = _$createReportDtoReasonCodeEnum_HATE_OR_THREATS;
  @BuiltValueEnumConst(wireName: r'SEXUAL_CONTENT')
  static const CreateReportDtoReasonCodeEnum SEXUAL_CONTENT = _$createReportDtoReasonCodeEnum_SEXUAL_CONTENT;
  @BuiltValueEnumConst(wireName: r'VIOLENT_CONTENT')
  static const CreateReportDtoReasonCodeEnum VIOLENT_CONTENT = _$createReportDtoReasonCodeEnum_VIOLENT_CONTENT;
  @BuiltValueEnumConst(wireName: r'PERSONAL_INFORMATION')
  static const CreateReportDtoReasonCodeEnum PERSONAL_INFORMATION = _$createReportDtoReasonCodeEnum_PERSONAL_INFORMATION;
  @BuiltValueEnumConst(wireName: r'ILLEGAL_CONTENT')
  static const CreateReportDtoReasonCodeEnum ILLEGAL_CONTENT = _$createReportDtoReasonCodeEnum_ILLEGAL_CONTENT;
  @BuiltValueEnumConst(wireName: r'OTHER')
  static const CreateReportDtoReasonCodeEnum OTHER = _$createReportDtoReasonCodeEnum_OTHER;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const CreateReportDtoReasonCodeEnum unknownDefaultOpenApi = _$createReportDtoReasonCodeEnum_unknownDefaultOpenApi;

  static Serializer<CreateReportDtoReasonCodeEnum> get serializer => _$createReportDtoReasonCodeEnumSerializer;

  const CreateReportDtoReasonCodeEnum._(String name): super(name);

  static BuiltSet<CreateReportDtoReasonCodeEnum> get values => _$createReportDtoReasonCodeEnumValues;
  static CreateReportDtoReasonCodeEnum valueOf(String name) => _$createReportDtoReasonCodeEnumValueOf(name);
}
