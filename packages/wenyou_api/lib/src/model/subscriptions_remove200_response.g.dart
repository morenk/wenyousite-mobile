// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscriptions_remove200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubscriptionsRemove200ResponseCodeEnum
_$subscriptionsRemove200ResponseCodeEnum_number0 =
    const SubscriptionsRemove200ResponseCodeEnum._('number0');
const SubscriptionsRemove200ResponseCodeEnum
_$subscriptionsRemove200ResponseCodeEnum_unknownDefaultOpenApi =
    const SubscriptionsRemove200ResponseCodeEnum._('unknownDefaultOpenApi');

SubscriptionsRemove200ResponseCodeEnum
_$subscriptionsRemove200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$subscriptionsRemove200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$subscriptionsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$subscriptionsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SubscriptionsRemove200ResponseCodeEnum>
_$subscriptionsRemove200ResponseCodeEnumValues =
    BuiltSet<SubscriptionsRemove200ResponseCodeEnum>(
      const <SubscriptionsRemove200ResponseCodeEnum>[
        _$subscriptionsRemove200ResponseCodeEnum_number0,
        _$subscriptionsRemove200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SubscriptionsRemove200ResponseCodeEnum>
_$subscriptionsRemove200ResponseCodeEnumSerializer =
    _$SubscriptionsRemove200ResponseCodeEnumSerializer();

class _$SubscriptionsRemove200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<SubscriptionsRemove200ResponseCodeEnum> {
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
    SubscriptionsRemove200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SubscriptionsRemove200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SubscriptionsRemove200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SubscriptionsRemove200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SubscriptionsRemove200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SubscriptionsRemove200Response extends SubscriptionsRemove200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SubscriptionsRemove200Response([
    void Function(SubscriptionsRemove200ResponseBuilder)? updates,
  ]) => (SubscriptionsRemove200ResponseBuilder()..update(updates))._build();

  _$SubscriptionsRemove200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SubscriptionsRemove200Response rebuild(
    void Function(SubscriptionsRemove200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubscriptionsRemove200ResponseBuilder toBuilder() =>
      SubscriptionsRemove200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubscriptionsRemove200Response &&
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
    return (newBuiltValueToStringHelper(r'SubscriptionsRemove200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SubscriptionsRemove200ResponseBuilder
    implements
        Builder<
          SubscriptionsRemove200Response,
          SubscriptionsRemove200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$SubscriptionsRemove200Response? _$v;

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

  SubscriptionsRemove200ResponseBuilder() {
    SubscriptionsRemove200Response._defaults(this);
  }

  SubscriptionsRemove200ResponseBuilder get _$this {
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
  void replace(covariant SubscriptionsRemove200Response other) {
    _$v = other as _$SubscriptionsRemove200Response;
  }

  @override
  void update(void Function(SubscriptionsRemove200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubscriptionsRemove200Response build() => _build();

  _$SubscriptionsRemove200Response _build() {
    _$SubscriptionsRemove200Response _$result;
    try {
      _$result =
          _$v ??
          _$SubscriptionsRemove200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SubscriptionsRemove200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SubscriptionsRemove200Response',
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
          r'SubscriptionsRemove200Response',
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
