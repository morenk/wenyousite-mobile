// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_state_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DraftStateResponseDto extends DraftStateResponseDto {
  @override
  final num usedSlots;
  @override
  final num maxSlots;
  @override
  final BuiltList<num> slots;
  @override
  final BuiltList<DraftResponseDto> drafts;

  factory _$DraftStateResponseDto([
    void Function(DraftStateResponseDtoBuilder)? updates,
  ]) => (DraftStateResponseDtoBuilder()..update(updates))._build();

  _$DraftStateResponseDto._({
    required this.usedSlots,
    required this.maxSlots,
    required this.slots,
    required this.drafts,
  }) : super._();
  @override
  DraftStateResponseDto rebuild(
    void Function(DraftStateResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DraftStateResponseDtoBuilder toBuilder() =>
      DraftStateResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DraftStateResponseDto &&
        usedSlots == other.usedSlots &&
        maxSlots == other.maxSlots &&
        slots == other.slots &&
        drafts == other.drafts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, usedSlots.hashCode);
    _$hash = $jc(_$hash, maxSlots.hashCode);
    _$hash = $jc(_$hash, slots.hashCode);
    _$hash = $jc(_$hash, drafts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DraftStateResponseDto')
          ..add('usedSlots', usedSlots)
          ..add('maxSlots', maxSlots)
          ..add('slots', slots)
          ..add('drafts', drafts))
        .toString();
  }
}

class DraftStateResponseDtoBuilder
    implements Builder<DraftStateResponseDto, DraftStateResponseDtoBuilder> {
  _$DraftStateResponseDto? _$v;

  num? _usedSlots;
  num? get usedSlots => _$this._usedSlots;
  set usedSlots(num? usedSlots) => _$this._usedSlots = usedSlots;

  num? _maxSlots;
  num? get maxSlots => _$this._maxSlots;
  set maxSlots(num? maxSlots) => _$this._maxSlots = maxSlots;

  ListBuilder<num>? _slots;
  ListBuilder<num> get slots => _$this._slots ??= ListBuilder<num>();
  set slots(ListBuilder<num>? slots) => _$this._slots = slots;

  ListBuilder<DraftResponseDto>? _drafts;
  ListBuilder<DraftResponseDto> get drafts =>
      _$this._drafts ??= ListBuilder<DraftResponseDto>();
  set drafts(ListBuilder<DraftResponseDto>? drafts) => _$this._drafts = drafts;

  DraftStateResponseDtoBuilder() {
    DraftStateResponseDto._defaults(this);
  }

  DraftStateResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _usedSlots = $v.usedSlots;
      _maxSlots = $v.maxSlots;
      _slots = $v.slots.toBuilder();
      _drafts = $v.drafts.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DraftStateResponseDto other) {
    _$v = other as _$DraftStateResponseDto;
  }

  @override
  void update(void Function(DraftStateResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DraftStateResponseDto build() => _build();

  _$DraftStateResponseDto _build() {
    _$DraftStateResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$DraftStateResponseDto._(
            usedSlots: BuiltValueNullFieldError.checkNotNull(
              usedSlots,
              r'DraftStateResponseDto',
              'usedSlots',
            ),
            maxSlots: BuiltValueNullFieldError.checkNotNull(
              maxSlots,
              r'DraftStateResponseDto',
              'maxSlots',
            ),
            slots: slots.build(),
            drafts: drafts.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'slots';
        slots.build();
        _$failedField = 'drafts';
        drafts.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DraftStateResponseDto',
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
