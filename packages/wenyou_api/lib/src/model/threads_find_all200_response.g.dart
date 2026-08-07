// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threads_find_all200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadsFindAll200ResponseCodeEnum
_$threadsFindAll200ResponseCodeEnum_number0 =
    const ThreadsFindAll200ResponseCodeEnum._('number0');
const ThreadsFindAll200ResponseCodeEnum
_$threadsFindAll200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadsFindAll200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadsFindAll200ResponseCodeEnum _$threadsFindAll200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$threadsFindAll200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadsFindAll200ResponseCodeEnum>
_$threadsFindAll200ResponseCodeEnumValues =
    BuiltSet<ThreadsFindAll200ResponseCodeEnum>(
      const <ThreadsFindAll200ResponseCodeEnum>[
        _$threadsFindAll200ResponseCodeEnum_number0,
        _$threadsFindAll200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadsFindAll200ResponseCodeEnum>
_$threadsFindAll200ResponseCodeEnumSerializer =
    _$ThreadsFindAll200ResponseCodeEnumSerializer();

class _$ThreadsFindAll200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadsFindAll200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ThreadsFindAll200ResponseCodeEnum];
  @override
  final String wireName = 'ThreadsFindAll200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadsFindAll200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadsFindAll200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadsFindAll200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadsFindAll200Response extends ThreadsFindAll200Response {
  @override
  final BuiltList<HomeThreadListItemResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadsFindAll200Response([
    void Function(ThreadsFindAll200ResponseBuilder)? updates,
  ]) => (ThreadsFindAll200ResponseBuilder()..update(updates))._build();

  _$ThreadsFindAll200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadsFindAll200Response rebuild(
    void Function(ThreadsFindAll200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadsFindAll200ResponseBuilder toBuilder() =>
      ThreadsFindAll200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadsFindAll200Response &&
        data == other.data &&
        meta == other.meta &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadsFindAll200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadsFindAll200ResponseBuilder
    implements
        Builder<ThreadsFindAll200Response, ThreadsFindAll200ResponseBuilder>,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$ThreadsFindAll200Response? _$v;

  ListBuilder<HomeThreadListItemResponseDto>? _data;
  ListBuilder<HomeThreadListItemResponseDto> get data =>
      _$this._data ??= ListBuilder<HomeThreadListItemResponseDto>();
  set data(covariant ListBuilder<HomeThreadListItemResponseDto>? data) =>
      _$this._data = data;

  ApiPaginationMetaBuilder? _meta;
  ApiPaginationMetaBuilder get meta =>
      _$this._meta ??= ApiPaginationMetaBuilder();
  set meta(covariant ApiPaginationMetaBuilder? meta) => _$this._meta = meta;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadsFindAll200ResponseBuilder() {
    ThreadsFindAll200Response._defaults(this);
  }

  ThreadsFindAll200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ThreadsFindAll200Response other) {
    _$v = other as _$ThreadsFindAll200Response;
  }

  @override
  void update(void Function(ThreadsFindAll200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadsFindAll200Response build() => _build();

  _$ThreadsFindAll200Response _build() {
    _$ThreadsFindAll200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadsFindAll200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadsFindAll200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadsFindAll200Response',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ThreadsFindAll200Response',
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
