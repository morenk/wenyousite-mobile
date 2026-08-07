// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threads_save_aggregate200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadsSaveAggregate200ResponseCodeEnum
_$threadsSaveAggregate200ResponseCodeEnum_number0 =
    const ThreadsSaveAggregate200ResponseCodeEnum._('number0');
const ThreadsSaveAggregate200ResponseCodeEnum
_$threadsSaveAggregate200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadsSaveAggregate200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadsSaveAggregate200ResponseCodeEnum
_$threadsSaveAggregate200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadsSaveAggregate200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadsSaveAggregate200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadsSaveAggregate200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadsSaveAggregate200ResponseCodeEnum>
_$threadsSaveAggregate200ResponseCodeEnumValues =
    BuiltSet<ThreadsSaveAggregate200ResponseCodeEnum>(
      const <ThreadsSaveAggregate200ResponseCodeEnum>[
        _$threadsSaveAggregate200ResponseCodeEnum_number0,
        _$threadsSaveAggregate200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadsSaveAggregate200ResponseCodeEnum>
_$threadsSaveAggregate200ResponseCodeEnumSerializer =
    _$ThreadsSaveAggregate200ResponseCodeEnumSerializer();

class _$ThreadsSaveAggregate200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadsSaveAggregate200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ThreadsSaveAggregate200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadsSaveAggregate200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadsSaveAggregate200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadsSaveAggregate200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadsSaveAggregate200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadsSaveAggregate200Response
    extends ThreadsSaveAggregate200Response {
  @override
  final ThreadDetailResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadsSaveAggregate200Response([
    void Function(ThreadsSaveAggregate200ResponseBuilder)? updates,
  ]) => (ThreadsSaveAggregate200ResponseBuilder()..update(updates))._build();

  _$ThreadsSaveAggregate200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadsSaveAggregate200Response rebuild(
    void Function(ThreadsSaveAggregate200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadsSaveAggregate200ResponseBuilder toBuilder() =>
      ThreadsSaveAggregate200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadsSaveAggregate200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadsSaveAggregate200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadsSaveAggregate200ResponseBuilder
    implements
        Builder<
          ThreadsSaveAggregate200Response,
          ThreadsSaveAggregate200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadsSaveAggregate200Response? _$v;

  ThreadDetailResponseDtoBuilder? _data;
  ThreadDetailResponseDtoBuilder get data =>
      _$this._data ??= ThreadDetailResponseDtoBuilder();
  set data(covariant ThreadDetailResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadsSaveAggregate200ResponseBuilder() {
    ThreadsSaveAggregate200Response._defaults(this);
  }

  ThreadsSaveAggregate200ResponseBuilder get _$this {
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
  void replace(covariant ThreadsSaveAggregate200Response other) {
    _$v = other as _$ThreadsSaveAggregate200Response;
  }

  @override
  void update(void Function(ThreadsSaveAggregate200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadsSaveAggregate200Response build() => _build();

  _$ThreadsSaveAggregate200Response _build() {
    _$ThreadsSaveAggregate200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadsSaveAggregate200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadsSaveAggregate200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadsSaveAggregate200Response',
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
          r'ThreadsSaveAggregate200Response',
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
