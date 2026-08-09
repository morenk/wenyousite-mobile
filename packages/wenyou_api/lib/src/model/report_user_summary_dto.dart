//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'report_user_summary_dto.g.dart';

/// ReportUserSummaryDto
///
/// Properties:
/// * [id]
/// * [username]
/// * [role]
@BuiltValue()
abstract class ReportUserSummaryDto implements Built<ReportUserSummaryDto, ReportUserSummaryDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'role')
  ReportUserSummaryDtoRoleEnum get role;
  // enum roleEnum {  USER,  ADMIN,  SUPER_ADMIN,  };

  ReportUserSummaryDto._();

  factory ReportUserSummaryDto([void updates(ReportUserSummaryDtoBuilder b)]) = _$ReportUserSummaryDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportUserSummaryDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportUserSummaryDto> get serializer => _$ReportUserSummaryDtoSerializer();
}

class _$ReportUserSummaryDtoSerializer implements PrimitiveSerializer<ReportUserSummaryDto> {
  @override
  final Iterable<Type> types = const [ReportUserSummaryDto, _$ReportUserSummaryDto];

  @override
  final String wireName = r'ReportUserSummaryDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportUserSummaryDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(ReportUserSummaryDtoRoleEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReportUserSummaryDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReportUserSummaryDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReportUserSummaryDtoRoleEnum),
          ) as ReportUserSummaryDtoRoleEnum;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReportUserSummaryDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportUserSummaryDtoBuilder();
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

class ReportUserSummaryDtoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'USER')
  static const ReportUserSummaryDtoRoleEnum USER = _$reportUserSummaryDtoRoleEnum_USER;
  @BuiltValueEnumConst(wireName: r'ADMIN')
  static const ReportUserSummaryDtoRoleEnum ADMIN = _$reportUserSummaryDtoRoleEnum_ADMIN;
  @BuiltValueEnumConst(wireName: r'SUPER_ADMIN')
  static const ReportUserSummaryDtoRoleEnum SUPER_ADMIN = _$reportUserSummaryDtoRoleEnum_SUPER_ADMIN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const ReportUserSummaryDtoRoleEnum unknownDefaultOpenApi = _$reportUserSummaryDtoRoleEnum_unknownDefaultOpenApi;

  static Serializer<ReportUserSummaryDtoRoleEnum> get serializer => _$reportUserSummaryDtoRoleEnumSerializer;

  const ReportUserSummaryDtoRoleEnum._(String name): super(name);

  static BuiltSet<ReportUserSummaryDtoRoleEnum> get values => _$reportUserSummaryDtoRoleEnumValues;
  static ReportUserSummaryDtoRoleEnum valueOf(String name) => _$reportUserSummaryDtoRoleEnumValueOf(name);
}
