// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_campaign_cancel200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationCampaignCancel200ResponseCodeEnum
_$notificationCampaignCancel200ResponseCodeEnum_number0 =
    const NotificationCampaignCancel200ResponseCodeEnum._('number0');
const NotificationCampaignCancel200ResponseCodeEnum
_$notificationCampaignCancel200ResponseCodeEnum_unknownDefaultOpenApi =
    const NotificationCampaignCancel200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

NotificationCampaignCancel200ResponseCodeEnum
_$notificationCampaignCancel200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$notificationCampaignCancel200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$notificationCampaignCancel200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$notificationCampaignCancel200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationCampaignCancel200ResponseCodeEnum>
_$notificationCampaignCancel200ResponseCodeEnumValues =
    BuiltSet<NotificationCampaignCancel200ResponseCodeEnum>(
      const <NotificationCampaignCancel200ResponseCodeEnum>[
        _$notificationCampaignCancel200ResponseCodeEnum_number0,
        _$notificationCampaignCancel200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<NotificationCampaignCancel200ResponseCodeEnum>
_$notificationCampaignCancel200ResponseCodeEnumSerializer =
    _$NotificationCampaignCancel200ResponseCodeEnumSerializer();

class _$NotificationCampaignCancel200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<NotificationCampaignCancel200ResponseCodeEnum> {
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
    NotificationCampaignCancel200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'NotificationCampaignCancel200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationCampaignCancel200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationCampaignCancel200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationCampaignCancel200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationCampaignCancel200Response
    extends NotificationCampaignCancel200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$NotificationCampaignCancel200Response([
    void Function(NotificationCampaignCancel200ResponseBuilder)? updates,
  ]) => (NotificationCampaignCancel200ResponseBuilder()..update(updates))
      ._build();

  _$NotificationCampaignCancel200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  NotificationCampaignCancel200Response rebuild(
    void Function(NotificationCampaignCancel200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationCampaignCancel200ResponseBuilder toBuilder() =>
      NotificationCampaignCancel200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationCampaignCancel200Response &&
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
            r'NotificationCampaignCancel200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class NotificationCampaignCancel200ResponseBuilder
    implements
        Builder<
          NotificationCampaignCancel200Response,
          NotificationCampaignCancel200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$NotificationCampaignCancel200Response? _$v;

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

  NotificationCampaignCancel200ResponseBuilder() {
    NotificationCampaignCancel200Response._defaults(this);
  }

  NotificationCampaignCancel200ResponseBuilder get _$this {
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
  void replace(covariant NotificationCampaignCancel200Response other) {
    _$v = other as _$NotificationCampaignCancel200Response;
  }

  @override
  void update(
    void Function(NotificationCampaignCancel200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  NotificationCampaignCancel200Response build() => _build();

  _$NotificationCampaignCancel200Response _build() {
    _$NotificationCampaignCancel200Response _$result;
    try {
      _$result =
          _$v ??
          _$NotificationCampaignCancel200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'NotificationCampaignCancel200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'NotificationCampaignCancel200Response',
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
          r'NotificationCampaignCancel200Response',
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
