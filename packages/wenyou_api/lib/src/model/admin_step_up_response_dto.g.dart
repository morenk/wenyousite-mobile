// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_step_up_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminStepUpResponseDto extends AdminStepUpResponseDto {
  @override
  final DateTime elevatedUntil;

  factory _$AdminStepUpResponseDto([
    void Function(AdminStepUpResponseDtoBuilder)? updates,
  ]) => (AdminStepUpResponseDtoBuilder()..update(updates))._build();

  _$AdminStepUpResponseDto._({required this.elevatedUntil}) : super._();
  @override
  AdminStepUpResponseDto rebuild(
    void Function(AdminStepUpResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminStepUpResponseDtoBuilder toBuilder() =>
      AdminStepUpResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminStepUpResponseDto &&
        elevatedUntil == other.elevatedUntil;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, elevatedUntil.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'AdminStepUpResponseDto',
    )..add('elevatedUntil', elevatedUntil)).toString();
  }
}

class AdminStepUpResponseDtoBuilder
    implements Builder<AdminStepUpResponseDto, AdminStepUpResponseDtoBuilder> {
  _$AdminStepUpResponseDto? _$v;

  DateTime? _elevatedUntil;
  DateTime? get elevatedUntil => _$this._elevatedUntil;
  set elevatedUntil(DateTime? elevatedUntil) =>
      _$this._elevatedUntil = elevatedUntil;

  AdminStepUpResponseDtoBuilder() {
    AdminStepUpResponseDto._defaults(this);
  }

  AdminStepUpResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _elevatedUntil = $v.elevatedUntil;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminStepUpResponseDto other) {
    _$v = other as _$AdminStepUpResponseDto;
  }

  @override
  void update(void Function(AdminStepUpResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminStepUpResponseDto build() => _build();

  _$AdminStepUpResponseDto _build() {
    final _$result =
        _$v ??
        _$AdminStepUpResponseDto._(
          elevatedUntil: BuiltValueNullFieldError.checkNotNull(
            elevatedUntil,
            r'AdminStepUpResponseDto',
            'elevatedUntil',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
