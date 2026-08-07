// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReportsCreate201ResponseCodeEnum
_$reportsCreate201ResponseCodeEnum_number0 =
    const ReportsCreate201ResponseCodeEnum._('number0');
const ReportsCreate201ResponseCodeEnum
_$reportsCreate201ResponseCodeEnum_unknownDefaultOpenApi =
    const ReportsCreate201ResponseCodeEnum._('unknownDefaultOpenApi');

ReportsCreate201ResponseCodeEnum _$reportsCreate201ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$reportsCreate201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$reportsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$reportsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ReportsCreate201ResponseCodeEnum>
_$reportsCreate201ResponseCodeEnumValues =
    BuiltSet<ReportsCreate201ResponseCodeEnum>(
      const <ReportsCreate201ResponseCodeEnum>[
        _$reportsCreate201ResponseCodeEnum_number0,
        _$reportsCreate201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ReportsCreate201ResponseCodeEnum>
_$reportsCreate201ResponseCodeEnumSerializer =
    _$ReportsCreate201ResponseCodeEnumSerializer();

class _$ReportsCreate201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ReportsCreate201ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ReportsCreate201ResponseCodeEnum];
  @override
  final String wireName = 'ReportsCreate201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ReportsCreate201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ReportsCreate201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ReportsCreate201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ReportsCreate201Response extends ReportsCreate201Response {
  @override
  final ReportResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ReportsCreate201Response([
    void Function(ReportsCreate201ResponseBuilder)? updates,
  ]) => (ReportsCreate201ResponseBuilder()..update(updates))._build();

  _$ReportsCreate201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ReportsCreate201Response rebuild(
    void Function(ReportsCreate201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ReportsCreate201ResponseBuilder toBuilder() =>
      ReportsCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportsCreate201Response &&
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
    return (newBuiltValueToStringHelper(r'ReportsCreate201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ReportsCreate201ResponseBuilder
    implements
        Builder<ReportsCreate201Response, ReportsCreate201ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$ReportsCreate201Response? _$v;

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

  ReportsCreate201ResponseBuilder() {
    ReportsCreate201Response._defaults(this);
  }

  ReportsCreate201ResponseBuilder get _$this {
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
  void replace(covariant ReportsCreate201Response other) {
    _$v = other as _$ReportsCreate201Response;
  }

  @override
  void update(void Function(ReportsCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReportsCreate201Response build() => _build();

  _$ReportsCreate201Response _build() {
    _$ReportsCreate201Response _$result;
    try {
      _$result =
          _$v ??
          _$ReportsCreate201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ReportsCreate201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ReportsCreate201Response',
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
          r'ReportsCreate201Response',
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
