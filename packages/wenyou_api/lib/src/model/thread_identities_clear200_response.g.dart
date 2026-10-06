// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_identities_clear200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadIdentitiesClear200ResponseCodeEnum
_$threadIdentitiesClear200ResponseCodeEnum_number0 =
    const ThreadIdentitiesClear200ResponseCodeEnum._('number0');
const ThreadIdentitiesClear200ResponseCodeEnum
_$threadIdentitiesClear200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadIdentitiesClear200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadIdentitiesClear200ResponseCodeEnum
_$threadIdentitiesClear200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadIdentitiesClear200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadIdentitiesClear200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadIdentitiesClear200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadIdentitiesClear200ResponseCodeEnum>
_$threadIdentitiesClear200ResponseCodeEnumValues =
    BuiltSet<ThreadIdentitiesClear200ResponseCodeEnum>(
      const <ThreadIdentitiesClear200ResponseCodeEnum>[
        _$threadIdentitiesClear200ResponseCodeEnum_number0,
        _$threadIdentitiesClear200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadIdentitiesClear200ResponseCodeEnum>
_$threadIdentitiesClear200ResponseCodeEnumSerializer =
    _$ThreadIdentitiesClear200ResponseCodeEnumSerializer();

class _$ThreadIdentitiesClear200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadIdentitiesClear200ResponseCodeEnum> {
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
    ThreadIdentitiesClear200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadIdentitiesClear200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadIdentitiesClear200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadIdentitiesClear200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadIdentitiesClear200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadIdentitiesClear200Response
    extends ThreadIdentitiesClear200Response {
  @override
  final ThreadIdentityStateDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadIdentitiesClear200Response([
    void Function(ThreadIdentitiesClear200ResponseBuilder)? updates,
  ]) => (ThreadIdentitiesClear200ResponseBuilder()..update(updates))._build();

  _$ThreadIdentitiesClear200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadIdentitiesClear200Response rebuild(
    void Function(ThreadIdentitiesClear200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadIdentitiesClear200ResponseBuilder toBuilder() =>
      ThreadIdentitiesClear200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadIdentitiesClear200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadIdentitiesClear200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadIdentitiesClear200ResponseBuilder
    implements
        Builder<
          ThreadIdentitiesClear200Response,
          ThreadIdentitiesClear200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadIdentitiesClear200Response? _$v;

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

  ThreadIdentitiesClear200ResponseBuilder() {
    ThreadIdentitiesClear200Response._defaults(this);
  }

  ThreadIdentitiesClear200ResponseBuilder get _$this {
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
  void replace(covariant ThreadIdentitiesClear200Response other) {
    _$v = other as _$ThreadIdentitiesClear200Response;
  }

  @override
  void update(void Function(ThreadIdentitiesClear200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadIdentitiesClear200Response build() => _build();

  _$ThreadIdentitiesClear200Response _build() {
    _$ThreadIdentitiesClear200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadIdentitiesClear200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadIdentitiesClear200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadIdentitiesClear200Response',
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
          r'ThreadIdentitiesClear200Response',
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
