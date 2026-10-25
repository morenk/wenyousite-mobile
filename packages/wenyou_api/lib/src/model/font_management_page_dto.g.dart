// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_management_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FontManagementPageDto extends FontManagementPageDto {
  @override
  final BuiltList<FontManagementItemDto> items;
  @override
  final int total;
  @override
  final int listingRevision;
  @override
  final int catalogRevision;
  @override
  final String? nextCursor;

  factory _$FontManagementPageDto([
    void Function(FontManagementPageDtoBuilder)? updates,
  ]) => (FontManagementPageDtoBuilder()..update(updates))._build();

  _$FontManagementPageDto._({
    required this.items,
    required this.total,
    required this.listingRevision,
    required this.catalogRevision,
    this.nextCursor,
  }) : super._();
  @override
  FontManagementPageDto rebuild(
    void Function(FontManagementPageDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FontManagementPageDtoBuilder toBuilder() =>
      FontManagementPageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontManagementPageDto &&
        items == other.items &&
        total == other.total &&
        listingRevision == other.listingRevision &&
        catalogRevision == other.catalogRevision &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, listingRevision.hashCode);
    _$hash = $jc(_$hash, catalogRevision.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontManagementPageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('listingRevision', listingRevision)
          ..add('catalogRevision', catalogRevision)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class FontManagementPageDtoBuilder
    implements Builder<FontManagementPageDto, FontManagementPageDtoBuilder> {
  _$FontManagementPageDto? _$v;

  ListBuilder<FontManagementItemDto>? _items;
  ListBuilder<FontManagementItemDto> get items =>
      _$this._items ??= ListBuilder<FontManagementItemDto>();
  set items(ListBuilder<FontManagementItemDto>? items) => _$this._items = items;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  int? _listingRevision;
  int? get listingRevision => _$this._listingRevision;
  set listingRevision(int? listingRevision) =>
      _$this._listingRevision = listingRevision;

  int? _catalogRevision;
  int? get catalogRevision => _$this._catalogRevision;
  set catalogRevision(int? catalogRevision) =>
      _$this._catalogRevision = catalogRevision;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  FontManagementPageDtoBuilder() {
    FontManagementPageDto._defaults(this);
  }

  FontManagementPageDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _total = $v.total;
      _listingRevision = $v.listingRevision;
      _catalogRevision = $v.catalogRevision;
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontManagementPageDto other) {
    _$v = other as _$FontManagementPageDto;
  }

  @override
  void update(void Function(FontManagementPageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontManagementPageDto build() => _build();

  _$FontManagementPageDto _build() {
    _$FontManagementPageDto _$result;
    try {
      _$result =
          _$v ??
          _$FontManagementPageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
              total,
              r'FontManagementPageDto',
              'total',
            ),
            listingRevision: BuiltValueNullFieldError.checkNotNull(
              listingRevision,
              r'FontManagementPageDto',
              'listingRevision',
            ),
            catalogRevision: BuiltValueNullFieldError.checkNotNull(
              catalogRevision,
              r'FontManagementPageDto',
              'catalogRevision',
            ),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'FontManagementPageDto',
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
