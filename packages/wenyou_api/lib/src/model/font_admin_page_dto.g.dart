// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_admin_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FontAdminPageDto extends FontAdminPageDto {
  @override
  final BuiltList<FontFamilyDto> items;
  @override
  final String? nextAfter;

  factory _$FontAdminPageDto([
    void Function(FontAdminPageDtoBuilder)? updates,
  ]) => (FontAdminPageDtoBuilder()..update(updates))._build();

  _$FontAdminPageDto._({required this.items, this.nextAfter}) : super._();
  @override
  FontAdminPageDto rebuild(void Function(FontAdminPageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FontAdminPageDtoBuilder toBuilder() =>
      FontAdminPageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontAdminPageDto &&
        items == other.items &&
        nextAfter == other.nextAfter;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextAfter.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontAdminPageDto')
          ..add('items', items)
          ..add('nextAfter', nextAfter))
        .toString();
  }
}

class FontAdminPageDtoBuilder
    implements Builder<FontAdminPageDto, FontAdminPageDtoBuilder> {
  _$FontAdminPageDto? _$v;

  ListBuilder<FontFamilyDto>? _items;
  ListBuilder<FontFamilyDto> get items =>
      _$this._items ??= ListBuilder<FontFamilyDto>();
  set items(ListBuilder<FontFamilyDto>? items) => _$this._items = items;

  String? _nextAfter;
  String? get nextAfter => _$this._nextAfter;
  set nextAfter(String? nextAfter) => _$this._nextAfter = nextAfter;

  FontAdminPageDtoBuilder() {
    FontAdminPageDto._defaults(this);
  }

  FontAdminPageDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextAfter = $v.nextAfter;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontAdminPageDto other) {
    _$v = other as _$FontAdminPageDto;
  }

  @override
  void update(void Function(FontAdminPageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontAdminPageDto build() => _build();

  _$FontAdminPageDto _build() {
    _$FontAdminPageDto _$result;
    try {
      _$result =
          _$v ??
          _$FontAdminPageDto._(items: items.build(), nextAfter: nextAfter);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'FontAdminPageDto',
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
