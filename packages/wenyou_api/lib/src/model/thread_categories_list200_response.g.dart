// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_categories_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadCategoriesList200ResponseCodeEnum
_$threadCategoriesList200ResponseCodeEnum_number0 =
    const ThreadCategoriesList200ResponseCodeEnum._('number0');
const ThreadCategoriesList200ResponseCodeEnum
_$threadCategoriesList200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadCategoriesList200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadCategoriesList200ResponseCodeEnum
_$threadCategoriesList200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadCategoriesList200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadCategoriesList200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadCategoriesList200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadCategoriesList200ResponseCodeEnum>
_$threadCategoriesList200ResponseCodeEnumValues =
    BuiltSet<ThreadCategoriesList200ResponseCodeEnum>(
      const <ThreadCategoriesList200ResponseCodeEnum>[
        _$threadCategoriesList200ResponseCodeEnum_number0,
        _$threadCategoriesList200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadCategoriesList200ResponseCodeEnum>
_$threadCategoriesList200ResponseCodeEnumSerializer =
    _$ThreadCategoriesList200ResponseCodeEnumSerializer();

class _$ThreadCategoriesList200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadCategoriesList200ResponseCodeEnum> {
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
    ThreadCategoriesList200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadCategoriesList200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadCategoriesList200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadCategoriesList200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadCategoriesList200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadCategoriesList200Response
    extends ThreadCategoriesList200Response {
  @override
  final BuiltList<ThreadCategoryResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadCategoriesList200Response([
    void Function(ThreadCategoriesList200ResponseBuilder)? updates,
  ]) => (ThreadCategoriesList200ResponseBuilder()..update(updates))._build();

  _$ThreadCategoriesList200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadCategoriesList200Response rebuild(
    void Function(ThreadCategoriesList200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadCategoriesList200ResponseBuilder toBuilder() =>
      ThreadCategoriesList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadCategoriesList200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadCategoriesList200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadCategoriesList200ResponseBuilder
    implements
        Builder<
          ThreadCategoriesList200Response,
          ThreadCategoriesList200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$ThreadCategoriesList200Response? _$v;

  ListBuilder<ThreadCategoryResponseDto>? _data;
  ListBuilder<ThreadCategoryResponseDto> get data =>
      _$this._data ??= ListBuilder<ThreadCategoryResponseDto>();
  set data(covariant ListBuilder<ThreadCategoryResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  ThreadCategoriesList200ResponseBuilder() {
    ThreadCategoriesList200Response._defaults(this);
  }

  ThreadCategoriesList200ResponseBuilder get _$this {
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
  void replace(covariant ThreadCategoriesList200Response other) {
    _$v = other as _$ThreadCategoriesList200Response;
  }

  @override
  void update(void Function(ThreadCategoriesList200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadCategoriesList200Response build() => _build();

  _$ThreadCategoriesList200Response _build() {
    _$ThreadCategoriesList200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadCategoriesList200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadCategoriesList200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadCategoriesList200Response',
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
          r'ThreadCategoriesList200Response',
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
