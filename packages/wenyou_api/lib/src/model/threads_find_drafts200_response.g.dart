// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threads_find_drafts200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadsFindDrafts200ResponseCodeEnum
_$threadsFindDrafts200ResponseCodeEnum_number0 =
    const ThreadsFindDrafts200ResponseCodeEnum._('number0');
const ThreadsFindDrafts200ResponseCodeEnum
_$threadsFindDrafts200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadsFindDrafts200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadsFindDrafts200ResponseCodeEnum
_$threadsFindDrafts200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadsFindDrafts200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadsFindDrafts200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadsFindDrafts200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadsFindDrafts200ResponseCodeEnum>
_$threadsFindDrafts200ResponseCodeEnumValues =
    BuiltSet<ThreadsFindDrafts200ResponseCodeEnum>(
      const <ThreadsFindDrafts200ResponseCodeEnum>[
        _$threadsFindDrafts200ResponseCodeEnum_number0,
        _$threadsFindDrafts200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadsFindDrafts200ResponseCodeEnum>
_$threadsFindDrafts200ResponseCodeEnumSerializer =
    _$ThreadsFindDrafts200ResponseCodeEnumSerializer();

class _$ThreadsFindDrafts200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadsFindDrafts200ResponseCodeEnum> {
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
    ThreadsFindDrafts200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadsFindDrafts200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadsFindDrafts200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadsFindDrafts200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadsFindDrafts200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadsFindDrafts200Response extends ThreadsFindDrafts200Response {
  @override
  final BuiltList<DraftThreadResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadsFindDrafts200Response([
    void Function(ThreadsFindDrafts200ResponseBuilder)? updates,
  ]) => (ThreadsFindDrafts200ResponseBuilder()..update(updates))._build();

  _$ThreadsFindDrafts200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadsFindDrafts200Response rebuild(
    void Function(ThreadsFindDrafts200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadsFindDrafts200ResponseBuilder toBuilder() =>
      ThreadsFindDrafts200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadsFindDrafts200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadsFindDrafts200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadsFindDrafts200ResponseBuilder
    implements
        Builder<
          ThreadsFindDrafts200Response,
          ThreadsFindDrafts200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadsFindDrafts200Response? _$v;

  ListBuilder<DraftThreadResponseDto>? _data;
  ListBuilder<DraftThreadResponseDto> get data =>
      _$this._data ??= ListBuilder<DraftThreadResponseDto>();
  set data(covariant ListBuilder<DraftThreadResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadsFindDrafts200ResponseBuilder() {
    ThreadsFindDrafts200Response._defaults(this);
  }

  ThreadsFindDrafts200ResponseBuilder get _$this {
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
  void replace(covariant ThreadsFindDrafts200Response other) {
    _$v = other as _$ThreadsFindDrafts200Response;
  }

  @override
  void update(void Function(ThreadsFindDrafts200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadsFindDrafts200Response build() => _build();

  _$ThreadsFindDrafts200Response _build() {
    _$ThreadsFindDrafts200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadsFindDrafts200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadsFindDrafts200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadsFindDrafts200Response',
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
          r'ThreadsFindDrafts200Response',
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
