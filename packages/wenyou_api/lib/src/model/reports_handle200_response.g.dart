// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_handle200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReportsHandle200ResponseCodeEnum
_$reportsHandle200ResponseCodeEnum_number0 =
    const ReportsHandle200ResponseCodeEnum._('number0');
const ReportsHandle200ResponseCodeEnum
_$reportsHandle200ResponseCodeEnum_unknownDefaultOpenApi =
    const ReportsHandle200ResponseCodeEnum._('unknownDefaultOpenApi');

ReportsHandle200ResponseCodeEnum _$reportsHandle200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$reportsHandle200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$reportsHandle200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$reportsHandle200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ReportsHandle200ResponseCodeEnum>
_$reportsHandle200ResponseCodeEnumValues =
    BuiltSet<ReportsHandle200ResponseCodeEnum>(
      const <ReportsHandle200ResponseCodeEnum>[
        _$reportsHandle200ResponseCodeEnum_number0,
        _$reportsHandle200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ReportsHandle200ResponseCodeEnum>
_$reportsHandle200ResponseCodeEnumSerializer =
    _$ReportsHandle200ResponseCodeEnumSerializer();

class _$ReportsHandle200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ReportsHandle200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ReportsHandle200ResponseCodeEnum];
  @override
  final String wireName = 'ReportsHandle200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ReportsHandle200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ReportsHandle200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ReportsHandle200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ReportsHandle200Response extends ReportsHandle200Response {
  @override
  final ReportResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ReportsHandle200Response([
    void Function(ReportsHandle200ResponseBuilder)? updates,
  ]) => (ReportsHandle200ResponseBuilder()..update(updates))._build();

  _$ReportsHandle200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ReportsHandle200Response rebuild(
    void Function(ReportsHandle200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ReportsHandle200ResponseBuilder toBuilder() =>
      ReportsHandle200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportsHandle200Response &&
        data == other.data &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReportsHandle200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ReportsHandle200ResponseBuilder
    implements
        Builder<ReportsHandle200Response, ReportsHandle200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$ReportsHandle200Response? _$v;

  ReportResponseDtoBuilder? _data;
  ReportResponseDtoBuilder get data =>
      _$this._data ??= ReportResponseDtoBuilder();
  set data(covariant ReportResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ReportsHandle200ResponseBuilder() {
    ReportsHandle200Response._defaults(this);
  }

  ReportsHandle200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ReportsHandle200Response other) {
    _$v = other as _$ReportsHandle200Response;
  }

  @override
  void update(void Function(ReportsHandle200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReportsHandle200Response build() => _build();

  _$ReportsHandle200Response _build() {
    _$ReportsHandle200Response _$result;
    try {
      _$result =
          _$v ??
          _$ReportsHandle200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ReportsHandle200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ReportsHandle200Response',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ReportsHandle200Response',
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
