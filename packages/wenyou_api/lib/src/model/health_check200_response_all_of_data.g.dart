// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_check200_response_all_of_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HealthCheck200ResponseAllOfData
    extends HealthCheck200ResponseAllOfData {
  @override
  final String? status;
  @override
  final BuiltMap<String, BuiltMap<String, JsonObject?>>? info;
  @override
  final BuiltMap<String, BuiltMap<String, JsonObject?>>? error;
  @override
  final BuiltMap<String, BuiltMap<String, JsonObject?>>? details;

  factory _$HealthCheck200ResponseAllOfData([
    void Function(HealthCheck200ResponseAllOfDataBuilder)? updates,
  ]) => (HealthCheck200ResponseAllOfDataBuilder()..update(updates))._build();

  _$HealthCheck200ResponseAllOfData._({
    this.status,
    this.info,
    this.error,
    this.details,
  }) : super._();
  @override
  HealthCheck200ResponseAllOfData rebuild(
    void Function(HealthCheck200ResponseAllOfDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  HealthCheck200ResponseAllOfDataBuilder toBuilder() =>
      HealthCheck200ResponseAllOfDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HealthCheck200ResponseAllOfData &&
        status == other.status &&
        info == other.info &&
        error == other.error &&
        details == other.details;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, info.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HealthCheck200ResponseAllOfData')
          ..add('status', status)
          ..add('info', info)
          ..add('error', error)
          ..add('details', details))
        .toString();
  }
}

class HealthCheck200ResponseAllOfDataBuilder
    implements
        Builder<
          HealthCheck200ResponseAllOfData,
          HealthCheck200ResponseAllOfDataBuilder
        > {
  _$HealthCheck200ResponseAllOfData? _$v;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  MapBuilder<String, BuiltMap<String, JsonObject?>>? _info;
  MapBuilder<String, BuiltMap<String, JsonObject?>> get info =>
      _$this._info ??= MapBuilder<String, BuiltMap<String, JsonObject?>>();
  set info(MapBuilder<String, BuiltMap<String, JsonObject?>>? info) =>
      _$this._info = info;

  MapBuilder<String, BuiltMap<String, JsonObject?>>? _error;
  MapBuilder<String, BuiltMap<String, JsonObject?>> get error =>
      _$this._error ??= MapBuilder<String, BuiltMap<String, JsonObject?>>();
  set error(MapBuilder<String, BuiltMap<String, JsonObject?>>? error) =>
      _$this._error = error;

  MapBuilder<String, BuiltMap<String, JsonObject?>>? _details;
  MapBuilder<String, BuiltMap<String, JsonObject?>> get details =>
      _$this._details ??= MapBuilder<String, BuiltMap<String, JsonObject?>>();
  set details(MapBuilder<String, BuiltMap<String, JsonObject?>>? details) =>
      _$this._details = details;

  HealthCheck200ResponseAllOfDataBuilder() {
    HealthCheck200ResponseAllOfData._defaults(this);
  }

  HealthCheck200ResponseAllOfDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _info = $v.info?.toBuilder();
      _error = $v.error?.toBuilder();
      _details = $v.details?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HealthCheck200ResponseAllOfData other) {
    _$v = other as _$HealthCheck200ResponseAllOfData;
  }

  @override
  void update(void Function(HealthCheck200ResponseAllOfDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HealthCheck200ResponseAllOfData build() => _build();

  _$HealthCheck200ResponseAllOfData _build() {
    _$HealthCheck200ResponseAllOfData _$result;
    try {
      _$result =
          _$v ??
          _$HealthCheck200ResponseAllOfData._(
            status: status,
            info: _info?.build(),
            error: _error?.build(),
            details: _details?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'info';
        _info?.build();
        _$failedField = 'error';
        _error?.build();
        _$failedField = 'details';
        _details?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'HealthCheck200ResponseAllOfData',
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
