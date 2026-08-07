// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_members_find_all200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadMembersFindAll200ResponseCodeEnum
_$threadMembersFindAll200ResponseCodeEnum_number0 =
    const ThreadMembersFindAll200ResponseCodeEnum._('number0');
const ThreadMembersFindAll200ResponseCodeEnum
_$threadMembersFindAll200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadMembersFindAll200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadMembersFindAll200ResponseCodeEnum
_$threadMembersFindAll200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadMembersFindAll200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadMembersFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadMembersFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadMembersFindAll200ResponseCodeEnum>
_$threadMembersFindAll200ResponseCodeEnumValues =
    BuiltSet<ThreadMembersFindAll200ResponseCodeEnum>(
      const <ThreadMembersFindAll200ResponseCodeEnum>[
        _$threadMembersFindAll200ResponseCodeEnum_number0,
        _$threadMembersFindAll200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadMembersFindAll200ResponseCodeEnum>
_$threadMembersFindAll200ResponseCodeEnumSerializer =
    _$ThreadMembersFindAll200ResponseCodeEnumSerializer();

class _$ThreadMembersFindAll200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadMembersFindAll200ResponseCodeEnum> {
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
    ThreadMembersFindAll200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadMembersFindAll200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadMembersFindAll200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadMembersFindAll200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadMembersFindAll200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadMembersFindAll200Response
    extends ThreadMembersFindAll200Response {
  @override
  final BuiltList<ThreadMemberResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadMembersFindAll200Response([
    void Function(ThreadMembersFindAll200ResponseBuilder)? updates,
  ]) => (ThreadMembersFindAll200ResponseBuilder()..update(updates))._build();

  _$ThreadMembersFindAll200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadMembersFindAll200Response rebuild(
    void Function(ThreadMembersFindAll200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadMembersFindAll200ResponseBuilder toBuilder() =>
      ThreadMembersFindAll200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadMembersFindAll200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadMembersFindAll200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadMembersFindAll200ResponseBuilder
    implements
        Builder<
          ThreadMembersFindAll200Response,
          ThreadMembersFindAll200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadMembersFindAll200Response? _$v;

  ListBuilder<ThreadMemberResponseDto>? _data;
  ListBuilder<ThreadMemberResponseDto> get data =>
      _$this._data ??= ListBuilder<ThreadMemberResponseDto>();
  set data(covariant ListBuilder<ThreadMemberResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadMembersFindAll200ResponseBuilder() {
    ThreadMembersFindAll200Response._defaults(this);
  }

  ThreadMembersFindAll200ResponseBuilder get _$this {
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
  void replace(covariant ThreadMembersFindAll200Response other) {
    _$v = other as _$ThreadMembersFindAll200Response;
  }

  @override
  void update(void Function(ThreadMembersFindAll200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadMembersFindAll200Response build() => _build();

  _$ThreadMembersFindAll200Response _build() {
    _$ThreadMembersFindAll200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadMembersFindAll200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadMembersFindAll200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadMembersFindAll200Response',
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
          r'ThreadMembersFindAll200Response',
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
