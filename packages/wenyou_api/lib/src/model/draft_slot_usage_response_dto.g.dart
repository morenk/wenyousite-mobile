// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_slot_usage_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DraftSlotUsageResponseDto extends DraftSlotUsageResponseDto {
  @override
  final num usedSlots;
  @override
  final num maxSlots;
  @override
  final BuiltList<num> slots;

  factory _$DraftSlotUsageResponseDto([
    void Function(DraftSlotUsageResponseDtoBuilder)? updates,
  ]) => (DraftSlotUsageResponseDtoBuilder()..update(updates))._build();

  _$DraftSlotUsageResponseDto._({
    required this.usedSlots,
    required this.maxSlots,
    required this.slots,
  }) : super._();
  @override
  DraftSlotUsageResponseDto rebuild(
    void Function(DraftSlotUsageResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DraftSlotUsageResponseDtoBuilder toBuilder() =>
      DraftSlotUsageResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DraftSlotUsageResponseDto &&
        usedSlots == other.usedSlots &&
        maxSlots == other.maxSlots &&
        slots == other.slots;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, usedSlots.hashCode);
    _$hash = $jc(_$hash, maxSlots.hashCode);
    _$hash = $jc(_$hash, slots.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DraftSlotUsageResponseDto')
          ..add('usedSlots', usedSlots)
          ..add('maxSlots', maxSlots)
          ..add('slots', slots))
        .toString();
  }
}

class DraftSlotUsageResponseDtoBuilder
    implements
        Builder<DraftSlotUsageResponseDto, DraftSlotUsageResponseDtoBuilder> {
  _$DraftSlotUsageResponseDto? _$v;

  num? _usedSlots;
  num? get usedSlots => _$this._usedSlots;
  set usedSlots(num? usedSlots) => _$this._usedSlots = usedSlots;

  num? _maxSlots;
  num? get maxSlots => _$this._maxSlots;
  set maxSlots(num? maxSlots) => _$this._maxSlots = maxSlots;

  ListBuilder<num>? _slots;
  ListBuilder<num> get slots => _$this._slots ??= ListBuilder<num>();
  set slots(ListBuilder<num>? slots) => _$this._slots = slots;

  DraftSlotUsageResponseDtoBuilder() {
    DraftSlotUsageResponseDto._defaults(this);
  }

  DraftSlotUsageResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _usedSlots = $v.usedSlots;
      _maxSlots = $v.maxSlots;
      _slots = $v.slots.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DraftSlotUsageResponseDto other) {
    _$v = other as _$DraftSlotUsageResponseDto;
  }

  @override
  void update(void Function(DraftSlotUsageResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DraftSlotUsageResponseDto build() => _build();

  _$DraftSlotUsageResponseDto _build() {
    _$DraftSlotUsageResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$DraftSlotUsageResponseDto._(
            usedSlots: BuiltValueNullFieldError.checkNotNull(
              usedSlots,
              r'DraftSlotUsageResponseDto',
              'usedSlots',
            ),
            maxSlots: BuiltValueNullFieldError.checkNotNull(
              maxSlots,
              r'DraftSlotUsageResponseDto',
              'maxSlots',
            ),
            slots: slots.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'slots';
        slots.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DraftSlotUsageResponseDto',
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
