// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_identities_set_enabled200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadIdentitiesSetEnabled200ResponseCodeEnum
_$threadIdentitiesSetEnabled200ResponseCodeEnum_number0 =
    const ThreadIdentitiesSetEnabled200ResponseCodeEnum._('number0');
const ThreadIdentitiesSetEnabled200ResponseCodeEnum
_$threadIdentitiesSetEnabled200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadIdentitiesSetEnabled200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

ThreadIdentitiesSetEnabled200ResponseCodeEnum
_$threadIdentitiesSetEnabled200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadIdentitiesSetEnabled200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadIdentitiesSetEnabled200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadIdentitiesSetEnabled200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadIdentitiesSetEnabled200ResponseCodeEnum>
_$threadIdentitiesSetEnabled200ResponseCodeEnumValues =
    BuiltSet<ThreadIdentitiesSetEnabled200ResponseCodeEnum>(
      const <ThreadIdentitiesSetEnabled200ResponseCodeEnum>[
        _$threadIdentitiesSetEnabled200ResponseCodeEnum_number0,
        _$threadIdentitiesSetEnabled200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadIdentitiesSetEnabled200ResponseCodeEnum>
_$threadIdentitiesSetEnabled200ResponseCodeEnumSerializer =
    _$ThreadIdentitiesSetEnabled200ResponseCodeEnumSerializer();

class _$ThreadIdentitiesSetEnabled200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<ThreadIdentitiesSetEnabled200ResponseCodeEnum> {
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
    ThreadIdentitiesSetEnabled200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadIdentitiesSetEnabled200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadIdentitiesSetEnabled200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadIdentitiesSetEnabled200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadIdentitiesSetEnabled200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadIdentitiesSetEnabled200Response
    extends ThreadIdentitiesSetEnabled200Response {
  @override
  final ThreadIdentitySettingsDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadIdentitiesSetEnabled200Response([
    void Function(ThreadIdentitiesSetEnabled200ResponseBuilder)? updates,
  ]) => (ThreadIdentitiesSetEnabled200ResponseBuilder()..update(updates))
      ._build();

  _$ThreadIdentitiesSetEnabled200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadIdentitiesSetEnabled200Response rebuild(
    void Function(ThreadIdentitiesSetEnabled200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadIdentitiesSetEnabled200ResponseBuilder toBuilder() =>
      ThreadIdentitiesSetEnabled200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadIdentitiesSetEnabled200Response &&
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
    return (newBuiltValueToStringHelper(
            r'ThreadIdentitiesSetEnabled200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadIdentitiesSetEnabled200ResponseBuilder
    implements
        Builder<
          ThreadIdentitiesSetEnabled200Response,
          ThreadIdentitiesSetEnabled200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadIdentitiesSetEnabled200Response? _$v;

  ThreadIdentitySettingsDtoBuilder? _data;
  ThreadIdentitySettingsDtoBuilder get data =>
      _$this._data ??= ThreadIdentitySettingsDtoBuilder();
  set data(covariant ThreadIdentitySettingsDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadIdentitiesSetEnabled200ResponseBuilder() {
    ThreadIdentitiesSetEnabled200Response._defaults(this);
  }

  ThreadIdentitiesSetEnabled200ResponseBuilder get _$this {
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
  void replace(covariant ThreadIdentitiesSetEnabled200Response other) {
    _$v = other as _$ThreadIdentitiesSetEnabled200Response;
  }

  @override
  void update(
    void Function(ThreadIdentitiesSetEnabled200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ThreadIdentitiesSetEnabled200Response build() => _build();

  _$ThreadIdentitiesSetEnabled200Response _build() {
    _$ThreadIdentitiesSetEnabled200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadIdentitiesSetEnabled200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadIdentitiesSetEnabled200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadIdentitiesSetEnabled200Response',
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
          r'ThreadIdentitiesSetEnabled200Response',
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
