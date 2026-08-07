// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_set_read_status200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationsSetReadStatus200ResponseCodeEnum
_$notificationsSetReadStatus200ResponseCodeEnum_number0 =
    const NotificationsSetReadStatus200ResponseCodeEnum._('number0');
const NotificationsSetReadStatus200ResponseCodeEnum
_$notificationsSetReadStatus200ResponseCodeEnum_unknownDefaultOpenApi =
    const NotificationsSetReadStatus200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

NotificationsSetReadStatus200ResponseCodeEnum
_$notificationsSetReadStatus200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$notificationsSetReadStatus200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$notificationsSetReadStatus200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$notificationsSetReadStatus200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationsSetReadStatus200ResponseCodeEnum>
_$notificationsSetReadStatus200ResponseCodeEnumValues =
    BuiltSet<NotificationsSetReadStatus200ResponseCodeEnum>(
      const <NotificationsSetReadStatus200ResponseCodeEnum>[
        _$notificationsSetReadStatus200ResponseCodeEnum_number0,
        _$notificationsSetReadStatus200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<NotificationsSetReadStatus200ResponseCodeEnum>
_$notificationsSetReadStatus200ResponseCodeEnumSerializer =
    _$NotificationsSetReadStatus200ResponseCodeEnumSerializer();

class _$NotificationsSetReadStatus200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<NotificationsSetReadStatus200ResponseCodeEnum> {
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
    NotificationsSetReadStatus200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'NotificationsSetReadStatus200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationsSetReadStatus200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationsSetReadStatus200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationsSetReadStatus200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationsSetReadStatus200Response
    extends NotificationsSetReadStatus200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$NotificationsSetReadStatus200Response([
    void Function(NotificationsSetReadStatus200ResponseBuilder)? updates,
  ]) => (NotificationsSetReadStatus200ResponseBuilder()..update(updates))
      ._build();

  _$NotificationsSetReadStatus200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  NotificationsSetReadStatus200Response rebuild(
    void Function(NotificationsSetReadStatus200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationsSetReadStatus200ResponseBuilder toBuilder() =>
      NotificationsSetReadStatus200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationsSetReadStatus200Response &&
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
    return (newBuiltValueToStringHelper(
            r'NotificationsSetReadStatus200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class NotificationsSetReadStatus200ResponseBuilder
    implements
        Builder<
          NotificationsSetReadStatus200Response,
          NotificationsSetReadStatus200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$NotificationsSetReadStatus200Response? _$v;

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

  NotificationsSetReadStatus200ResponseBuilder() {
    NotificationsSetReadStatus200Response._defaults(this);
  }

  NotificationsSetReadStatus200ResponseBuilder get _$this {
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
  void replace(covariant NotificationsSetReadStatus200Response other) {
    _$v = other as _$NotificationsSetReadStatus200Response;
  }

  @override
  void update(
    void Function(NotificationsSetReadStatus200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  NotificationsSetReadStatus200Response build() => _build();

  _$NotificationsSetReadStatus200Response _build() {
    _$NotificationsSetReadStatus200Response _$result;
    try {
      _$result =
          _$v ??
          _$NotificationsSetReadStatus200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'NotificationsSetReadStatus200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'NotificationsSetReadStatus200Response',
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
          r'NotificationsSetReadStatus200Response',
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
