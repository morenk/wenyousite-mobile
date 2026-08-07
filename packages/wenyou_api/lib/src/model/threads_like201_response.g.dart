// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threads_like201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadsLike201ResponseCodeEnum _$threadsLike201ResponseCodeEnum_number0 =
    const ThreadsLike201ResponseCodeEnum._('number0');
const ThreadsLike201ResponseCodeEnum
_$threadsLike201ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadsLike201ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadsLike201ResponseCodeEnum _$threadsLike201ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$threadsLike201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadsLike201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadsLike201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadsLike201ResponseCodeEnum>
_$threadsLike201ResponseCodeEnumValues =
    BuiltSet<ThreadsLike201ResponseCodeEnum>(
      const <ThreadsLike201ResponseCodeEnum>[
        _$threadsLike201ResponseCodeEnum_number0,
        _$threadsLike201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadsLike201ResponseCodeEnum>
_$threadsLike201ResponseCodeEnumSerializer =
    _$ThreadsLike201ResponseCodeEnumSerializer();

class _$ThreadsLike201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadsLike201ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ThreadsLike201ResponseCodeEnum];
  @override
  final String wireName = 'ThreadsLike201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadsLike201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadsLike201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadsLike201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadsLike201Response extends ThreadsLike201Response {
  @override
  final ThreadLikeResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadsLike201Response([
    void Function(ThreadsLike201ResponseBuilder)? updates,
  ]) => (ThreadsLike201ResponseBuilder()..update(updates))._build();

  _$ThreadsLike201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadsLike201Response rebuild(
    void Function(ThreadsLike201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadsLike201ResponseBuilder toBuilder() =>
      ThreadsLike201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadsLike201Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadsLike201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadsLike201ResponseBuilder
    implements
        Builder<ThreadsLike201Response, ThreadsLike201ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$ThreadsLike201Response? _$v;

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

  ThreadsLike201ResponseBuilder() {
    ThreadsLike201Response._defaults(this);
  }

  ThreadsLike201ResponseBuilder get _$this {
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
  void replace(covariant ThreadsLike201Response other) {
    _$v = other as _$ThreadsLike201Response;
  }

  @override
  void update(void Function(ThreadsLike201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadsLike201Response build() => _build();

  _$ThreadsLike201Response _build() {
    _$ThreadsLike201Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadsLike201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadsLike201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadsLike201Response',
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
          r'ThreadsLike201Response',
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
