// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_remove200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationsRemove200ResponseCodeEnum
_$notificationsRemove200ResponseCodeEnum_number0 =
    const NotificationsRemove200ResponseCodeEnum._('number0');
const NotificationsRemove200ResponseCodeEnum
_$notificationsRemove200ResponseCodeEnum_unknownDefaultOpenApi =
    const NotificationsRemove200ResponseCodeEnum._('unknownDefaultOpenApi');

NotificationsRemove200ResponseCodeEnum
_$notificationsRemove200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$notificationsRemove200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$notificationsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$notificationsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationsRemove200ResponseCodeEnum>
_$notificationsRemove200ResponseCodeEnumValues =
    BuiltSet<NotificationsRemove200ResponseCodeEnum>(
      const <NotificationsRemove200ResponseCodeEnum>[
        _$notificationsRemove200ResponseCodeEnum_number0,
        _$notificationsRemove200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<NotificationsRemove200ResponseCodeEnum>
_$notificationsRemove200ResponseCodeEnumSerializer =
    _$NotificationsRemove200ResponseCodeEnumSerializer();

class _$NotificationsRemove200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<NotificationsRemove200ResponseCodeEnum> {
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
    NotificationsRemove200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'NotificationsRemove200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationsRemove200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationsRemove200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationsRemove200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationsRemove200Response extends NotificationsRemove200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$NotificationsRemove200Response([
    void Function(NotificationsRemove200ResponseBuilder)? updates,
  ]) => (NotificationsRemove200ResponseBuilder()..update(updates))._build();

  _$NotificationsRemove200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  NotificationsRemove200Response rebuild(
    void Function(NotificationsRemove200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationsRemove200ResponseBuilder toBuilder() =>
      NotificationsRemove200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationsRemove200Response &&
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
    return (newBuiltValueToStringHelper(r'NotificationsRemove200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class NotificationsRemove200ResponseBuilder
    implements
        Builder<
          NotificationsRemove200Response,
          NotificationsRemove200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$NotificationsRemove200Response? _$v;

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

  NotificationsRemove200ResponseBuilder() {
    NotificationsRemove200Response._defaults(this);
  }

  NotificationsRemove200ResponseBuilder get _$this {
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
  void replace(covariant NotificationsRemove200Response other) {
    _$v = other as _$NotificationsRemove200Response;
  }

  @override
  void update(void Function(NotificationsRemove200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationsRemove200Response build() => _build();

  _$NotificationsRemove200Response _build() {
    _$NotificationsRemove200Response _$result;
    try {
      _$result =
          _$v ??
          _$NotificationsRemove200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'NotificationsRemove200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'NotificationsRemove200Response',
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
          r'NotificationsRemove200Response',
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
