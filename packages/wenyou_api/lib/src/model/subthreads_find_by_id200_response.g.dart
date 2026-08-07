// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subthreads_find_by_id200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubthreadsFindById200ResponseCodeEnum
_$subthreadsFindById200ResponseCodeEnum_number0 =
    const SubthreadsFindById200ResponseCodeEnum._('number0');
const SubthreadsFindById200ResponseCodeEnum
_$subthreadsFindById200ResponseCodeEnum_unknownDefaultOpenApi =
    const SubthreadsFindById200ResponseCodeEnum._('unknownDefaultOpenApi');

SubthreadsFindById200ResponseCodeEnum
_$subthreadsFindById200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$subthreadsFindById200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$subthreadsFindById200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$subthreadsFindById200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SubthreadsFindById200ResponseCodeEnum>
_$subthreadsFindById200ResponseCodeEnumValues =
    BuiltSet<SubthreadsFindById200ResponseCodeEnum>(
      const <SubthreadsFindById200ResponseCodeEnum>[
        _$subthreadsFindById200ResponseCodeEnum_number0,
        _$subthreadsFindById200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SubthreadsFindById200ResponseCodeEnum>
_$subthreadsFindById200ResponseCodeEnumSerializer =
    _$SubthreadsFindById200ResponseCodeEnumSerializer();

class _$SubthreadsFindById200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<SubthreadsFindById200ResponseCodeEnum> {
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
    SubthreadsFindById200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SubthreadsFindById200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SubthreadsFindById200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SubthreadsFindById200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SubthreadsFindById200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SubthreadsFindById200Response extends SubthreadsFindById200Response {
  @override
  final SubthreadResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SubthreadsFindById200Response([
    void Function(SubthreadsFindById200ResponseBuilder)? updates,
  ]) => (SubthreadsFindById200ResponseBuilder()..update(updates))._build();

  _$SubthreadsFindById200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SubthreadsFindById200Response rebuild(
    void Function(SubthreadsFindById200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubthreadsFindById200ResponseBuilder toBuilder() =>
      SubthreadsFindById200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubthreadsFindById200Response &&
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
    return (newBuiltValueToStringHelper(r'SubthreadsFindById200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SubthreadsFindById200ResponseBuilder
    implements
        Builder<
          SubthreadsFindById200Response,
          SubthreadsFindById200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$SubthreadsFindById200Response? _$v;

  SubthreadResponseDtoBuilder? _data;
  SubthreadResponseDtoBuilder get data =>
      _$this._data ??= SubthreadResponseDtoBuilder();
  set data(covariant SubthreadResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  SubthreadsFindById200ResponseBuilder() {
    SubthreadsFindById200Response._defaults(this);
  }

  SubthreadsFindById200ResponseBuilder get _$this {
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
  void replace(covariant SubthreadsFindById200Response other) {
    _$v = other as _$SubthreadsFindById200Response;
  }

  @override
  void update(void Function(SubthreadsFindById200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubthreadsFindById200Response build() => _build();

  _$SubthreadsFindById200Response _build() {
    _$SubthreadsFindById200Response _$result;
    try {
      _$result =
          _$v ??
          _$SubthreadsFindById200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SubthreadsFindById200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SubthreadsFindById200Response',
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
          r'SubthreadsFindById200Response',
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
