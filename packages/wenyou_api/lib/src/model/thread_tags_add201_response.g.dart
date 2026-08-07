// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_tags_add201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadTagsAdd201ResponseCodeEnum
_$threadTagsAdd201ResponseCodeEnum_number0 =
    const ThreadTagsAdd201ResponseCodeEnum._('number0');
const ThreadTagsAdd201ResponseCodeEnum
_$threadTagsAdd201ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadTagsAdd201ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadTagsAdd201ResponseCodeEnum _$threadTagsAdd201ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$threadTagsAdd201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadTagsAdd201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadTagsAdd201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadTagsAdd201ResponseCodeEnum>
_$threadTagsAdd201ResponseCodeEnumValues =
    BuiltSet<ThreadTagsAdd201ResponseCodeEnum>(
      const <ThreadTagsAdd201ResponseCodeEnum>[
        _$threadTagsAdd201ResponseCodeEnum_number0,
        _$threadTagsAdd201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadTagsAdd201ResponseCodeEnum>
_$threadTagsAdd201ResponseCodeEnumSerializer =
    _$ThreadTagsAdd201ResponseCodeEnumSerializer();

class _$ThreadTagsAdd201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadTagsAdd201ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ThreadTagsAdd201ResponseCodeEnum];
  @override
  final String wireName = 'ThreadTagsAdd201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadTagsAdd201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadTagsAdd201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadTagsAdd201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadTagsAdd201Response extends ThreadTagsAdd201Response {
  @override
  final ThreadTagResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadTagsAdd201Response([
    void Function(ThreadTagsAdd201ResponseBuilder)? updates,
  ]) => (ThreadTagsAdd201ResponseBuilder()..update(updates))._build();

  _$ThreadTagsAdd201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadTagsAdd201Response rebuild(
    void Function(ThreadTagsAdd201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadTagsAdd201ResponseBuilder toBuilder() =>
      ThreadTagsAdd201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadTagsAdd201Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadTagsAdd201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadTagsAdd201ResponseBuilder
    implements
        Builder<ThreadTagsAdd201Response, ThreadTagsAdd201ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$ThreadTagsAdd201Response? _$v;

  ThreadTagResponseDtoBuilder? _data;
  ThreadTagResponseDtoBuilder get data =>
      _$this._data ??= ThreadTagResponseDtoBuilder();
  set data(covariant ThreadTagResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadTagsAdd201ResponseBuilder() {
    ThreadTagsAdd201Response._defaults(this);
  }

  ThreadTagsAdd201ResponseBuilder get _$this {
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
  void replace(covariant ThreadTagsAdd201Response other) {
    _$v = other as _$ThreadTagsAdd201Response;
  }

  @override
  void update(void Function(ThreadTagsAdd201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadTagsAdd201Response build() => _build();

  _$ThreadTagsAdd201Response _build() {
    _$ThreadTagsAdd201Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadTagsAdd201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadTagsAdd201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadTagsAdd201Response',
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
          r'ThreadTagsAdd201Response',
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
