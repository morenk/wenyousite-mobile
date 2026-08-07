// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threads_remove200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadsRemove200ResponseCodeEnum
_$threadsRemove200ResponseCodeEnum_number0 =
    const ThreadsRemove200ResponseCodeEnum._('number0');
const ThreadsRemove200ResponseCodeEnum
_$threadsRemove200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadsRemove200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadsRemove200ResponseCodeEnum _$threadsRemove200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$threadsRemove200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadsRemove200ResponseCodeEnum>
_$threadsRemove200ResponseCodeEnumValues =
    BuiltSet<ThreadsRemove200ResponseCodeEnum>(
      const <ThreadsRemove200ResponseCodeEnum>[
        _$threadsRemove200ResponseCodeEnum_number0,
        _$threadsRemove200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadsRemove200ResponseCodeEnum>
_$threadsRemove200ResponseCodeEnumSerializer =
    _$ThreadsRemove200ResponseCodeEnumSerializer();

class _$ThreadsRemove200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadsRemove200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ThreadsRemove200ResponseCodeEnum];
  @override
  final String wireName = 'ThreadsRemove200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadsRemove200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadsRemove200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadsRemove200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadsRemove200Response extends ThreadsRemove200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadsRemove200Response([
    void Function(ThreadsRemove200ResponseBuilder)? updates,
  ]) => (ThreadsRemove200ResponseBuilder()..update(updates))._build();

  _$ThreadsRemove200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadsRemove200Response rebuild(
    void Function(ThreadsRemove200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadsRemove200ResponseBuilder toBuilder() =>
      ThreadsRemove200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadsRemove200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadsRemove200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadsRemove200ResponseBuilder
    implements
        Builder<ThreadsRemove200Response, ThreadsRemove200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$ThreadsRemove200Response? _$v;

  MessageResponseDtoBuilder? _data;
  MessageResponseDtoBuilder get data =>
      _$this._data ??= MessageResponseDtoBuilder();
  set data(covariant MessageResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadsRemove200ResponseBuilder() {
    ThreadsRemove200Response._defaults(this);
  }

  ThreadsRemove200ResponseBuilder get _$this {
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
  void replace(covariant ThreadsRemove200Response other) {
    _$v = other as _$ThreadsRemove200Response;
  }

  @override
  void update(void Function(ThreadsRemove200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadsRemove200Response build() => _build();

  _$ThreadsRemove200Response _build() {
    _$ThreadsRemove200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadsRemove200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadsRemove200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadsRemove200Response',
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
          r'ThreadsRemove200Response',
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
