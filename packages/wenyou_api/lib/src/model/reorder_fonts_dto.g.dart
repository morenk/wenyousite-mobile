// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reorder_fonts_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReorderFontsDto extends ReorderFontsDto {
  @override
  final BuiltList<FontOrderGroupDto> groups;
  @override
  final int expectedCatalogRevision;

  factory _$ReorderFontsDto([void Function(ReorderFontsDtoBuilder)? updates]) =>
      (ReorderFontsDtoBuilder()..update(updates))._build();

  _$ReorderFontsDto._({
    required this.groups,
    required this.expectedCatalogRevision,
  }) : super._();
  @override
  ReorderFontsDto rebuild(void Function(ReorderFontsDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReorderFontsDtoBuilder toBuilder() => ReorderFontsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReorderFontsDto &&
        groups == other.groups &&
        expectedCatalogRevision == other.expectedCatalogRevision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, groups.hashCode);
    _$hash = $jc(_$hash, expectedCatalogRevision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReorderFontsDto')
          ..add('groups', groups)
          ..add('expectedCatalogRevision', expectedCatalogRevision))
        .toString();
  }
}

class ReorderFontsDtoBuilder
    implements Builder<ReorderFontsDto, ReorderFontsDtoBuilder> {
  _$ReorderFontsDto? _$v;

  ListBuilder<FontOrderGroupDto>? _groups;
  ListBuilder<FontOrderGroupDto> get groups =>
      _$this._groups ??= ListBuilder<FontOrderGroupDto>();
  set groups(ListBuilder<FontOrderGroupDto>? groups) => _$this._groups = groups;

  int? _expectedCatalogRevision;
  int? get expectedCatalogRevision => _$this._expectedCatalogRevision;
  set expectedCatalogRevision(int? expectedCatalogRevision) =>
      _$this._expectedCatalogRevision = expectedCatalogRevision;

  ReorderFontsDtoBuilder() {
    ReorderFontsDto._defaults(this);
  }

  ReorderFontsDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _groups = $v.groups.toBuilder();
      _expectedCatalogRevision = $v.expectedCatalogRevision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReorderFontsDto other) {
    _$v = other as _$ReorderFontsDto;
  }

  @override
  void update(void Function(ReorderFontsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReorderFontsDto build() => _build();

  _$ReorderFontsDto _build() {
    _$ReorderFontsDto _$result;
    try {
      _$result =
          _$v ??
          _$ReorderFontsDto._(
            groups: groups.build(),
            expectedCatalogRevision: BuiltValueNullFieldError.checkNotNull(
              expectedCatalogRevision,
              r'ReorderFontsDto',
              'expectedCatalogRevision',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'groups';
        groups.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ReorderFontsDto',
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
