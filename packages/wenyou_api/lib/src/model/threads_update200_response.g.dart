// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threads_update200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadsUpdate200ResponseCodeEnum
_$threadsUpdate200ResponseCodeEnum_number0 =
    const ThreadsUpdate200ResponseCodeEnum._('number0');
const ThreadsUpdate200ResponseCodeEnum
_$threadsUpdate200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadsUpdate200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadsUpdate200ResponseCodeEnum _$threadsUpdate200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$threadsUpdate200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadsUpdate200ResponseCodeEnum>
_$threadsUpdate200ResponseCodeEnumValues =
    BuiltSet<ThreadsUpdate200ResponseCodeEnum>(
      const <ThreadsUpdate200ResponseCodeEnum>[
        _$threadsUpdate200ResponseCodeEnum_number0,
        _$threadsUpdate200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadsUpdate200ResponseCodeEnum>
_$threadsUpdate200ResponseCodeEnumSerializer =
    _$ThreadsUpdate200ResponseCodeEnumSerializer();

class _$ThreadsUpdate200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadsUpdate200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ThreadsUpdate200ResponseCodeEnum];
  @override
  final String wireName = 'ThreadsUpdate200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadsUpdate200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadsUpdate200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadsUpdate200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadsUpdate200Response extends ThreadsUpdate200Response {
  @override
  final ThreadDetailResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadsUpdate200Response([
    void Function(ThreadsUpdate200ResponseBuilder)? updates,
  ]) => (ThreadsUpdate200ResponseBuilder()..update(updates))._build();

  _$ThreadsUpdate200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadsUpdate200Response rebuild(
    void Function(ThreadsUpdate200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadsUpdate200ResponseBuilder toBuilder() =>
      ThreadsUpdate200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadsUpdate200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadsUpdate200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadsUpdate200ResponseBuilder
    implements
        Builder<ThreadsUpdate200Response, ThreadsUpdate200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$ThreadsUpdate200Response? _$v;

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

  ThreadsUpdate200ResponseBuilder() {
    ThreadsUpdate200Response._defaults(this);
  }

  ThreadsUpdate200ResponseBuilder get _$this {
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
  void replace(covariant ThreadsUpdate200Response other) {
    _$v = other as _$ThreadsUpdate200Response;
  }

  @override
  void update(void Function(ThreadsUpdate200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadsUpdate200Response build() => _build();

  _$ThreadsUpdate200Response _build() {
    _$ThreadsUpdate200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadsUpdate200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadsUpdate200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadsUpdate200Response',
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
          r'ThreadsUpdate200Response',
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
