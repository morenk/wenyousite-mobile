// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_identities_find_user200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadIdentitiesFindUser200ResponseCodeEnum
_$threadIdentitiesFindUser200ResponseCodeEnum_number0 =
    const ThreadIdentitiesFindUser200ResponseCodeEnum._('number0');
const ThreadIdentitiesFindUser200ResponseCodeEnum
_$threadIdentitiesFindUser200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadIdentitiesFindUser200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

ThreadIdentitiesFindUser200ResponseCodeEnum
_$threadIdentitiesFindUser200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadIdentitiesFindUser200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadIdentitiesFindUser200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadIdentitiesFindUser200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadIdentitiesFindUser200ResponseCodeEnum>
_$threadIdentitiesFindUser200ResponseCodeEnumValues =
    BuiltSet<ThreadIdentitiesFindUser200ResponseCodeEnum>(
      const <ThreadIdentitiesFindUser200ResponseCodeEnum>[
        _$threadIdentitiesFindUser200ResponseCodeEnum_number0,
        _$threadIdentitiesFindUser200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadIdentitiesFindUser200ResponseCodeEnum>
_$threadIdentitiesFindUser200ResponseCodeEnumSerializer =
    _$ThreadIdentitiesFindUser200ResponseCodeEnumSerializer();

class _$ThreadIdentitiesFindUser200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<ThreadIdentitiesFindUser200ResponseCodeEnum> {
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
    ThreadIdentitiesFindUser200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadIdentitiesFindUser200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadIdentitiesFindUser200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadIdentitiesFindUser200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadIdentitiesFindUser200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadIdentitiesFindUser200Response
    extends ThreadIdentitiesFindUser200Response {
  @override
  final ThreadIdentityStateDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadIdentitiesFindUser200Response([
    void Function(ThreadIdentitiesFindUser200ResponseBuilder)? updates,
  ]) =>
      (ThreadIdentitiesFindUser200ResponseBuilder()..update(updates))._build();

  _$ThreadIdentitiesFindUser200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadIdentitiesFindUser200Response rebuild(
    void Function(ThreadIdentitiesFindUser200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadIdentitiesFindUser200ResponseBuilder toBuilder() =>
      ThreadIdentitiesFindUser200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadIdentitiesFindUser200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadIdentitiesFindUser200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadIdentitiesFindUser200ResponseBuilder
    implements
        Builder<
          ThreadIdentitiesFindUser200Response,
          ThreadIdentitiesFindUser200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadIdentitiesFindUser200Response? _$v;

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

  ThreadIdentitiesFindUser200ResponseBuilder() {
    ThreadIdentitiesFindUser200Response._defaults(this);
  }

  ThreadIdentitiesFindUser200ResponseBuilder get _$this {
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
  void replace(covariant ThreadIdentitiesFindUser200Response other) {
    _$v = other as _$ThreadIdentitiesFindUser200Response;
  }

  @override
  void update(
    void Function(ThreadIdentitiesFindUser200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ThreadIdentitiesFindUser200Response build() => _build();

  _$ThreadIdentitiesFindUser200Response _build() {
    _$ThreadIdentitiesFindUser200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadIdentitiesFindUser200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadIdentitiesFindUser200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadIdentitiesFindUser200Response',
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
          r'ThreadIdentitiesFindUser200Response',
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
