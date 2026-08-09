// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'economy_tip_user201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EconomyTipUser201ResponseCodeEnum
_$economyTipUser201ResponseCodeEnum_number0 =
    const EconomyTipUser201ResponseCodeEnum._('number0');
const EconomyTipUser201ResponseCodeEnum
_$economyTipUser201ResponseCodeEnum_unknownDefaultOpenApi =
    const EconomyTipUser201ResponseCodeEnum._('unknownDefaultOpenApi');

EconomyTipUser201ResponseCodeEnum _$economyTipUser201ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$economyTipUser201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$economyTipUser201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$economyTipUser201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<EconomyTipUser201ResponseCodeEnum>
_$economyTipUser201ResponseCodeEnumValues =
    BuiltSet<EconomyTipUser201ResponseCodeEnum>(
      const <EconomyTipUser201ResponseCodeEnum>[
        _$economyTipUser201ResponseCodeEnum_number0,
        _$economyTipUser201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<EconomyTipUser201ResponseCodeEnum>
_$economyTipUser201ResponseCodeEnumSerializer =
    _$EconomyTipUser201ResponseCodeEnumSerializer();

class _$EconomyTipUser201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<EconomyTipUser201ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[EconomyTipUser201ResponseCodeEnum];
  @override
  final String wireName = 'EconomyTipUser201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    EconomyTipUser201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  EconomyTipUser201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => EconomyTipUser201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$EconomyTipUser201Response extends EconomyTipUser201Response {
  @override
  final TipResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$EconomyTipUser201Response([
    void Function(EconomyTipUser201ResponseBuilder)? updates,
  ]) => (EconomyTipUser201ResponseBuilder()..update(updates))._build();

  _$EconomyTipUser201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  EconomyTipUser201Response rebuild(
    void Function(EconomyTipUser201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  EconomyTipUser201ResponseBuilder toBuilder() =>
      EconomyTipUser201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EconomyTipUser201Response &&
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
    return (newBuiltValueToStringHelper(r'EconomyTipUser201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class EconomyTipUser201ResponseBuilder
    implements
        Builder<EconomyTipUser201Response, EconomyTipUser201ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$EconomyTipUser201Response? _$v;

  TipResponseDtoBuilder? _data;
  TipResponseDtoBuilder get data => _$this._data ??= TipResponseDtoBuilder();
  set data(covariant TipResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  EconomyTipUser201ResponseBuilder() {
    EconomyTipUser201Response._defaults(this);
  }

  EconomyTipUser201ResponseBuilder get _$this {
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
  void replace(covariant EconomyTipUser201Response other) {
    _$v = other as _$EconomyTipUser201Response;
  }

  @override
  void update(void Function(EconomyTipUser201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EconomyTipUser201Response build() => _build();

  _$EconomyTipUser201Response _build() {
    _$EconomyTipUser201Response _$result;
    try {
      _$result =
          _$v ??
          _$EconomyTipUser201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'EconomyTipUser201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'EconomyTipUser201Response',
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
          r'EconomyTipUser201Response',
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
