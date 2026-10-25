// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_rights_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FontRightsDto extends FontRightsDto {
  @override
  final bool redistribution;
  @override
  final bool conversion;
  @override
  final bool subsetting;

  factory _$FontRightsDto([void Function(FontRightsDtoBuilder)? updates]) =>
      (FontRightsDtoBuilder()..update(updates))._build();

  _$FontRightsDto._({
    required this.redistribution,
    required this.conversion,
    required this.subsetting,
  }) : super._();
  @override
  FontRightsDto rebuild(void Function(FontRightsDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FontRightsDtoBuilder toBuilder() => FontRightsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontRightsDto &&
        redistribution == other.redistribution &&
        conversion == other.conversion &&
        subsetting == other.subsetting;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, redistribution.hashCode);
    _$hash = $jc(_$hash, conversion.hashCode);
    _$hash = $jc(_$hash, subsetting.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontRightsDto')
          ..add('redistribution', redistribution)
          ..add('conversion', conversion)
          ..add('subsetting', subsetting))
        .toString();
  }
}

class FontRightsDtoBuilder
    implements Builder<FontRightsDto, FontRightsDtoBuilder> {
  _$FontRightsDto? _$v;

  bool? _redistribution;
  bool? get redistribution => _$this._redistribution;
  set redistribution(bool? redistribution) =>
      _$this._redistribution = redistribution;

  bool? _conversion;
  bool? get conversion => _$this._conversion;
  set conversion(bool? conversion) => _$this._conversion = conversion;

  bool? _subsetting;
  bool? get subsetting => _$this._subsetting;
  set subsetting(bool? subsetting) => _$this._subsetting = subsetting;

  FontRightsDtoBuilder() {
    FontRightsDto._defaults(this);
  }

  FontRightsDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _redistribution = $v.redistribution;
      _conversion = $v.conversion;
      _subsetting = $v.subsetting;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontRightsDto other) {
    _$v = other as _$FontRightsDto;
  }

  @override
  void update(void Function(FontRightsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontRightsDto build() => _build();

  _$FontRightsDto _build() {
    final _$result =
        _$v ??
        _$FontRightsDto._(
          redistribution: BuiltValueNullFieldError.checkNotNull(
            redistribution,
            r'FontRightsDto',
            'redistribution',
          ),
          conversion: BuiltValueNullFieldError.checkNotNull(
            conversion,
            r'FontRightsDto',
            'conversion',
          ),
          subsetting: BuiltValueNullFieldError.checkNotNull(
            subsetting,
            r'FontRightsDto',
            'subsetting',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
