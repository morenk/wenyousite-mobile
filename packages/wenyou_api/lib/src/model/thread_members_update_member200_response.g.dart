// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_members_update_member200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadMembersUpdateMember200ResponseCodeEnum
_$threadMembersUpdateMember200ResponseCodeEnum_number0 =
    const ThreadMembersUpdateMember200ResponseCodeEnum._('number0');
const ThreadMembersUpdateMember200ResponseCodeEnum
_$threadMembersUpdateMember200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadMembersUpdateMember200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

ThreadMembersUpdateMember200ResponseCodeEnum
_$threadMembersUpdateMember200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadMembersUpdateMember200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadMembersUpdateMember200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadMembersUpdateMember200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadMembersUpdateMember200ResponseCodeEnum>
_$threadMembersUpdateMember200ResponseCodeEnumValues =
    BuiltSet<ThreadMembersUpdateMember200ResponseCodeEnum>(
      const <ThreadMembersUpdateMember200ResponseCodeEnum>[
        _$threadMembersUpdateMember200ResponseCodeEnum_number0,
        _$threadMembersUpdateMember200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadMembersUpdateMember200ResponseCodeEnum>
_$threadMembersUpdateMember200ResponseCodeEnumSerializer =
    _$ThreadMembersUpdateMember200ResponseCodeEnumSerializer();

class _$ThreadMembersUpdateMember200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<ThreadMembersUpdateMember200ResponseCodeEnum> {
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
    ThreadMembersUpdateMember200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadMembersUpdateMember200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadMembersUpdateMember200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadMembersUpdateMember200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadMembersUpdateMember200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadMembersUpdateMember200Response
    extends ThreadMembersUpdateMember200Response {
  @override
  final ThreadMemberResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadMembersUpdateMember200Response([
    void Function(ThreadMembersUpdateMember200ResponseBuilder)? updates,
  ]) =>
      (ThreadMembersUpdateMember200ResponseBuilder()..update(updates))._build();

  _$ThreadMembersUpdateMember200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadMembersUpdateMember200Response rebuild(
    void Function(ThreadMembersUpdateMember200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadMembersUpdateMember200ResponseBuilder toBuilder() =>
      ThreadMembersUpdateMember200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadMembersUpdateMember200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadMembersUpdateMember200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadMembersUpdateMember200ResponseBuilder
    implements
        Builder<
          ThreadMembersUpdateMember200Response,
          ThreadMembersUpdateMember200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadMembersUpdateMember200Response? _$v;

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

  ThreadMembersUpdateMember200ResponseBuilder() {
    ThreadMembersUpdateMember200Response._defaults(this);
  }

  ThreadMembersUpdateMember200ResponseBuilder get _$this {
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
  void replace(covariant ThreadMembersUpdateMember200Response other) {
    _$v = other as _$ThreadMembersUpdateMember200Response;
  }

  @override
  void update(
    void Function(ThreadMembersUpdateMember200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ThreadMembersUpdateMember200Response build() => _build();

  _$ThreadMembersUpdateMember200Response _build() {
    _$ThreadMembersUpdateMember200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadMembersUpdateMember200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadMembersUpdateMember200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadMembersUpdateMember200Response',
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
          r'ThreadMembersUpdateMember200Response',
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
