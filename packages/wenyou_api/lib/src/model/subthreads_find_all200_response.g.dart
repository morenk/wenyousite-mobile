// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subthreads_find_all200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubthreadsFindAll200ResponseCodeEnum
_$subthreadsFindAll200ResponseCodeEnum_number0 =
    const SubthreadsFindAll200ResponseCodeEnum._('number0');
const SubthreadsFindAll200ResponseCodeEnum
_$subthreadsFindAll200ResponseCodeEnum_unknownDefaultOpenApi =
    const SubthreadsFindAll200ResponseCodeEnum._('unknownDefaultOpenApi');

SubthreadsFindAll200ResponseCodeEnum
_$subthreadsFindAll200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$subthreadsFindAll200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$subthreadsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$subthreadsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SubthreadsFindAll200ResponseCodeEnum>
_$subthreadsFindAll200ResponseCodeEnumValues =
    BuiltSet<SubthreadsFindAll200ResponseCodeEnum>(
      const <SubthreadsFindAll200ResponseCodeEnum>[
        _$subthreadsFindAll200ResponseCodeEnum_number0,
        _$subthreadsFindAll200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SubthreadsFindAll200ResponseCodeEnum>
_$subthreadsFindAll200ResponseCodeEnumSerializer =
    _$SubthreadsFindAll200ResponseCodeEnumSerializer();

class _$SubthreadsFindAll200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<SubthreadsFindAll200ResponseCodeEnum> {
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
    SubthreadsFindAll200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SubthreadsFindAll200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SubthreadsFindAll200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SubthreadsFindAll200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SubthreadsFindAll200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SubthreadsFindAll200Response extends SubthreadsFindAll200Response {
  @override
  final BuiltList<SubthreadResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SubthreadsFindAll200Response([
    void Function(SubthreadsFindAll200ResponseBuilder)? updates,
  ]) => (SubthreadsFindAll200ResponseBuilder()..update(updates))._build();

  _$SubthreadsFindAll200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SubthreadsFindAll200Response rebuild(
    void Function(SubthreadsFindAll200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubthreadsFindAll200ResponseBuilder toBuilder() =>
      SubthreadsFindAll200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubthreadsFindAll200Response &&
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
    return (newBuiltValueToStringHelper(r'SubthreadsFindAll200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SubthreadsFindAll200ResponseBuilder
    implements
        Builder<
          SubthreadsFindAll200Response,
          SubthreadsFindAll200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$SubthreadsFindAll200Response? _$v;

  ListBuilder<SubthreadResponseDto>? _data;
  ListBuilder<SubthreadResponseDto> get data =>
      _$this._data ??= ListBuilder<SubthreadResponseDto>();
  set data(covariant ListBuilder<SubthreadResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  SubthreadsFindAll200ResponseBuilder() {
    SubthreadsFindAll200Response._defaults(this);
  }

  SubthreadsFindAll200ResponseBuilder get _$this {
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
  void replace(covariant SubthreadsFindAll200Response other) {
    _$v = other as _$SubthreadsFindAll200Response;
  }

  @override
  void update(void Function(SubthreadsFindAll200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubthreadsFindAll200Response build() => _build();

  _$SubthreadsFindAll200Response _build() {
    _$SubthreadsFindAll200Response _$result;
    try {
      _$result =
          _$v ??
          _$SubthreadsFindAll200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SubthreadsFindAll200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SubthreadsFindAll200Response',
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
          r'SubthreadsFindAll200Response',
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
