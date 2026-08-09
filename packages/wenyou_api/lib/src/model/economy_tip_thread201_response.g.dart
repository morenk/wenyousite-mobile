// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'economy_tip_thread201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EconomyTipThread201ResponseCodeEnum
_$economyTipThread201ResponseCodeEnum_number0 =
    const EconomyTipThread201ResponseCodeEnum._('number0');
const EconomyTipThread201ResponseCodeEnum
_$economyTipThread201ResponseCodeEnum_unknownDefaultOpenApi =
    const EconomyTipThread201ResponseCodeEnum._('unknownDefaultOpenApi');

EconomyTipThread201ResponseCodeEnum
_$economyTipThread201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$economyTipThread201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$economyTipThread201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$economyTipThread201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<EconomyTipThread201ResponseCodeEnum>
_$economyTipThread201ResponseCodeEnumValues =
    BuiltSet<EconomyTipThread201ResponseCodeEnum>(
      const <EconomyTipThread201ResponseCodeEnum>[
        _$economyTipThread201ResponseCodeEnum_number0,
        _$economyTipThread201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<EconomyTipThread201ResponseCodeEnum>
_$economyTipThread201ResponseCodeEnumSerializer =
    _$EconomyTipThread201ResponseCodeEnumSerializer();

class _$EconomyTipThread201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<EconomyTipThread201ResponseCodeEnum> {
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
    EconomyTipThread201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'EconomyTipThread201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    EconomyTipThread201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  EconomyTipThread201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => EconomyTipThread201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$EconomyTipThread201Response extends EconomyTipThread201Response {
  @override
  final TipResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$EconomyTipThread201Response([
    void Function(EconomyTipThread201ResponseBuilder)? updates,
  ]) => (EconomyTipThread201ResponseBuilder()..update(updates))._build();

  _$EconomyTipThread201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  EconomyTipThread201Response rebuild(
    void Function(EconomyTipThread201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  EconomyTipThread201ResponseBuilder toBuilder() =>
      EconomyTipThread201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EconomyTipThread201Response &&
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
    return (newBuiltValueToStringHelper(r'EconomyTipThread201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class EconomyTipThread201ResponseBuilder
    implements
        Builder<
          EconomyTipThread201Response,
          EconomyTipThread201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$EconomyTipThread201Response? _$v;

  TipResponseDtoBuilder? _data;
  TipResponseDtoBuilder get data => _$this._data ??= TipResponseDtoBuilder();
  set data(covariant TipResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  EconomyTipThread201ResponseBuilder() {
    EconomyTipThread201Response._defaults(this);
  }

  EconomyTipThread201ResponseBuilder get _$this {
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
  void replace(covariant EconomyTipThread201Response other) {
    _$v = other as _$EconomyTipThread201Response;
  }

  @override
  void update(void Function(EconomyTipThread201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EconomyTipThread201Response build() => _build();

  _$EconomyTipThread201Response _build() {
    _$EconomyTipThread201Response _$result;
    try {
      _$result =
          _$v ??
          _$EconomyTipThread201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'EconomyTipThread201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'EconomyTipThread201Response',
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
          r'EconomyTipThread201Response',
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
