// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subthreads_remove200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubthreadsRemove200ResponseCodeEnum
_$subthreadsRemove200ResponseCodeEnum_number0 =
    const SubthreadsRemove200ResponseCodeEnum._('number0');
const SubthreadsRemove200ResponseCodeEnum
_$subthreadsRemove200ResponseCodeEnum_unknownDefaultOpenApi =
    const SubthreadsRemove200ResponseCodeEnum._('unknownDefaultOpenApi');

SubthreadsRemove200ResponseCodeEnum
_$subthreadsRemove200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$subthreadsRemove200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$subthreadsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$subthreadsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SubthreadsRemove200ResponseCodeEnum>
_$subthreadsRemove200ResponseCodeEnumValues =
    BuiltSet<SubthreadsRemove200ResponseCodeEnum>(
      const <SubthreadsRemove200ResponseCodeEnum>[
        _$subthreadsRemove200ResponseCodeEnum_number0,
        _$subthreadsRemove200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SubthreadsRemove200ResponseCodeEnum>
_$subthreadsRemove200ResponseCodeEnumSerializer =
    _$SubthreadsRemove200ResponseCodeEnumSerializer();

class _$SubthreadsRemove200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<SubthreadsRemove200ResponseCodeEnum> {
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
    SubthreadsRemove200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SubthreadsRemove200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SubthreadsRemove200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SubthreadsRemove200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SubthreadsRemove200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SubthreadsRemove200Response extends SubthreadsRemove200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SubthreadsRemove200Response([
    void Function(SubthreadsRemove200ResponseBuilder)? updates,
  ]) => (SubthreadsRemove200ResponseBuilder()..update(updates))._build();

  _$SubthreadsRemove200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SubthreadsRemove200Response rebuild(
    void Function(SubthreadsRemove200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubthreadsRemove200ResponseBuilder toBuilder() =>
      SubthreadsRemove200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubthreadsRemove200Response &&
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
    return (newBuiltValueToStringHelper(r'SubthreadsRemove200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SubthreadsRemove200ResponseBuilder
    implements
        Builder<
          SubthreadsRemove200Response,
          SubthreadsRemove200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$SubthreadsRemove200Response? _$v;

  MessageResponseDtoBuilder? _data;
  MessageResponseDtoBuilder get data =>
      _$this._data ??= MessageResponseDtoBuilder();
  set data(covariant MessageResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  SubthreadsRemove200ResponseBuilder() {
    SubthreadsRemove200Response._defaults(this);
  }

  SubthreadsRemove200ResponseBuilder get _$this {
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
  void replace(covariant SubthreadsRemove200Response other) {
    _$v = other as _$SubthreadsRemove200Response;
  }

  @override
  void update(void Function(SubthreadsRemove200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubthreadsRemove200Response build() => _build();

  _$SubthreadsRemove200Response _build() {
    _$SubthreadsRemove200Response _$result;
    try {
      _$result =
          _$v ??
          _$SubthreadsRemove200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SubthreadsRemove200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SubthreadsRemove200Response',
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
          r'SubthreadsRemove200Response',
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
