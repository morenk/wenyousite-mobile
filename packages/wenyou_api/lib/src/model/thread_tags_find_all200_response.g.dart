// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_tags_find_all200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadTagsFindAll200ResponseCodeEnum
_$threadTagsFindAll200ResponseCodeEnum_number0 =
    const ThreadTagsFindAll200ResponseCodeEnum._('number0');
const ThreadTagsFindAll200ResponseCodeEnum
_$threadTagsFindAll200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadTagsFindAll200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadTagsFindAll200ResponseCodeEnum
_$threadTagsFindAll200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadTagsFindAll200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadTagsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadTagsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadTagsFindAll200ResponseCodeEnum>
_$threadTagsFindAll200ResponseCodeEnumValues =
    BuiltSet<ThreadTagsFindAll200ResponseCodeEnum>(
      const <ThreadTagsFindAll200ResponseCodeEnum>[
        _$threadTagsFindAll200ResponseCodeEnum_number0,
        _$threadTagsFindAll200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadTagsFindAll200ResponseCodeEnum>
_$threadTagsFindAll200ResponseCodeEnumSerializer =
    _$ThreadTagsFindAll200ResponseCodeEnumSerializer();

class _$ThreadTagsFindAll200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadTagsFindAll200ResponseCodeEnum> {
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
    ThreadTagsFindAll200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadTagsFindAll200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadTagsFindAll200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadTagsFindAll200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadTagsFindAll200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadTagsFindAll200Response extends ThreadTagsFindAll200Response {
  @override
  final BuiltList<ThreadTagRelationResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadTagsFindAll200Response([
    void Function(ThreadTagsFindAll200ResponseBuilder)? updates,
  ]) => (ThreadTagsFindAll200ResponseBuilder()..update(updates))._build();

  _$ThreadTagsFindAll200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadTagsFindAll200Response rebuild(
    void Function(ThreadTagsFindAll200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadTagsFindAll200ResponseBuilder toBuilder() =>
      ThreadTagsFindAll200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadTagsFindAll200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadTagsFindAll200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadTagsFindAll200ResponseBuilder
    implements
        Builder<
          ThreadTagsFindAll200Response,
          ThreadTagsFindAll200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadTagsFindAll200Response? _$v;

  ListBuilder<ThreadTagRelationResponseDto>? _data;
  ListBuilder<ThreadTagRelationResponseDto> get data =>
      _$this._data ??= ListBuilder<ThreadTagRelationResponseDto>();
  set data(covariant ListBuilder<ThreadTagRelationResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadTagsFindAll200ResponseBuilder() {
    ThreadTagsFindAll200Response._defaults(this);
  }

  ThreadTagsFindAll200ResponseBuilder get _$this {
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
  void replace(covariant ThreadTagsFindAll200Response other) {
    _$v = other as _$ThreadTagsFindAll200Response;
  }

  @override
  void update(void Function(ThreadTagsFindAll200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadTagsFindAll200Response build() => _build();

  _$ThreadTagsFindAll200Response _build() {
    _$ThreadTagsFindAll200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadTagsFindAll200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadTagsFindAll200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadTagsFindAll200Response',
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
          r'ThreadTagsFindAll200Response',
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
