// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'economy_tip_moment201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EconomyTipMoment201ResponseCodeEnum
_$economyTipMoment201ResponseCodeEnum_number0 =
    const EconomyTipMoment201ResponseCodeEnum._('number0');
const EconomyTipMoment201ResponseCodeEnum
_$economyTipMoment201ResponseCodeEnum_unknownDefaultOpenApi =
    const EconomyTipMoment201ResponseCodeEnum._('unknownDefaultOpenApi');

EconomyTipMoment201ResponseCodeEnum
_$economyTipMoment201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$economyTipMoment201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$economyTipMoment201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$economyTipMoment201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<EconomyTipMoment201ResponseCodeEnum>
_$economyTipMoment201ResponseCodeEnumValues =
    BuiltSet<EconomyTipMoment201ResponseCodeEnum>(
      const <EconomyTipMoment201ResponseCodeEnum>[
        _$economyTipMoment201ResponseCodeEnum_number0,
        _$economyTipMoment201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<EconomyTipMoment201ResponseCodeEnum>
_$economyTipMoment201ResponseCodeEnumSerializer =
    _$EconomyTipMoment201ResponseCodeEnumSerializer();

class _$EconomyTipMoment201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<EconomyTipMoment201ResponseCodeEnum> {
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
    EconomyTipMoment201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'EconomyTipMoment201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    EconomyTipMoment201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  EconomyTipMoment201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => EconomyTipMoment201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$EconomyTipMoment201Response extends EconomyTipMoment201Response {
  @override
  final TipResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$EconomyTipMoment201Response([
    void Function(EconomyTipMoment201ResponseBuilder)? updates,
  ]) => (EconomyTipMoment201ResponseBuilder()..update(updates))._build();

  _$EconomyTipMoment201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  EconomyTipMoment201Response rebuild(
    void Function(EconomyTipMoment201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  EconomyTipMoment201ResponseBuilder toBuilder() =>
      EconomyTipMoment201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EconomyTipMoment201Response &&
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
    return (newBuiltValueToStringHelper(r'EconomyTipMoment201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class EconomyTipMoment201ResponseBuilder
    implements
        Builder<
          EconomyTipMoment201Response,
          EconomyTipMoment201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$EconomyTipMoment201Response? _$v;

  TipResponseDtoBuilder? _data;
  TipResponseDtoBuilder get data => _$this._data ??= TipResponseDtoBuilder();
  set data(covariant TipResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  EconomyTipMoment201ResponseBuilder() {
    EconomyTipMoment201Response._defaults(this);
  }

  EconomyTipMoment201ResponseBuilder get _$this {
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
  void replace(covariant EconomyTipMoment201Response other) {
    _$v = other as _$EconomyTipMoment201Response;
  }

  @override
  void update(void Function(EconomyTipMoment201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EconomyTipMoment201Response build() => _build();

  _$EconomyTipMoment201Response _build() {
    _$EconomyTipMoment201Response _$result;
    try {
      _$result =
          _$v ??
          _$EconomyTipMoment201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'EconomyTipMoment201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'EconomyTipMoment201Response',
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
          r'EconomyTipMoment201Response',
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
