// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threads_ensure_invite_link200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadsEnsureInviteLink200ResponseCodeEnum
_$threadsEnsureInviteLink200ResponseCodeEnum_number0 =
    const ThreadsEnsureInviteLink200ResponseCodeEnum._('number0');
const ThreadsEnsureInviteLink200ResponseCodeEnum
_$threadsEnsureInviteLink200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadsEnsureInviteLink200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadsEnsureInviteLink200ResponseCodeEnum
_$threadsEnsureInviteLink200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadsEnsureInviteLink200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadsEnsureInviteLink200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadsEnsureInviteLink200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadsEnsureInviteLink200ResponseCodeEnum>
_$threadsEnsureInviteLink200ResponseCodeEnumValues =
    BuiltSet<ThreadsEnsureInviteLink200ResponseCodeEnum>(
      const <ThreadsEnsureInviteLink200ResponseCodeEnum>[
        _$threadsEnsureInviteLink200ResponseCodeEnum_number0,
        _$threadsEnsureInviteLink200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadsEnsureInviteLink200ResponseCodeEnum>
_$threadsEnsureInviteLink200ResponseCodeEnumSerializer =
    _$ThreadsEnsureInviteLink200ResponseCodeEnumSerializer();

class _$ThreadsEnsureInviteLink200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadsEnsureInviteLink200ResponseCodeEnum> {
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
    ThreadsEnsureInviteLink200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadsEnsureInviteLink200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadsEnsureInviteLink200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadsEnsureInviteLink200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadsEnsureInviteLink200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadsEnsureInviteLink200Response
    extends ThreadsEnsureInviteLink200Response {
  @override
  final InviteLinkResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadsEnsureInviteLink200Response([
    void Function(ThreadsEnsureInviteLink200ResponseBuilder)? updates,
  ]) => (ThreadsEnsureInviteLink200ResponseBuilder()..update(updates))._build();

  _$ThreadsEnsureInviteLink200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadsEnsureInviteLink200Response rebuild(
    void Function(ThreadsEnsureInviteLink200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadsEnsureInviteLink200ResponseBuilder toBuilder() =>
      ThreadsEnsureInviteLink200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadsEnsureInviteLink200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadsEnsureInviteLink200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadsEnsureInviteLink200ResponseBuilder
    implements
        Builder<
          ThreadsEnsureInviteLink200Response,
          ThreadsEnsureInviteLink200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadsEnsureInviteLink200Response? _$v;

  InviteLinkResponseDtoBuilder? _data;
  InviteLinkResponseDtoBuilder get data =>
      _$this._data ??= InviteLinkResponseDtoBuilder();
  set data(covariant InviteLinkResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadsEnsureInviteLink200ResponseBuilder() {
    ThreadsEnsureInviteLink200Response._defaults(this);
  }

  ThreadsEnsureInviteLink200ResponseBuilder get _$this {
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
  void replace(covariant ThreadsEnsureInviteLink200Response other) {
    _$v = other as _$ThreadsEnsureInviteLink200Response;
  }

  @override
  void update(
    void Function(ThreadsEnsureInviteLink200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ThreadsEnsureInviteLink200Response build() => _build();

  _$ThreadsEnsureInviteLink200Response _build() {
    _$ThreadsEnsureInviteLink200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadsEnsureInviteLink200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadsEnsureInviteLink200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadsEnsureInviteLink200Response',
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
          r'ThreadsEnsureInviteLink200Response',
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
