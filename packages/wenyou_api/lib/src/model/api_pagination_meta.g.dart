// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_pagination_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ApiPaginationMeta extends ApiPaginationMeta {
  @override
  final String? cursor;
  @override
  final bool hasMore;

  factory _$ApiPaginationMeta([
    void Function(ApiPaginationMetaBuilder)? updates,
  ]) => (ApiPaginationMetaBuilder()..update(updates))._build();

  _$ApiPaginationMeta._({this.cursor, required this.hasMore}) : super._();
  @override
  ApiPaginationMeta rebuild(void Function(ApiPaginationMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ApiPaginationMetaBuilder toBuilder() =>
      ApiPaginationMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApiPaginationMeta &&
        cursor == other.cursor &&
        hasMore == other.hasMore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cursor.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ApiPaginationMeta')
          ..add('cursor', cursor)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class ApiPaginationMetaBuilder
    implements Builder<ApiPaginationMeta, ApiPaginationMetaBuilder> {
  _$ApiPaginationMeta? _$v;

  String? _cursor;
  String? get cursor => _$this._cursor;
  set cursor(String? cursor) => _$this._cursor = cursor;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ApiPaginationMetaBuilder() {
    ApiPaginationMeta._defaults(this);
  }

  ApiPaginationMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cursor = $v.cursor;
      _hasMore = $v.hasMore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApiPaginationMeta other) {
    _$v = other as _$ApiPaginationMeta;
  }

  @override
  void update(void Function(ApiPaginationMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApiPaginationMeta build() => _build();

  _$ApiPaginationMeta _build() {
    final _$result =
        _$v ??
        _$ApiPaginationMeta._(
          cursor: cursor,
          hasMore: BuiltValueNullFieldError.checkNotNull(
            hasMore,
            r'ApiPaginationMeta',
            'hasMore',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
