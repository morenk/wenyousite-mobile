// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_unread_count200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationsUnreadCount200ResponseCodeEnum
_$notificationsUnreadCount200ResponseCodeEnum_number0 =
    const NotificationsUnreadCount200ResponseCodeEnum._('number0');
const NotificationsUnreadCount200ResponseCodeEnum
_$notificationsUnreadCount200ResponseCodeEnum_unknownDefaultOpenApi =
    const NotificationsUnreadCount200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

NotificationsUnreadCount200ResponseCodeEnum
_$notificationsUnreadCount200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$notificationsUnreadCount200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$notificationsUnreadCount200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$notificationsUnreadCount200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationsUnreadCount200ResponseCodeEnum>
_$notificationsUnreadCount200ResponseCodeEnumValues =
    BuiltSet<NotificationsUnreadCount200ResponseCodeEnum>(
      const <NotificationsUnreadCount200ResponseCodeEnum>[
        _$notificationsUnreadCount200ResponseCodeEnum_number0,
        _$notificationsUnreadCount200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<NotificationsUnreadCount200ResponseCodeEnum>
_$notificationsUnreadCount200ResponseCodeEnumSerializer =
    _$NotificationsUnreadCount200ResponseCodeEnumSerializer();

class _$NotificationsUnreadCount200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<NotificationsUnreadCount200ResponseCodeEnum> {
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
    NotificationsUnreadCount200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'NotificationsUnreadCount200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationsUnreadCount200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationsUnreadCount200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationsUnreadCount200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationsUnreadCount200Response
    extends NotificationsUnreadCount200Response {
  @override
  final UnreadNotificationCountResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$NotificationsUnreadCount200Response([
    void Function(NotificationsUnreadCount200ResponseBuilder)? updates,
  ]) =>
      (NotificationsUnreadCount200ResponseBuilder()..update(updates))._build();

  _$NotificationsUnreadCount200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  NotificationsUnreadCount200Response rebuild(
    void Function(NotificationsUnreadCount200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationsUnreadCount200ResponseBuilder toBuilder() =>
      NotificationsUnreadCount200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationsUnreadCount200Response &&
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
    return (newBuiltValueToStringHelper(r'NotificationsUnreadCount200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class NotificationsUnreadCount200ResponseBuilder
    implements
        Builder<
          NotificationsUnreadCount200Response,
          NotificationsUnreadCount200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$NotificationsUnreadCount200Response? _$v;

  UnreadNotificationCountResponseDtoBuilder? _data;
  UnreadNotificationCountResponseDtoBuilder get data =>
      _$this._data ??= UnreadNotificationCountResponseDtoBuilder();
  set data(covariant UnreadNotificationCountResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  NotificationsUnreadCount200ResponseBuilder() {
    NotificationsUnreadCount200Response._defaults(this);
  }

  NotificationsUnreadCount200ResponseBuilder get _$this {
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
  void replace(covariant NotificationsUnreadCount200Response other) {
    _$v = other as _$NotificationsUnreadCount200Response;
  }

  @override
  void update(
    void Function(NotificationsUnreadCount200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  NotificationsUnreadCount200Response build() => _build();

  _$NotificationsUnreadCount200Response _build() {
    _$NotificationsUnreadCount200Response _$result;
    try {
      _$result =
          _$v ??
          _$NotificationsUnreadCount200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'NotificationsUnreadCount200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'NotificationsUnreadCount200Response',
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
          r'NotificationsUnreadCount200Response',
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
