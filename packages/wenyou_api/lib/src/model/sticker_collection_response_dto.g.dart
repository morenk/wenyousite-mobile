// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_collection_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StickerCollectionResponseDto extends StickerCollectionResponseDto {
  @override
  final num version;
  @override
  final num limit;
  @override
  final BuiltList<UserStickerResponseDto> items;
  @override
  final BuiltList<UserStickerResponseDto> recent;
  @override
  final BuiltList<StickerImportResponseDto> pendingImports;

  factory _$StickerCollectionResponseDto([
    void Function(StickerCollectionResponseDtoBuilder)? updates,
  ]) => (StickerCollectionResponseDtoBuilder()..update(updates))._build();

  _$StickerCollectionResponseDto._({
    required this.version,
    required this.limit,
    required this.items,
    required this.recent,
    required this.pendingImports,
  }) : super._();
  @override
  StickerCollectionResponseDto rebuild(
    void Function(StickerCollectionResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  StickerCollectionResponseDtoBuilder toBuilder() =>
      StickerCollectionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StickerCollectionResponseDto &&
        version == other.version &&
        limit == other.limit &&
        items == other.items &&
        recent == other.recent &&
        pendingImports == other.pendingImports;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, recent.hashCode);
    _$hash = $jc(_$hash, pendingImports.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StickerCollectionResponseDto')
          ..add('version', version)
          ..add('limit', limit)
          ..add('items', items)
          ..add('recent', recent)
          ..add('pendingImports', pendingImports))
        .toString();
  }
}

class StickerCollectionResponseDtoBuilder
    implements
        Builder<
          StickerCollectionResponseDto,
          StickerCollectionResponseDtoBuilder
        > {
  _$StickerCollectionResponseDto? _$v;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  num? _limit;
  num? get limit => _$this._limit;
  set limit(num? limit) => _$this._limit = limit;

  ListBuilder<UserStickerResponseDto>? _items;
  ListBuilder<UserStickerResponseDto> get items =>
      _$this._items ??= ListBuilder<UserStickerResponseDto>();
  set items(ListBuilder<UserStickerResponseDto>? items) =>
      _$this._items = items;

  ListBuilder<UserStickerResponseDto>? _recent;
  ListBuilder<UserStickerResponseDto> get recent =>
      _$this._recent ??= ListBuilder<UserStickerResponseDto>();
  set recent(ListBuilder<UserStickerResponseDto>? recent) =>
      _$this._recent = recent;

  ListBuilder<StickerImportResponseDto>? _pendingImports;
  ListBuilder<StickerImportResponseDto> get pendingImports =>
      _$this._pendingImports ??= ListBuilder<StickerImportResponseDto>();
  set pendingImports(ListBuilder<StickerImportResponseDto>? pendingImports) =>
      _$this._pendingImports = pendingImports;

  StickerCollectionResponseDtoBuilder() {
    StickerCollectionResponseDto._defaults(this);
  }

  StickerCollectionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _limit = $v.limit;
      _items = $v.items.toBuilder();
      _recent = $v.recent.toBuilder();
      _pendingImports = $v.pendingImports.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StickerCollectionResponseDto other) {
    _$v = other as _$StickerCollectionResponseDto;
  }

  @override
  void update(void Function(StickerCollectionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StickerCollectionResponseDto build() => _build();

  _$StickerCollectionResponseDto _build() {
    _$StickerCollectionResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$StickerCollectionResponseDto._(
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'StickerCollectionResponseDto',
              'version',
            ),
            limit: BuiltValueNullFieldError.checkNotNull(
              limit,
              r'StickerCollectionResponseDto',
              'limit',
            ),
            items: items.build(),
            recent: recent.build(),
            pendingImports: pendingImports.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
        _$failedField = 'recent';
        recent.build();
        _$failedField = 'pendingImports';
        pendingImports.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'StickerCollectionResponseDto',
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
