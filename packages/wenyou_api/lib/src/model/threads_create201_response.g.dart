// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threads_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadsCreate201ResponseCodeEnum
_$threadsCreate201ResponseCodeEnum_number0 =
    const ThreadsCreate201ResponseCodeEnum._('number0');
const ThreadsCreate201ResponseCodeEnum
_$threadsCreate201ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadsCreate201ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadsCreate201ResponseCodeEnum _$threadsCreate201ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$threadsCreate201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadsCreate201ResponseCodeEnum>
_$threadsCreate201ResponseCodeEnumValues =
    BuiltSet<ThreadsCreate201ResponseCodeEnum>(
      const <ThreadsCreate201ResponseCodeEnum>[
        _$threadsCreate201ResponseCodeEnum_number0,
        _$threadsCreate201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadsCreate201ResponseCodeEnum>
_$threadsCreate201ResponseCodeEnumSerializer =
    _$ThreadsCreate201ResponseCodeEnumSerializer();

class _$ThreadsCreate201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadsCreate201ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ThreadsCreate201ResponseCodeEnum];
  @override
  final String wireName = 'ThreadsCreate201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadsCreate201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadsCreate201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadsCreate201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadsCreate201Response extends ThreadsCreate201Response {
  @override
  final ThreadDetailResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadsCreate201Response([
    void Function(ThreadsCreate201ResponseBuilder)? updates,
  ]) => (ThreadsCreate201ResponseBuilder()..update(updates))._build();

  _$ThreadsCreate201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadsCreate201Response rebuild(
    void Function(ThreadsCreate201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadsCreate201ResponseBuilder toBuilder() =>
      ThreadsCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadsCreate201Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadsCreate201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadsCreate201ResponseBuilder
    implements
        Builder<ThreadsCreate201Response, ThreadsCreate201ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$ThreadsCreate201Response? _$v;

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

  ThreadsCreate201ResponseBuilder() {
    ThreadsCreate201Response._defaults(this);
  }

  ThreadsCreate201ResponseBuilder get _$this {
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
  void replace(covariant ThreadsCreate201Response other) {
    _$v = other as _$ThreadsCreate201Response;
  }

  @override
  void update(void Function(ThreadsCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadsCreate201Response build() => _build();

  _$ThreadsCreate201Response _build() {
    _$ThreadsCreate201Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadsCreate201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadsCreate201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadsCreate201Response',
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
          r'ThreadsCreate201Response',
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
