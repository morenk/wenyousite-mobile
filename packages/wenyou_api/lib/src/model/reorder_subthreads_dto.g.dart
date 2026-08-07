// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reorder_subthreads_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReorderSubthreadsDto extends ReorderSubthreadsDto {
  @override
  final BuiltList<String> ids;

  factory _$ReorderSubthreadsDto([
    void Function(ReorderSubthreadsDtoBuilder)? updates,
  ]) => (ReorderSubthreadsDtoBuilder()..update(updates))._build();

  _$ReorderSubthreadsDto._({required this.ids}) : super._();
  @override
  ReorderSubthreadsDto rebuild(
    void Function(ReorderSubthreadsDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ReorderSubthreadsDtoBuilder toBuilder() =>
      ReorderSubthreadsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReorderSubthreadsDto && ids == other.ids;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ids.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'ReorderSubthreadsDto',
    )..add('ids', ids)).toString();
  }
}

class ReorderSubthreadsDtoBuilder
    implements Builder<ReorderSubthreadsDto, ReorderSubthreadsDtoBuilder> {
  _$ReorderSubthreadsDto? _$v;

  ListBuilder<String>? _ids;
  ListBuilder<String> get ids => _$this._ids ??= ListBuilder<String>();
  set ids(ListBuilder<String>? ids) => _$this._ids = ids;

  ReorderSubthreadsDtoBuilder() {
    ReorderSubthreadsDto._defaults(this);
  }

  ReorderSubthreadsDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ids = $v.ids.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReorderSubthreadsDto other) {
    _$v = other as _$ReorderSubthreadsDto;
  }

  @override
  void update(void Function(ReorderSubthreadsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReorderSubthreadsDto build() => _build();

  _$ReorderSubthreadsDto _build() {
    _$ReorderSubthreadsDto _$result;
    try {
      _$result = _$v ?? _$ReorderSubthreadsDto._(ids: ids.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ids';
        ids.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ReorderSubthreadsDto',
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
