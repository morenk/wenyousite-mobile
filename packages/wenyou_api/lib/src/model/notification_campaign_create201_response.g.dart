// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_campaign_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationCampaignCreate201ResponseCodeEnum
_$notificationCampaignCreate201ResponseCodeEnum_number0 =
    const NotificationCampaignCreate201ResponseCodeEnum._('number0');
const NotificationCampaignCreate201ResponseCodeEnum
_$notificationCampaignCreate201ResponseCodeEnum_unknownDefaultOpenApi =
    const NotificationCampaignCreate201ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

NotificationCampaignCreate201ResponseCodeEnum
_$notificationCampaignCreate201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$notificationCampaignCreate201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$notificationCampaignCreate201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$notificationCampaignCreate201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationCampaignCreate201ResponseCodeEnum>
_$notificationCampaignCreate201ResponseCodeEnumValues =
    BuiltSet<NotificationCampaignCreate201ResponseCodeEnum>(
      const <NotificationCampaignCreate201ResponseCodeEnum>[
        _$notificationCampaignCreate201ResponseCodeEnum_number0,
        _$notificationCampaignCreate201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<NotificationCampaignCreate201ResponseCodeEnum>
_$notificationCampaignCreate201ResponseCodeEnumSerializer =
    _$NotificationCampaignCreate201ResponseCodeEnumSerializer();

class _$NotificationCampaignCreate201ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<NotificationCampaignCreate201ResponseCodeEnum> {
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
    NotificationCampaignCreate201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'NotificationCampaignCreate201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationCampaignCreate201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationCampaignCreate201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationCampaignCreate201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationCampaignCreate201Response
    extends NotificationCampaignCreate201Response {
  @override
  final NotificationCampaignResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$NotificationCampaignCreate201Response([
    void Function(NotificationCampaignCreate201ResponseBuilder)? updates,
  ]) => (NotificationCampaignCreate201ResponseBuilder()..update(updates))
      ._build();

  _$NotificationCampaignCreate201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  NotificationCampaignCreate201Response rebuild(
    void Function(NotificationCampaignCreate201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationCampaignCreate201ResponseBuilder toBuilder() =>
      NotificationCampaignCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationCampaignCreate201Response &&
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
            r'NotificationCampaignCreate201Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class NotificationCampaignCreate201ResponseBuilder
    implements
        Builder<
          NotificationCampaignCreate201Response,
          NotificationCampaignCreate201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$NotificationCampaignCreate201Response? _$v;

  NotificationCampaignResponseDtoBuilder? _data;
  NotificationCampaignResponseDtoBuilder get data =>
      _$this._data ??= NotificationCampaignResponseDtoBuilder();
  set data(covariant NotificationCampaignResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  NotificationCampaignCreate201ResponseBuilder() {
    NotificationCampaignCreate201Response._defaults(this);
  }

  NotificationCampaignCreate201ResponseBuilder get _$this {
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
  void replace(covariant NotificationCampaignCreate201Response other) {
    _$v = other as _$NotificationCampaignCreate201Response;
  }

  @override
  void update(
    void Function(NotificationCampaignCreate201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  NotificationCampaignCreate201Response build() => _build();

  _$NotificationCampaignCreate201Response _build() {
    _$NotificationCampaignCreate201Response _$result;
    try {
      _$result =
          _$v ??
          _$NotificationCampaignCreate201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'NotificationCampaignCreate201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'NotificationCampaignCreate201Response',
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
          r'NotificationCampaignCreate201Response',
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
