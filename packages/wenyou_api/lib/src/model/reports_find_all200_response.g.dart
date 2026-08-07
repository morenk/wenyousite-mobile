// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_find_all200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReportsFindAll200ResponseCodeEnum
_$reportsFindAll200ResponseCodeEnum_number0 =
    const ReportsFindAll200ResponseCodeEnum._('number0');
const ReportsFindAll200ResponseCodeEnum
_$reportsFindAll200ResponseCodeEnum_unknownDefaultOpenApi =
    const ReportsFindAll200ResponseCodeEnum._('unknownDefaultOpenApi');

ReportsFindAll200ResponseCodeEnum _$reportsFindAll200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$reportsFindAll200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$reportsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$reportsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ReportsFindAll200ResponseCodeEnum>
_$reportsFindAll200ResponseCodeEnumValues =
    BuiltSet<ReportsFindAll200ResponseCodeEnum>(
      const <ReportsFindAll200ResponseCodeEnum>[
        _$reportsFindAll200ResponseCodeEnum_number0,
        _$reportsFindAll200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ReportsFindAll200ResponseCodeEnum>
_$reportsFindAll200ResponseCodeEnumSerializer =
    _$ReportsFindAll200ResponseCodeEnumSerializer();

class _$ReportsFindAll200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ReportsFindAll200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ReportsFindAll200ResponseCodeEnum];
  @override
  final String wireName = 'ReportsFindAll200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ReportsFindAll200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ReportsFindAll200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ReportsFindAll200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ReportsFindAll200Response extends ReportsFindAll200Response {
  @override
  final BuiltList<ReportResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ReportsFindAll200Response([
    void Function(ReportsFindAll200ResponseBuilder)? updates,
  ]) => (ReportsFindAll200ResponseBuilder()..update(updates))._build();

  _$ReportsFindAll200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ReportsFindAll200Response rebuild(
    void Function(ReportsFindAll200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ReportsFindAll200ResponseBuilder toBuilder() =>
      ReportsFindAll200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportsFindAll200Response &&
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
    return (newBuiltValueToStringHelper(r'ReportsFindAll200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ReportsFindAll200ResponseBuilder
    implements
        Builder<ReportsFindAll200Response, ReportsFindAll200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$ReportsFindAll200Response? _$v;

  ListBuilder<ReportResponseDto>? _data;
  ListBuilder<ReportResponseDto> get data =>
      _$this._data ??= ListBuilder<ReportResponseDto>();
  set data(covariant ListBuilder<ReportResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ReportsFindAll200ResponseBuilder() {
    ReportsFindAll200Response._defaults(this);
  }

  ReportsFindAll200ResponseBuilder get _$this {
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
  void replace(covariant ReportsFindAll200Response other) {
    _$v = other as _$ReportsFindAll200Response;
  }

  @override
  void update(void Function(ReportsFindAll200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReportsFindAll200Response build() => _build();

  _$ReportsFindAll200Response _build() {
    _$ReportsFindAll200Response _$result;
    try {
      _$result =
          _$v ??
          _$ReportsFindAll200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ReportsFindAll200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ReportsFindAll200Response',
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
          r'ReportsFindAll200Response',
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
