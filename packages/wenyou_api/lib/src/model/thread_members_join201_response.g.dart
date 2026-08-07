// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_members_join201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadMembersJoin201ResponseCodeEnum
_$threadMembersJoin201ResponseCodeEnum_number0 =
    const ThreadMembersJoin201ResponseCodeEnum._('number0');
const ThreadMembersJoin201ResponseCodeEnum
_$threadMembersJoin201ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadMembersJoin201ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadMembersJoin201ResponseCodeEnum
_$threadMembersJoin201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadMembersJoin201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadMembersJoin201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadMembersJoin201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadMembersJoin201ResponseCodeEnum>
_$threadMembersJoin201ResponseCodeEnumValues =
    BuiltSet<ThreadMembersJoin201ResponseCodeEnum>(
      const <ThreadMembersJoin201ResponseCodeEnum>[
        _$threadMembersJoin201ResponseCodeEnum_number0,
        _$threadMembersJoin201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadMembersJoin201ResponseCodeEnum>
_$threadMembersJoin201ResponseCodeEnumSerializer =
    _$ThreadMembersJoin201ResponseCodeEnumSerializer();

class _$ThreadMembersJoin201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadMembersJoin201ResponseCodeEnum> {
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
    ThreadMembersJoin201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadMembersJoin201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadMembersJoin201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadMembersJoin201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadMembersJoin201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadMembersJoin201Response extends ThreadMembersJoin201Response {
  @override
  final ThreadMemberResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadMembersJoin201Response([
    void Function(ThreadMembersJoin201ResponseBuilder)? updates,
  ]) => (ThreadMembersJoin201ResponseBuilder()..update(updates))._build();

  _$ThreadMembersJoin201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadMembersJoin201Response rebuild(
    void Function(ThreadMembersJoin201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadMembersJoin201ResponseBuilder toBuilder() =>
      ThreadMembersJoin201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadMembersJoin201Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadMembersJoin201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadMembersJoin201ResponseBuilder
    implements
        Builder<
          ThreadMembersJoin201Response,
          ThreadMembersJoin201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadMembersJoin201Response? _$v;

  ThreadMemberResponseDtoBuilder? _data;
  ThreadMemberResponseDtoBuilder get data =>
      _$this._data ??= ThreadMemberResponseDtoBuilder();
  set data(covariant ThreadMemberResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadMembersJoin201ResponseBuilder() {
    ThreadMembersJoin201Response._defaults(this);
  }

  ThreadMembersJoin201ResponseBuilder get _$this {
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
  void replace(covariant ThreadMembersJoin201Response other) {
    _$v = other as _$ThreadMembersJoin201Response;
  }

  @override
  void update(void Function(ThreadMembersJoin201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadMembersJoin201Response build() => _build();

  _$ThreadMembersJoin201Response _build() {
    _$ThreadMembersJoin201Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadMembersJoin201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadMembersJoin201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadMembersJoin201Response',
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
          r'ThreadMembersJoin201Response',
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
