// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_mark_all_as_read200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationsMarkAllAsRead200ResponseCodeEnum
_$notificationsMarkAllAsRead200ResponseCodeEnum_number0 =
    const NotificationsMarkAllAsRead200ResponseCodeEnum._('number0');
const NotificationsMarkAllAsRead200ResponseCodeEnum
_$notificationsMarkAllAsRead200ResponseCodeEnum_unknownDefaultOpenApi =
    const NotificationsMarkAllAsRead200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

NotificationsMarkAllAsRead200ResponseCodeEnum
_$notificationsMarkAllAsRead200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$notificationsMarkAllAsRead200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$notificationsMarkAllAsRead200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$notificationsMarkAllAsRead200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationsMarkAllAsRead200ResponseCodeEnum>
_$notificationsMarkAllAsRead200ResponseCodeEnumValues =
    BuiltSet<NotificationsMarkAllAsRead200ResponseCodeEnum>(
      const <NotificationsMarkAllAsRead200ResponseCodeEnum>[
        _$notificationsMarkAllAsRead200ResponseCodeEnum_number0,
        _$notificationsMarkAllAsRead200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<NotificationsMarkAllAsRead200ResponseCodeEnum>
_$notificationsMarkAllAsRead200ResponseCodeEnumSerializer =
    _$NotificationsMarkAllAsRead200ResponseCodeEnumSerializer();

class _$NotificationsMarkAllAsRead200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<NotificationsMarkAllAsRead200ResponseCodeEnum> {
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
    NotificationsMarkAllAsRead200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'NotificationsMarkAllAsRead200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationsMarkAllAsRead200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationsMarkAllAsRead200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationsMarkAllAsRead200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationsMarkAllAsRead200Response
    extends NotificationsMarkAllAsRead200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$NotificationsMarkAllAsRead200Response([
    void Function(NotificationsMarkAllAsRead200ResponseBuilder)? updates,
  ]) => (NotificationsMarkAllAsRead200ResponseBuilder()..update(updates))
      ._build();

  _$NotificationsMarkAllAsRead200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  NotificationsMarkAllAsRead200Response rebuild(
    void Function(NotificationsMarkAllAsRead200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationsMarkAllAsRead200ResponseBuilder toBuilder() =>
      NotificationsMarkAllAsRead200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationsMarkAllAsRead200Response &&
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
            r'NotificationsMarkAllAsRead200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class NotificationsMarkAllAsRead200ResponseBuilder
    implements
        Builder<
          NotificationsMarkAllAsRead200Response,
          NotificationsMarkAllAsRead200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$NotificationsMarkAllAsRead200Response? _$v;

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

  NotificationsMarkAllAsRead200ResponseBuilder() {
    NotificationsMarkAllAsRead200Response._defaults(this);
  }

  NotificationsMarkAllAsRead200ResponseBuilder get _$this {
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
  void replace(covariant NotificationsMarkAllAsRead200Response other) {
    _$v = other as _$NotificationsMarkAllAsRead200Response;
  }

  @override
  void update(
    void Function(NotificationsMarkAllAsRead200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  NotificationsMarkAllAsRead200Response build() => _build();

  _$NotificationsMarkAllAsRead200Response _build() {
    _$NotificationsMarkAllAsRead200Response _$result;
    try {
      _$result =
          _$v ??
          _$NotificationsMarkAllAsRead200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'NotificationsMarkAllAsRead200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'NotificationsMarkAllAsRead200Response',
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
          r'NotificationsMarkAllAsRead200Response',
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
