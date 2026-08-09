// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progression_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProgressionResponseDto extends ProgressionResponseDto {
  @override
  final num level;
  @override
  final num experience;
  @override
  final num currentLevelExperience;
  @override
  final num? nextLevelExperience;

  factory _$ProgressionResponseDto([
    void Function(ProgressionResponseDtoBuilder)? updates,
  ]) => (ProgressionResponseDtoBuilder()..update(updates))._build();

  _$ProgressionResponseDto._({
    required this.level,
    required this.experience,
    required this.currentLevelExperience,
    this.nextLevelExperience,
  }) : super._();
  @override
  ProgressionResponseDto rebuild(
    void Function(ProgressionResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ProgressionResponseDtoBuilder toBuilder() =>
      ProgressionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProgressionResponseDto &&
        level == other.level &&
        experience == other.experience &&
        currentLevelExperience == other.currentLevelExperience &&
        nextLevelExperience == other.nextLevelExperience;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, level.hashCode);
    _$hash = $jc(_$hash, experience.hashCode);
    _$hash = $jc(_$hash, currentLevelExperience.hashCode);
    _$hash = $jc(_$hash, nextLevelExperience.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProgressionResponseDto')
          ..add('level', level)
          ..add('experience', experience)
          ..add('currentLevelExperience', currentLevelExperience)
          ..add('nextLevelExperience', nextLevelExperience))
        .toString();
  }
}

class ProgressionResponseDtoBuilder
    implements Builder<ProgressionResponseDto, ProgressionResponseDtoBuilder> {
  _$ProgressionResponseDto? _$v;

  num? _level;
  num? get level => _$this._level;
  set level(num? level) => _$this._level = level;

  num? _experience;
  num? get experience => _$this._experience;
  set experience(num? experience) => _$this._experience = experience;

  num? _currentLevelExperience;
  num? get currentLevelExperience => _$this._currentLevelExperience;
  set currentLevelExperience(num? currentLevelExperience) =>
      _$this._currentLevelExperience = currentLevelExperience;

  num? _nextLevelExperience;
  num? get nextLevelExperience => _$this._nextLevelExperience;
  set nextLevelExperience(num? nextLevelExperience) =>
      _$this._nextLevelExperience = nextLevelExperience;

  ProgressionResponseDtoBuilder() {
    ProgressionResponseDto._defaults(this);
  }

  ProgressionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _level = $v.level;
      _experience = $v.experience;
      _currentLevelExperience = $v.currentLevelExperience;
      _nextLevelExperience = $v.nextLevelExperience;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProgressionResponseDto other) {
    _$v = other as _$ProgressionResponseDto;
  }

  @override
  void update(void Function(ProgressionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProgressionResponseDto build() => _build();

  _$ProgressionResponseDto _build() {
    final _$result =
        _$v ??
        _$ProgressionResponseDto._(
          level: BuiltValueNullFieldError.checkNotNull(
            level,
            r'ProgressionResponseDto',
            'level',
          ),
          experience: BuiltValueNullFieldError.checkNotNull(
            experience,
            r'ProgressionResponseDto',
            'experience',
          ),
          currentLevelExperience: BuiltValueNullFieldError.checkNotNull(
            currentLevelExperience,
            r'ProgressionResponseDto',
            'currentLevelExperience',
          ),
          nextLevelExperience: nextLevelExperience,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
