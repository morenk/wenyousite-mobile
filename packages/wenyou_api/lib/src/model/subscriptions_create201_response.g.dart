// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscriptions_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubscriptionsCreate201ResponseCodeEnum
_$subscriptionsCreate201ResponseCodeEnum_number0 =
    const SubscriptionsCreate201ResponseCodeEnum._('number0');
const SubscriptionsCreate201ResponseCodeEnum
_$subscriptionsCreate201ResponseCodeEnum_unknownDefaultOpenApi =
    const SubscriptionsCreate201ResponseCodeEnum._('unknownDefaultOpenApi');

SubscriptionsCreate201ResponseCodeEnum
_$subscriptionsCreate201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$subscriptionsCreate201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$subscriptionsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$subscriptionsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SubscriptionsCreate201ResponseCodeEnum>
_$subscriptionsCreate201ResponseCodeEnumValues =
    BuiltSet<SubscriptionsCreate201ResponseCodeEnum>(
      const <SubscriptionsCreate201ResponseCodeEnum>[
        _$subscriptionsCreate201ResponseCodeEnum_number0,
        _$subscriptionsCreate201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SubscriptionsCreate201ResponseCodeEnum>
_$subscriptionsCreate201ResponseCodeEnumSerializer =
    _$SubscriptionsCreate201ResponseCodeEnumSerializer();

class _$SubscriptionsCreate201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<SubscriptionsCreate201ResponseCodeEnum> {
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
    SubscriptionsCreate201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SubscriptionsCreate201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SubscriptionsCreate201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SubscriptionsCreate201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SubscriptionsCreate201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SubscriptionsCreate201Response extends SubscriptionsCreate201Response {
  @override
  final SubscriptionResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SubscriptionsCreate201Response([
    void Function(SubscriptionsCreate201ResponseBuilder)? updates,
  ]) => (SubscriptionsCreate201ResponseBuilder()..update(updates))._build();

  _$SubscriptionsCreate201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SubscriptionsCreate201Response rebuild(
    void Function(SubscriptionsCreate201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubscriptionsCreate201ResponseBuilder toBuilder() =>
      SubscriptionsCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubscriptionsCreate201Response &&
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
    return (newBuiltValueToStringHelper(r'SubscriptionsCreate201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SubscriptionsCreate201ResponseBuilder
    implements
        Builder<
          SubscriptionsCreate201Response,
          SubscriptionsCreate201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$SubscriptionsCreate201Response? _$v;

  SubscriptionResponseDtoBuilder? _data;
  SubscriptionResponseDtoBuilder get data =>
      _$this._data ??= SubscriptionResponseDtoBuilder();
  set data(covariant SubscriptionResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  SubscriptionsCreate201ResponseBuilder() {
    SubscriptionsCreate201Response._defaults(this);
  }

  SubscriptionsCreate201ResponseBuilder get _$this {
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
  void replace(covariant SubscriptionsCreate201Response other) {
    _$v = other as _$SubscriptionsCreate201Response;
  }

  @override
  void update(void Function(SubscriptionsCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubscriptionsCreate201Response build() => _build();

  _$SubscriptionsCreate201Response _build() {
    _$SubscriptionsCreate201Response _$result;
    try {
      _$result =
          _$v ??
          _$SubscriptionsCreate201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SubscriptionsCreate201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SubscriptionsCreate201Response',
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
          r'SubscriptionsCreate201Response',
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
