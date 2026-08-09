//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sanction_user_dto.g.dart';

/// SanctionUserDto
///
/// Properties:
/// * [type]
/// * [reason]
/// * [endsAt] - 暂停结束时间；永久封禁时不得传入
@BuiltValue()
abstract class SanctionUserDto implements Built<SanctionUserDto, SanctionUserDtoBuilder> {
  @BuiltValueField(wireName: r'type')
  SanctionUserDtoTypeEnum get type;
  // enum typeEnum {  SUSPENSION,  BAN,  };

  @BuiltValueField(wireName: r'reason')
  String get reason;

  /// 暂停结束时间；永久封禁时不得传入
  @BuiltValueField(wireName: r'endsAt')
  DateTime? get endsAt;

  SanctionUserDto._();

  factory SanctionUserDto([void updates(SanctionUserDtoBuilder b)]) = _$SanctionUserDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SanctionUserDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SanctionUserDto> get serializer => _$SanctionUserDtoSerializer();
}

class _$SanctionUserDtoSerializer implements PrimitiveSerializer<SanctionUserDto> {
  @override
  final Iterable<Type> types = const [SanctionUserDto, _$SanctionUserDto];

  @override
  final String wireName = r'SanctionUserDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SanctionUserDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(SanctionUserDtoTypeEnum),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    if (object.endsAt != null) {
      yield r'endsAt';
      yield serializers.serialize(
        object.endsAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SanctionUserDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SanctionUserDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SanctionUserDtoTypeEnum),
          ) as SanctionUserDtoTypeEnum;
          result.type = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'endsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endsAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SanctionUserDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SanctionUserDtoBuilder();
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

class SanctionUserDtoTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SUSPENSION')
  static const SanctionUserDtoTypeEnum SUSPENSION = _$sanctionUserDtoTypeEnum_SUSPENSION;
  @BuiltValueEnumConst(wireName: r'BAN')
  static const SanctionUserDtoTypeEnum BAN = _$sanctionUserDtoTypeEnum_BAN;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const SanctionUserDtoTypeEnum unknownDefaultOpenApi = _$sanctionUserDtoTypeEnum_unknownDefaultOpenApi;

  static Serializer<SanctionUserDtoTypeEnum> get serializer => _$sanctionUserDtoTypeEnumSerializer;

  const SanctionUserDtoTypeEnum._(String name): super(name);

  static BuiltSet<SanctionUserDtoTypeEnum> get values => _$sanctionUserDtoTypeEnumValues;
  static SanctionUserDtoTypeEnum valueOf(String name) => _$sanctionUserDtoTypeEnumValueOf(name);
}
