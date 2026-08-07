// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_members_exit_member200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadMembersExitMember200ResponseCodeEnum
_$threadMembersExitMember200ResponseCodeEnum_number0 =
    const ThreadMembersExitMember200ResponseCodeEnum._('number0');
const ThreadMembersExitMember200ResponseCodeEnum
_$threadMembersExitMember200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadMembersExitMember200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadMembersExitMember200ResponseCodeEnum
_$threadMembersExitMember200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadMembersExitMember200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadMembersExitMember200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadMembersExitMember200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadMembersExitMember200ResponseCodeEnum>
_$threadMembersExitMember200ResponseCodeEnumValues =
    BuiltSet<ThreadMembersExitMember200ResponseCodeEnum>(
      const <ThreadMembersExitMember200ResponseCodeEnum>[
        _$threadMembersExitMember200ResponseCodeEnum_number0,
        _$threadMembersExitMember200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadMembersExitMember200ResponseCodeEnum>
_$threadMembersExitMember200ResponseCodeEnumSerializer =
    _$ThreadMembersExitMember200ResponseCodeEnumSerializer();

class _$ThreadMembersExitMember200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadMembersExitMember200ResponseCodeEnum> {
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
    ThreadMembersExitMember200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadMembersExitMember200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadMembersExitMember200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadMembersExitMember200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadMembersExitMember200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadMembersExitMember200Response
    extends ThreadMembersExitMember200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadMembersExitMember200Response([
    void Function(ThreadMembersExitMember200ResponseBuilder)? updates,
  ]) => (ThreadMembersExitMember200ResponseBuilder()..update(updates))._build();

  _$ThreadMembersExitMember200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadMembersExitMember200Response rebuild(
    void Function(ThreadMembersExitMember200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadMembersExitMember200ResponseBuilder toBuilder() =>
      ThreadMembersExitMember200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadMembersExitMember200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadMembersExitMember200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadMembersExitMember200ResponseBuilder
    implements
        Builder<
          ThreadMembersExitMember200Response,
          ThreadMembersExitMember200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadMembersExitMember200Response? _$v;

  MessageResponseDtoBuilder? _data;
  MessageResponseDtoBuilder get data =>
      _$this._data ??= MessageResponseDtoBuilder();
  set data(covariant MessageResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadMembersExitMember200ResponseBuilder() {
    ThreadMembersExitMember200Response._defaults(this);
  }

  ThreadMembersExitMember200ResponseBuilder get _$this {
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
  void replace(covariant ThreadMembersExitMember200Response other) {
    _$v = other as _$ThreadMembersExitMember200Response;
  }

  @override
  void update(
    void Function(ThreadMembersExitMember200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ThreadMembersExitMember200Response build() => _build();

  _$ThreadMembersExitMember200Response _build() {
    _$ThreadMembersExitMember200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadMembersExitMember200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadMembersExitMember200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadMembersExitMember200Response',
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
          r'ThreadMembersExitMember200Response',
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
