// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_reorder_result_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FontReorderResultDto extends FontReorderResultDto {
  @override
  final int catalogRevision;
  @override
  final int listingRevision;
  @override
  final bool changed;

  factory _$FontReorderResultDto([
    void Function(FontReorderResultDtoBuilder)? updates,
  ]) => (FontReorderResultDtoBuilder()..update(updates))._build();

  _$FontReorderResultDto._({
    required this.catalogRevision,
    required this.listingRevision,
    required this.changed,
  }) : super._();
  @override
  FontReorderResultDto rebuild(
    void Function(FontReorderResultDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FontReorderResultDtoBuilder toBuilder() =>
      FontReorderResultDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontReorderResultDto &&
        catalogRevision == other.catalogRevision &&
        listingRevision == other.listingRevision &&
        changed == other.changed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, catalogRevision.hashCode);
    _$hash = $jc(_$hash, listingRevision.hashCode);
    _$hash = $jc(_$hash, changed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontReorderResultDto')
          ..add('catalogRevision', catalogRevision)
          ..add('listingRevision', listingRevision)
          ..add('changed', changed))
        .toString();
  }
}

class FontReorderResultDtoBuilder
    implements Builder<FontReorderResultDto, FontReorderResultDtoBuilder> {
  _$FontReorderResultDto? _$v;

  int? _catalogRevision;
  int? get catalogRevision => _$this._catalogRevision;
  set catalogRevision(int? catalogRevision) =>
      _$this._catalogRevision = catalogRevision;

  int? _listingRevision;
  int? get listingRevision => _$this._listingRevision;
  set listingRevision(int? listingRevision) =>
      _$this._listingRevision = listingRevision;

  bool? _changed;
  bool? get changed => _$this._changed;
  set changed(bool? changed) => _$this._changed = changed;

  FontReorderResultDtoBuilder() {
    FontReorderResultDto._defaults(this);
  }

  FontReorderResultDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _catalogRevision = $v.catalogRevision;
      _listingRevision = $v.listingRevision;
      _changed = $v.changed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontReorderResultDto other) {
    _$v = other as _$FontReorderResultDto;
  }

  @override
  void update(void Function(FontReorderResultDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontReorderResultDto build() => _build();

  _$FontReorderResultDto _build() {
    final _$result =
        _$v ??
        _$FontReorderResultDto._(
          catalogRevision: BuiltValueNullFieldError.checkNotNull(
            catalogRevision,
            r'FontReorderResultDto',
            'catalogRevision',
          ),
          listingRevision: BuiltValueNullFieldError.checkNotNull(
            listingRevision,
            r'FontReorderResultDto',
            'listingRevision',
          ),
          changed: BuiltValueNullFieldError.checkNotNull(
            changed,
            r'FontReorderResultDto',
            'changed',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
