// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threads_find_by_id200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadsFindById200ResponseCodeEnum
_$threadsFindById200ResponseCodeEnum_number0 =
    const ThreadsFindById200ResponseCodeEnum._('number0');
const ThreadsFindById200ResponseCodeEnum
_$threadsFindById200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadsFindById200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadsFindById200ResponseCodeEnum _$threadsFindById200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$threadsFindById200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadsFindById200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadsFindById200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadsFindById200ResponseCodeEnum>
_$threadsFindById200ResponseCodeEnumValues =
    BuiltSet<ThreadsFindById200ResponseCodeEnum>(
      const <ThreadsFindById200ResponseCodeEnum>[
        _$threadsFindById200ResponseCodeEnum_number0,
        _$threadsFindById200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadsFindById200ResponseCodeEnum>
_$threadsFindById200ResponseCodeEnumSerializer =
    _$ThreadsFindById200ResponseCodeEnumSerializer();

class _$ThreadsFindById200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadsFindById200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ThreadsFindById200ResponseCodeEnum];
  @override
  final String wireName = 'ThreadsFindById200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadsFindById200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadsFindById200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadsFindById200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadsFindById200Response extends ThreadsFindById200Response {
  @override
  final ThreadDetailResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadsFindById200Response([
    void Function(ThreadsFindById200ResponseBuilder)? updates,
  ]) => (ThreadsFindById200ResponseBuilder()..update(updates))._build();

  _$ThreadsFindById200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadsFindById200Response rebuild(
    void Function(ThreadsFindById200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadsFindById200ResponseBuilder toBuilder() =>
      ThreadsFindById200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadsFindById200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadsFindById200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadsFindById200ResponseBuilder
    implements
        Builder<ThreadsFindById200Response, ThreadsFindById200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$ThreadsFindById200Response? _$v;

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

  ThreadsFindById200ResponseBuilder() {
    ThreadsFindById200Response._defaults(this);
  }

  ThreadsFindById200ResponseBuilder get _$this {
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
  void replace(covariant ThreadsFindById200Response other) {
    _$v = other as _$ThreadsFindById200Response;
  }

  @override
  void update(void Function(ThreadsFindById200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadsFindById200Response build() => _build();

  _$ThreadsFindById200Response _build() {
    _$ThreadsFindById200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadsFindById200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadsFindById200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadsFindById200Response',
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
          r'ThreadsFindById200Response',
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
