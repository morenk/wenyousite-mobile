// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subthreads_update200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubthreadsUpdate200ResponseCodeEnum
_$subthreadsUpdate200ResponseCodeEnum_number0 =
    const SubthreadsUpdate200ResponseCodeEnum._('number0');
const SubthreadsUpdate200ResponseCodeEnum
_$subthreadsUpdate200ResponseCodeEnum_unknownDefaultOpenApi =
    const SubthreadsUpdate200ResponseCodeEnum._('unknownDefaultOpenApi');

SubthreadsUpdate200ResponseCodeEnum
_$subthreadsUpdate200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$subthreadsUpdate200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$subthreadsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$subthreadsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SubthreadsUpdate200ResponseCodeEnum>
_$subthreadsUpdate200ResponseCodeEnumValues =
    BuiltSet<SubthreadsUpdate200ResponseCodeEnum>(
      const <SubthreadsUpdate200ResponseCodeEnum>[
        _$subthreadsUpdate200ResponseCodeEnum_number0,
        _$subthreadsUpdate200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SubthreadsUpdate200ResponseCodeEnum>
_$subthreadsUpdate200ResponseCodeEnumSerializer =
    _$SubthreadsUpdate200ResponseCodeEnumSerializer();

class _$SubthreadsUpdate200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<SubthreadsUpdate200ResponseCodeEnum> {
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
    SubthreadsUpdate200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SubthreadsUpdate200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SubthreadsUpdate200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SubthreadsUpdate200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SubthreadsUpdate200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SubthreadsUpdate200Response extends SubthreadsUpdate200Response {
  @override
  final SubthreadResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SubthreadsUpdate200Response([
    void Function(SubthreadsUpdate200ResponseBuilder)? updates,
  ]) => (SubthreadsUpdate200ResponseBuilder()..update(updates))._build();

  _$SubthreadsUpdate200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SubthreadsUpdate200Response rebuild(
    void Function(SubthreadsUpdate200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubthreadsUpdate200ResponseBuilder toBuilder() =>
      SubthreadsUpdate200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubthreadsUpdate200Response &&
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
    return (newBuiltValueToStringHelper(r'SubthreadsUpdate200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SubthreadsUpdate200ResponseBuilder
    implements
        Builder<
          SubthreadsUpdate200Response,
          SubthreadsUpdate200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$SubthreadsUpdate200Response? _$v;

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

  SubthreadsUpdate200ResponseBuilder() {
    SubthreadsUpdate200Response._defaults(this);
  }

  SubthreadsUpdate200ResponseBuilder get _$this {
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
  void replace(covariant SubthreadsUpdate200Response other) {
    _$v = other as _$SubthreadsUpdate200Response;
  }

  @override
  void update(void Function(SubthreadsUpdate200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubthreadsUpdate200Response build() => _build();

  _$SubthreadsUpdate200Response _build() {
    _$SubthreadsUpdate200Response _$result;
    try {
      _$result =
          _$v ??
          _$SubthreadsUpdate200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SubthreadsUpdate200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SubthreadsUpdate200Response',
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
          r'SubthreadsUpdate200Response',
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
