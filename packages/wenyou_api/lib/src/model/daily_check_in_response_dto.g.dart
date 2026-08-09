// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_check_in_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DailyCheckInResponseDtoRewardAmountEnum
_$dailyCheckInResponseDtoRewardAmountEnum_n1 =
    const DailyCheckInResponseDtoRewardAmountEnum._('n1');
const DailyCheckInResponseDtoRewardAmountEnum
_$dailyCheckInResponseDtoRewardAmountEnum_n2 =
    const DailyCheckInResponseDtoRewardAmountEnum._('n2');
const DailyCheckInResponseDtoRewardAmountEnum
_$dailyCheckInResponseDtoRewardAmountEnum_n3 =
    const DailyCheckInResponseDtoRewardAmountEnum._('n3');
const DailyCheckInResponseDtoRewardAmountEnum
_$dailyCheckInResponseDtoRewardAmountEnum_unknownDefaultOpenApi =
    const DailyCheckInResponseDtoRewardAmountEnum._('unknownDefaultOpenApi');

DailyCheckInResponseDtoRewardAmountEnum
_$dailyCheckInResponseDtoRewardAmountEnumValueOf(String name) {
  switch (name) {
    case 'n1':
      return _$dailyCheckInResponseDtoRewardAmountEnum_n1;
    case 'n2':
      return _$dailyCheckInResponseDtoRewardAmountEnum_n2;
    case 'n3':
      return _$dailyCheckInResponseDtoRewardAmountEnum_n3;
    case 'unknownDefaultOpenApi':
      return _$dailyCheckInResponseDtoRewardAmountEnum_unknownDefaultOpenApi;
    default:
      return _$dailyCheckInResponseDtoRewardAmountEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DailyCheckInResponseDtoRewardAmountEnum>
_$dailyCheckInResponseDtoRewardAmountEnumValues =
    BuiltSet<DailyCheckInResponseDtoRewardAmountEnum>(
      const <DailyCheckInResponseDtoRewardAmountEnum>[
        _$dailyCheckInResponseDtoRewardAmountEnum_n1,
        _$dailyCheckInResponseDtoRewardAmountEnum_n2,
        _$dailyCheckInResponseDtoRewardAmountEnum_n3,
        _$dailyCheckInResponseDtoRewardAmountEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DailyCheckInResponseDtoRewardAmountEnum>
_$dailyCheckInResponseDtoRewardAmountEnumSerializer =
    _$DailyCheckInResponseDtoRewardAmountEnumSerializer();

class _$DailyCheckInResponseDtoRewardAmountEnumSerializer
    implements PrimitiveSerializer<DailyCheckInResponseDtoRewardAmountEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n1': '1',
    'n2': '2',
    'n3': '3',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '1': 'n1',
    '2': 'n2',
    '3': 'n3',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    DailyCheckInResponseDtoRewardAmountEnum,
  ];
  @override
  final String wireName = 'DailyCheckInResponseDtoRewardAmountEnum';

  @override
  Object serialize(
    Serializers serializers,
    DailyCheckInResponseDtoRewardAmountEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DailyCheckInResponseDtoRewardAmountEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DailyCheckInResponseDtoRewardAmountEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DailyCheckInResponseDto extends DailyCheckInResponseDto {
  @override
  final bool claimedNow;
  @override
  final String date;
  @override
  final DailyCheckInResponseDtoRewardAmountEnum rewardAmount;
  @override
  final num experienceAwarded;
  @override
  final String balance;
  @override
  final ProgressionResponseDto progression;

  factory _$DailyCheckInResponseDto([
    void Function(DailyCheckInResponseDtoBuilder)? updates,
  ]) => (DailyCheckInResponseDtoBuilder()..update(updates))._build();

  _$DailyCheckInResponseDto._({
    required this.claimedNow,
    required this.date,
    required this.rewardAmount,
    required this.experienceAwarded,
    required this.balance,
    required this.progression,
  }) : super._();
  @override
  DailyCheckInResponseDto rebuild(
    void Function(DailyCheckInResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DailyCheckInResponseDtoBuilder toBuilder() =>
      DailyCheckInResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DailyCheckInResponseDto &&
        claimedNow == other.claimedNow &&
        date == other.date &&
        rewardAmount == other.rewardAmount &&
        experienceAwarded == other.experienceAwarded &&
        balance == other.balance &&
        progression == other.progression;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, claimedNow.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, rewardAmount.hashCode);
    _$hash = $jc(_$hash, experienceAwarded.hashCode);
    _$hash = $jc(_$hash, balance.hashCode);
    _$hash = $jc(_$hash, progression.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DailyCheckInResponseDto')
          ..add('claimedNow', claimedNow)
          ..add('date', date)
          ..add('rewardAmount', rewardAmount)
          ..add('experienceAwarded', experienceAwarded)
          ..add('balance', balance)
          ..add('progression', progression))
        .toString();
  }
}

class DailyCheckInResponseDtoBuilder
    implements
        Builder<DailyCheckInResponseDto, DailyCheckInResponseDtoBuilder> {
  _$DailyCheckInResponseDto? _$v;

  bool? _claimedNow;
  bool? get claimedNow => _$this._claimedNow;
  set claimedNow(bool? claimedNow) => _$this._claimedNow = claimedNow;

  String? _date;
  String? get date => _$this._date;
  set date(String? date) => _$this._date = date;

  DailyCheckInResponseDtoRewardAmountEnum? _rewardAmount;
  DailyCheckInResponseDtoRewardAmountEnum? get rewardAmount =>
      _$this._rewardAmount;
  set rewardAmount(DailyCheckInResponseDtoRewardAmountEnum? rewardAmount) =>
      _$this._rewardAmount = rewardAmount;

  num? _experienceAwarded;
  num? get experienceAwarded => _$this._experienceAwarded;
  set experienceAwarded(num? experienceAwarded) =>
      _$this._experienceAwarded = experienceAwarded;

  String? _balance;
  String? get balance => _$this._balance;
  set balance(String? balance) => _$this._balance = balance;

  ProgressionResponseDtoBuilder? _progression;
  ProgressionResponseDtoBuilder get progression =>
      _$this._progression ??= ProgressionResponseDtoBuilder();
  set progression(ProgressionResponseDtoBuilder? progression) =>
      _$this._progression = progression;

  DailyCheckInResponseDtoBuilder() {
    DailyCheckInResponseDto._defaults(this);
  }

  DailyCheckInResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _claimedNow = $v.claimedNow;
      _date = $v.date;
      _rewardAmount = $v.rewardAmount;
      _experienceAwarded = $v.experienceAwarded;
      _balance = $v.balance;
      _progression = $v.progression.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DailyCheckInResponseDto other) {
    _$v = other as _$DailyCheckInResponseDto;
  }

  @override
  void update(void Function(DailyCheckInResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DailyCheckInResponseDto build() => _build();

  _$DailyCheckInResponseDto _build() {
    _$DailyCheckInResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$DailyCheckInResponseDto._(
            claimedNow: BuiltValueNullFieldError.checkNotNull(
              claimedNow,
              r'DailyCheckInResponseDto',
              'claimedNow',
            ),
            date: BuiltValueNullFieldError.checkNotNull(
              date,
              r'DailyCheckInResponseDto',
              'date',
            ),
            rewardAmount: BuiltValueNullFieldError.checkNotNull(
              rewardAmount,
              r'DailyCheckInResponseDto',
              'rewardAmount',
            ),
            experienceAwarded: BuiltValueNullFieldError.checkNotNull(
              experienceAwarded,
              r'DailyCheckInResponseDto',
              'experienceAwarded',
            ),
            balance: BuiltValueNullFieldError.checkNotNull(
              balance,
              r'DailyCheckInResponseDto',
              'balance',
            ),
            progression: progression.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'progression';
        progression.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DailyCheckInResponseDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
