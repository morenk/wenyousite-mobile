// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reorder_stickers_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReorderStickersDto extends ReorderStickersDto {
  @override
  final num version;
  @override
  final BuiltList<String> favoriteIds;

  factory _$ReorderStickersDto([
    void Function(ReorderStickersDtoBuilder)? updates,
  ]) => (ReorderStickersDtoBuilder()..update(updates))._build();

  _$ReorderStickersDto._({required this.version, required this.favoriteIds})
    : super._();
  @override
  ReorderStickersDto rebuild(
    void Function(ReorderStickersDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ReorderStickersDtoBuilder toBuilder() =>
      ReorderStickersDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReorderStickersDto &&
        version == other.version &&
        favoriteIds == other.favoriteIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, favoriteIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReorderStickersDto')
          ..add('version', version)
          ..add('favoriteIds', favoriteIds))
        .toString();
  }
}

class ReorderStickersDtoBuilder
    implements Builder<ReorderStickersDto, ReorderStickersDtoBuilder> {
  _$ReorderStickersDto? _$v;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  ListBuilder<String>? _favoriteIds;
  ListBuilder<String> get favoriteIds =>
      _$this._favoriteIds ??= ListBuilder<String>();
  set favoriteIds(ListBuilder<String>? favoriteIds) =>
      _$this._favoriteIds = favoriteIds;

  ReorderStickersDtoBuilder() {
    ReorderStickersDto._defaults(this);
  }

  ReorderStickersDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _favoriteIds = $v.favoriteIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReorderStickersDto other) {
    _$v = other as _$ReorderStickersDto;
  }

  @override
  void update(void Function(ReorderStickersDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReorderStickersDto build() => _build();

  _$ReorderStickersDto _build() {
    _$ReorderStickersDto _$result;
    try {
      _$result =
          _$v ??
          _$ReorderStickersDto._(
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'ReorderStickersDto',
              'version',
            ),
            favoriteIds: favoriteIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'favoriteIds';
        favoriteIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ReorderStickersDto',
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
