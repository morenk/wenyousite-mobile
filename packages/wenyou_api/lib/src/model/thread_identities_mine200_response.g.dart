// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_identities_mine200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadIdentitiesMine200ResponseCodeEnum
_$threadIdentitiesMine200ResponseCodeEnum_number0 =
    const ThreadIdentitiesMine200ResponseCodeEnum._('number0');
const ThreadIdentitiesMine200ResponseCodeEnum
_$threadIdentitiesMine200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadIdentitiesMine200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadIdentitiesMine200ResponseCodeEnum
_$threadIdentitiesMine200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadIdentitiesMine200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadIdentitiesMine200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadIdentitiesMine200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadIdentitiesMine200ResponseCodeEnum>
_$threadIdentitiesMine200ResponseCodeEnumValues =
    BuiltSet<ThreadIdentitiesMine200ResponseCodeEnum>(
      const <ThreadIdentitiesMine200ResponseCodeEnum>[
        _$threadIdentitiesMine200ResponseCodeEnum_number0,
        _$threadIdentitiesMine200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadIdentitiesMine200ResponseCodeEnum>
_$threadIdentitiesMine200ResponseCodeEnumSerializer =
    _$ThreadIdentitiesMine200ResponseCodeEnumSerializer();

class _$ThreadIdentitiesMine200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadIdentitiesMine200ResponseCodeEnum> {
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
    ThreadIdentitiesMine200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadIdentitiesMine200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadIdentitiesMine200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadIdentitiesMine200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadIdentitiesMine200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadIdentitiesMine200Response
    extends ThreadIdentitiesMine200Response {
  @override
  final ThreadIdentityStateDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadIdentitiesMine200Response([
    void Function(ThreadIdentitiesMine200ResponseBuilder)? updates,
  ]) => (ThreadIdentitiesMine200ResponseBuilder()..update(updates))._build();

  _$ThreadIdentitiesMine200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadIdentitiesMine200Response rebuild(
    void Function(ThreadIdentitiesMine200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadIdentitiesMine200ResponseBuilder toBuilder() =>
      ThreadIdentitiesMine200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadIdentitiesMine200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadIdentitiesMine200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadIdentitiesMine200ResponseBuilder
    implements
        Builder<
          ThreadIdentitiesMine200Response,
          ThreadIdentitiesMine200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadIdentitiesMine200Response? _$v;

  ThreadIdentityStateDtoBuilder? _data;
  ThreadIdentityStateDtoBuilder get data =>
      _$this._data ??= ThreadIdentityStateDtoBuilder();
  set data(covariant ThreadIdentityStateDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadIdentitiesMine200ResponseBuilder() {
    ThreadIdentitiesMine200Response._defaults(this);
  }

  ThreadIdentitiesMine200ResponseBuilder get _$this {
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
  void replace(covariant ThreadIdentitiesMine200Response other) {
    _$v = other as _$ThreadIdentitiesMine200Response;
  }

  @override
  void update(void Function(ThreadIdentitiesMine200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadIdentitiesMine200Response build() => _build();

  _$ThreadIdentitiesMine200Response _build() {
    _$ThreadIdentitiesMine200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadIdentitiesMine200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadIdentitiesMine200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadIdentitiesMine200Response',
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
          r'ThreadIdentitiesMine200Response',
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
