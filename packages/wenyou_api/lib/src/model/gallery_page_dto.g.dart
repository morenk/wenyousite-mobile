// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GalleryPageDto extends GalleryPageDto {
  @override
  final BuiltList<GalleryImageDto> items;
  @override
  final String? previousCursor;
  @override
  final String? nextCursor;
  @override
  final String? anchorItemId;

  factory _$GalleryPageDto([void Function(GalleryPageDtoBuilder)? updates]) =>
      (GalleryPageDtoBuilder()..update(updates))._build();

  _$GalleryPageDto._({
    required this.items,
    this.previousCursor,
    this.nextCursor,
    this.anchorItemId,
  }) : super._();
  @override
  GalleryPageDto rebuild(void Function(GalleryPageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GalleryPageDtoBuilder toBuilder() => GalleryPageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GalleryPageDto &&
        items == other.items &&
        previousCursor == other.previousCursor &&
        nextCursor == other.nextCursor &&
        anchorItemId == other.anchorItemId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, previousCursor.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jc(_$hash, anchorItemId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GalleryPageDto')
          ..add('items', items)
          ..add('previousCursor', previousCursor)
          ..add('nextCursor', nextCursor)
          ..add('anchorItemId', anchorItemId))
        .toString();
  }
}

class GalleryPageDtoBuilder
    implements Builder<GalleryPageDto, GalleryPageDtoBuilder> {
  _$GalleryPageDto? _$v;

  ListBuilder<GalleryImageDto>? _items;
  ListBuilder<GalleryImageDto> get items =>
      _$this._items ??= ListBuilder<GalleryImageDto>();
  set items(ListBuilder<GalleryImageDto>? items) => _$this._items = items;

  String? _previousCursor;
  String? get previousCursor => _$this._previousCursor;
  set previousCursor(String? previousCursor) =>
      _$this._previousCursor = previousCursor;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  String? _anchorItemId;
  String? get anchorItemId => _$this._anchorItemId;
  set anchorItemId(String? anchorItemId) => _$this._anchorItemId = anchorItemId;

  GalleryPageDtoBuilder() {
    GalleryPageDto._defaults(this);
  }

  GalleryPageDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _previousCursor = $v.previousCursor;
      _nextCursor = $v.nextCursor;
      _anchorItemId = $v.anchorItemId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GalleryPageDto other) {
    _$v = other as _$GalleryPageDto;
  }

  @override
  void update(void Function(GalleryPageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GalleryPageDto build() => _build();

  _$GalleryPageDto _build() {
    _$GalleryPageDto _$result;
    try {
      _$result =
          _$v ??
          _$GalleryPageDto._(
            items: items.build(),
            previousCursor: previousCursor,
            nextCursor: nextCursor,
            anchorItemId: anchorItemId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GalleryPageDto',
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
