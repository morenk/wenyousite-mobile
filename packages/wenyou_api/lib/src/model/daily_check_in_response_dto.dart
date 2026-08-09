//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/progression_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'daily_check_in_response_dto.g.dart';

/// DailyCheckInResponseDto
///
/// Properties:
/// * [claimedNow] - true 仅表示本次请求实际完成领取
/// * [date]
/// * [rewardAmount]
/// * [experienceAwarded]
/// * [balance]
/// * [progression]
@BuiltValue()
abstract class DailyCheckInResponseDto implements Built<DailyCheckInResponseDto, DailyCheckInResponseDtoBuilder> {
  /// true 仅表示本次请求实际完成领取
  @BuiltValueField(wireName: r'claimedNow')
  bool get claimedNow;

  @BuiltValueField(wireName: r'date')
  String get date;

  @BuiltValueField(wireName: r'rewardAmount')
  DailyCheckInResponseDtoRewardAmountEnum get rewardAmount;
  // enum rewardAmountEnum {  1,  2,  3,  };

  @BuiltValueField(wireName: r'experienceAwarded')
  num get experienceAwarded;

  @BuiltValueField(wireName: r'balance')
  String get balance;

  @BuiltValueField(wireName: r'progression')
  ProgressionResponseDto get progression;

  DailyCheckInResponseDto._();

  factory DailyCheckInResponseDto([void updates(DailyCheckInResponseDtoBuilder b)]) = _$DailyCheckInResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DailyCheckInResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DailyCheckInResponseDto> get serializer => _$DailyCheckInResponseDtoSerializer();
}

class _$DailyCheckInResponseDtoSerializer implements PrimitiveSerializer<DailyCheckInResponseDto> {
  @override
  final Iterable<Type> types = const [DailyCheckInResponseDto, _$DailyCheckInResponseDto];

  @override
  final String wireName = r'DailyCheckInResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DailyCheckInResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'claimedNow';
    yield serializers.serialize(
      object.claimedNow,
      specifiedType: const FullType(bool),
    );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(String),
    );
    yield r'rewardAmount';
    yield serializers.serialize(
      object.rewardAmount,
      specifiedType: const FullType(DailyCheckInResponseDtoRewardAmountEnum),
    );
    yield r'experienceAwarded';
    yield serializers.serialize(
      object.experienceAwarded,
      specifiedType: const FullType(num),
    );
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
    yield r'progression';
    yield serializers.serialize(
      object.progression,
      specifiedType: const FullType(ProgressionResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DailyCheckInResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DailyCheckInResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'claimedNow':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.claimedNow = valueDes;
          break;
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.date = valueDes;
          break;
        case r'rewardAmount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DailyCheckInResponseDtoRewardAmountEnum),
          ) as DailyCheckInResponseDtoRewardAmountEnum;
          result.rewardAmount = valueDes;
          break;
        case r'experienceAwarded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.experienceAwarded = valueDes;
          break;
        case r'balance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.balance = valueDes;
          break;
        case r'progression':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProgressionResponseDto),
          ) as ProgressionResponseDto;
          result.progression.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DailyCheckInResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DailyCheckInResponseDtoBuilder();
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

class DailyCheckInResponseDtoRewardAmountEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'1')
  static const DailyCheckInResponseDtoRewardAmountEnum n1 = _$dailyCheckInResponseDtoRewardAmountEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const DailyCheckInResponseDtoRewardAmountEnum n2 = _$dailyCheckInResponseDtoRewardAmountEnum_n2;
  @BuiltValueEnumConst(wireName: r'3')
  static const DailyCheckInResponseDtoRewardAmountEnum n3 = _$dailyCheckInResponseDtoRewardAmountEnum_n3;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const DailyCheckInResponseDtoRewardAmountEnum unknownDefaultOpenApi = _$dailyCheckInResponseDtoRewardAmountEnum_unknownDefaultOpenApi;

  static Serializer<DailyCheckInResponseDtoRewardAmountEnum> get serializer => _$dailyCheckInResponseDtoRewardAmountEnumSerializer;

  const DailyCheckInResponseDtoRewardAmountEnum._(String name): super(name);

  static BuiltSet<DailyCheckInResponseDtoRewardAmountEnum> get values => _$dailyCheckInResponseDtoRewardAmountEnumValues;
  static DailyCheckInResponseDtoRewardAmountEnum valueOf(String name) => _$dailyCheckInResponseDtoRewardAmountEnumValueOf(name);
}
