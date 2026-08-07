// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscriptions_find_all200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubscriptionsFindAll200ResponseCodeEnum
_$subscriptionsFindAll200ResponseCodeEnum_number0 =
    const SubscriptionsFindAll200ResponseCodeEnum._('number0');
const SubscriptionsFindAll200ResponseCodeEnum
_$subscriptionsFindAll200ResponseCodeEnum_unknownDefaultOpenApi =
    const SubscriptionsFindAll200ResponseCodeEnum._('unknownDefaultOpenApi');

SubscriptionsFindAll200ResponseCodeEnum
_$subscriptionsFindAll200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$subscriptionsFindAll200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$subscriptionsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$subscriptionsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SubscriptionsFindAll200ResponseCodeEnum>
_$subscriptionsFindAll200ResponseCodeEnumValues =
    BuiltSet<SubscriptionsFindAll200ResponseCodeEnum>(
      const <SubscriptionsFindAll200ResponseCodeEnum>[
        _$subscriptionsFindAll200ResponseCodeEnum_number0,
        _$subscriptionsFindAll200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SubscriptionsFindAll200ResponseCodeEnum>
_$subscriptionsFindAll200ResponseCodeEnumSerializer =
    _$SubscriptionsFindAll200ResponseCodeEnumSerializer();

class _$SubscriptionsFindAll200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<SubscriptionsFindAll200ResponseCodeEnum> {
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
    SubscriptionsFindAll200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SubscriptionsFindAll200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SubscriptionsFindAll200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SubscriptionsFindAll200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SubscriptionsFindAll200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SubscriptionsFindAll200Response
    extends SubscriptionsFindAll200Response {
  @override
  final BuiltList<SubscriptionResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SubscriptionsFindAll200Response([
    void Function(SubscriptionsFindAll200ResponseBuilder)? updates,
  ]) => (SubscriptionsFindAll200ResponseBuilder()..update(updates))._build();

  _$SubscriptionsFindAll200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SubscriptionsFindAll200Response rebuild(
    void Function(SubscriptionsFindAll200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubscriptionsFindAll200ResponseBuilder toBuilder() =>
      SubscriptionsFindAll200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubscriptionsFindAll200Response &&
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
    return (newBuiltValueToStringHelper(r'SubscriptionsFindAll200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SubscriptionsFindAll200ResponseBuilder
    implements
        Builder<
          SubscriptionsFindAll200Response,
          SubscriptionsFindAll200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$SubscriptionsFindAll200Response? _$v;

  ListBuilder<SubscriptionResponseDto>? _data;
  ListBuilder<SubscriptionResponseDto> get data =>
      _$this._data ??= ListBuilder<SubscriptionResponseDto>();
  set data(covariant ListBuilder<SubscriptionResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  SubscriptionsFindAll200ResponseBuilder() {
    SubscriptionsFindAll200Response._defaults(this);
  }

  SubscriptionsFindAll200ResponseBuilder get _$this {
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
  void replace(covariant SubscriptionsFindAll200Response other) {
    _$v = other as _$SubscriptionsFindAll200Response;
  }

  @override
  void update(void Function(SubscriptionsFindAll200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubscriptionsFindAll200Response build() => _build();

  _$SubscriptionsFindAll200Response _build() {
    _$SubscriptionsFindAll200Response _$result;
    try {
      _$result =
          _$v ??
          _$SubscriptionsFindAll200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SubscriptionsFindAll200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SubscriptionsFindAll200Response',
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
          r'SubscriptionsFindAll200Response',
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
