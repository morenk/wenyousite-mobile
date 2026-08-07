// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ApiErrorEnvelope extends ApiErrorEnvelope {
  @override
  final BusinessErrorCode code;
  @override
  final String message;
  @override
  final JsonObject? data;

  factory _$ApiErrorEnvelope([
    void Function(ApiErrorEnvelopeBuilder)? updates,
  ]) => (ApiErrorEnvelopeBuilder()..update(updates))._build();

  _$ApiErrorEnvelope._({required this.code, required this.message, this.data})
    : super._();
  @override
  ApiErrorEnvelope rebuild(void Function(ApiErrorEnvelopeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ApiErrorEnvelopeBuilder toBuilder() =>
      ApiErrorEnvelopeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApiErrorEnvelope &&
        code == other.code &&
        message == other.message &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ApiErrorEnvelope')
          ..add('code', code)
          ..add('message', message)
          ..add('data', data))
        .toString();
  }
}

class ApiErrorEnvelopeBuilder
    implements Builder<ApiErrorEnvelope, ApiErrorEnvelopeBuilder> {
  _$ApiErrorEnvelope? _$v;

  BusinessErrorCode? _code;
  BusinessErrorCode? get code => _$this._code;
  set code(BusinessErrorCode? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  JsonObject? _data;
  JsonObject? get data => _$this._data;
  set data(JsonObject? data) => _$this._data = data;

  ApiErrorEnvelopeBuilder() {
    ApiErrorEnvelope._defaults(this);
  }

  ApiErrorEnvelopeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _data = $v.data;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApiErrorEnvelope other) {
    _$v = other as _$ApiErrorEnvelope;
  }

  @override
  void update(void Function(ApiErrorEnvelopeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApiErrorEnvelope build() => _build();

  _$ApiErrorEnvelope _build() {
    final _$result =
        _$v ??
        _$ApiErrorEnvelope._(
          code: BuiltValueNullFieldError.checkNotNull(
            code,
            r'ApiErrorEnvelope',
            'code',
          ),
          message: BuiltValueNullFieldError.checkNotNull(
            message,
            r'ApiErrorEnvelope',
            'message',
          ),
          data: data,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
