// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threads_create_invite_link200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadsCreateInviteLink200ResponseCodeEnum
_$threadsCreateInviteLink200ResponseCodeEnum_number0 =
    const ThreadsCreateInviteLink200ResponseCodeEnum._('number0');
const ThreadsCreateInviteLink200ResponseCodeEnum
_$threadsCreateInviteLink200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadsCreateInviteLink200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadsCreateInviteLink200ResponseCodeEnum
_$threadsCreateInviteLink200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadsCreateInviteLink200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadsCreateInviteLink200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadsCreateInviteLink200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadsCreateInviteLink200ResponseCodeEnum>
_$threadsCreateInviteLink200ResponseCodeEnumValues =
    BuiltSet<ThreadsCreateInviteLink200ResponseCodeEnum>(
      const <ThreadsCreateInviteLink200ResponseCodeEnum>[
        _$threadsCreateInviteLink200ResponseCodeEnum_number0,
        _$threadsCreateInviteLink200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadsCreateInviteLink200ResponseCodeEnum>
_$threadsCreateInviteLink200ResponseCodeEnumSerializer =
    _$ThreadsCreateInviteLink200ResponseCodeEnumSerializer();

class _$ThreadsCreateInviteLink200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadsCreateInviteLink200ResponseCodeEnum> {
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
    ThreadsCreateInviteLink200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadsCreateInviteLink200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadsCreateInviteLink200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadsCreateInviteLink200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadsCreateInviteLink200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadsCreateInviteLink200Response
    extends ThreadsCreateInviteLink200Response {
  @override
  final InviteLinkResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadsCreateInviteLink200Response([
    void Function(ThreadsCreateInviteLink200ResponseBuilder)? updates,
  ]) => (ThreadsCreateInviteLink200ResponseBuilder()..update(updates))._build();

  _$ThreadsCreateInviteLink200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadsCreateInviteLink200Response rebuild(
    void Function(ThreadsCreateInviteLink200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadsCreateInviteLink200ResponseBuilder toBuilder() =>
      ThreadsCreateInviteLink200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadsCreateInviteLink200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadsCreateInviteLink200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadsCreateInviteLink200ResponseBuilder
    implements
        Builder<
          ThreadsCreateInviteLink200Response,
          ThreadsCreateInviteLink200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadsCreateInviteLink200Response? _$v;

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

  ThreadsCreateInviteLink200ResponseBuilder() {
    ThreadsCreateInviteLink200Response._defaults(this);
  }

  ThreadsCreateInviteLink200ResponseBuilder get _$this {
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
  void replace(covariant ThreadsCreateInviteLink200Response other) {
    _$v = other as _$ThreadsCreateInviteLink200Response;
  }

  @override
  void update(
    void Function(ThreadsCreateInviteLink200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ThreadsCreateInviteLink200Response build() => _build();

  _$ThreadsCreateInviteLink200Response _build() {
    _$ThreadsCreateInviteLink200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadsCreateInviteLink200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadsCreateInviteLink200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadsCreateInviteLink200Response',
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
          r'ThreadsCreateInviteLink200Response',
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
