// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_identities_update200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadIdentitiesUpdate200ResponseCodeEnum
_$threadIdentitiesUpdate200ResponseCodeEnum_number0 =
    const ThreadIdentitiesUpdate200ResponseCodeEnum._('number0');
const ThreadIdentitiesUpdate200ResponseCodeEnum
_$threadIdentitiesUpdate200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadIdentitiesUpdate200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadIdentitiesUpdate200ResponseCodeEnum
_$threadIdentitiesUpdate200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadIdentitiesUpdate200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadIdentitiesUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadIdentitiesUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadIdentitiesUpdate200ResponseCodeEnum>
_$threadIdentitiesUpdate200ResponseCodeEnumValues =
    BuiltSet<ThreadIdentitiesUpdate200ResponseCodeEnum>(
      const <ThreadIdentitiesUpdate200ResponseCodeEnum>[
        _$threadIdentitiesUpdate200ResponseCodeEnum_number0,
        _$threadIdentitiesUpdate200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadIdentitiesUpdate200ResponseCodeEnum>
_$threadIdentitiesUpdate200ResponseCodeEnumSerializer =
    _$ThreadIdentitiesUpdate200ResponseCodeEnumSerializer();

class _$ThreadIdentitiesUpdate200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadIdentitiesUpdate200ResponseCodeEnum> {
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
    ThreadIdentitiesUpdate200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadIdentitiesUpdate200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadIdentitiesUpdate200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadIdentitiesUpdate200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadIdentitiesUpdate200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadIdentitiesUpdate200Response
    extends ThreadIdentitiesUpdate200Response {
  @override
  final ThreadIdentityStateDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadIdentitiesUpdate200Response([
    void Function(ThreadIdentitiesUpdate200ResponseBuilder)? updates,
  ]) => (ThreadIdentitiesUpdate200ResponseBuilder()..update(updates))._build();

  _$ThreadIdentitiesUpdate200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadIdentitiesUpdate200Response rebuild(
    void Function(ThreadIdentitiesUpdate200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadIdentitiesUpdate200ResponseBuilder toBuilder() =>
      ThreadIdentitiesUpdate200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadIdentitiesUpdate200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadIdentitiesUpdate200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadIdentitiesUpdate200ResponseBuilder
    implements
        Builder<
          ThreadIdentitiesUpdate200Response,
          ThreadIdentitiesUpdate200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadIdentitiesUpdate200Response? _$v;

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

  ThreadIdentitiesUpdate200ResponseBuilder() {
    ThreadIdentitiesUpdate200Response._defaults(this);
  }

  ThreadIdentitiesUpdate200ResponseBuilder get _$this {
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
  void replace(covariant ThreadIdentitiesUpdate200Response other) {
    _$v = other as _$ThreadIdentitiesUpdate200Response;
  }

  @override
  void update(
    void Function(ThreadIdentitiesUpdate200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ThreadIdentitiesUpdate200Response build() => _build();

  _$ThreadIdentitiesUpdate200Response _build() {
    _$ThreadIdentitiesUpdate200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadIdentitiesUpdate200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadIdentitiesUpdate200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadIdentitiesUpdate200Response',
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
          r'ThreadIdentitiesUpdate200Response',
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
