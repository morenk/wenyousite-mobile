// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threads_unlike200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadsUnlike200ResponseCodeEnum
_$threadsUnlike200ResponseCodeEnum_number0 =
    const ThreadsUnlike200ResponseCodeEnum._('number0');
const ThreadsUnlike200ResponseCodeEnum
_$threadsUnlike200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadsUnlike200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadsUnlike200ResponseCodeEnum _$threadsUnlike200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$threadsUnlike200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadsUnlike200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadsUnlike200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadsUnlike200ResponseCodeEnum>
_$threadsUnlike200ResponseCodeEnumValues =
    BuiltSet<ThreadsUnlike200ResponseCodeEnum>(
      const <ThreadsUnlike200ResponseCodeEnum>[
        _$threadsUnlike200ResponseCodeEnum_number0,
        _$threadsUnlike200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadsUnlike200ResponseCodeEnum>
_$threadsUnlike200ResponseCodeEnumSerializer =
    _$ThreadsUnlike200ResponseCodeEnumSerializer();

class _$ThreadsUnlike200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadsUnlike200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ThreadsUnlike200ResponseCodeEnum];
  @override
  final String wireName = 'ThreadsUnlike200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadsUnlike200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadsUnlike200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadsUnlike200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadsUnlike200Response extends ThreadsUnlike200Response {
  @override
  final ThreadLikeResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadsUnlike200Response([
    void Function(ThreadsUnlike200ResponseBuilder)? updates,
  ]) => (ThreadsUnlike200ResponseBuilder()..update(updates))._build();

  _$ThreadsUnlike200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadsUnlike200Response rebuild(
    void Function(ThreadsUnlike200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadsUnlike200ResponseBuilder toBuilder() =>
      ThreadsUnlike200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadsUnlike200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadsUnlike200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadsUnlike200ResponseBuilder
    implements
        Builder<ThreadsUnlike200Response, ThreadsUnlike200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$ThreadsUnlike200Response? _$v;

  ThreadLikeResponseDtoBuilder? _data;
  ThreadLikeResponseDtoBuilder get data =>
      _$this._data ??= ThreadLikeResponseDtoBuilder();
  set data(covariant ThreadLikeResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadsUnlike200ResponseBuilder() {
    ThreadsUnlike200Response._defaults(this);
  }

  ThreadsUnlike200ResponseBuilder get _$this {
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
  void replace(covariant ThreadsUnlike200Response other) {
    _$v = other as _$ThreadsUnlike200Response;
  }

  @override
  void update(void Function(ThreadsUnlike200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadsUnlike200Response build() => _build();

  _$ThreadsUnlike200Response _build() {
    _$ThreadsUnlike200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadsUnlike200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadsUnlike200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadsUnlike200Response',
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
          r'ThreadsUnlike200Response',
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
