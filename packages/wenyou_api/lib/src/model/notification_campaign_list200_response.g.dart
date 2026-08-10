// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_campaign_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationCampaignList200ResponseCodeEnum
_$notificationCampaignList200ResponseCodeEnum_number0 =
    const NotificationCampaignList200ResponseCodeEnum._('number0');
const NotificationCampaignList200ResponseCodeEnum
_$notificationCampaignList200ResponseCodeEnum_unknownDefaultOpenApi =
    const NotificationCampaignList200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

NotificationCampaignList200ResponseCodeEnum
_$notificationCampaignList200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$notificationCampaignList200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$notificationCampaignList200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$notificationCampaignList200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationCampaignList200ResponseCodeEnum>
_$notificationCampaignList200ResponseCodeEnumValues =
    BuiltSet<NotificationCampaignList200ResponseCodeEnum>(
      const <NotificationCampaignList200ResponseCodeEnum>[
        _$notificationCampaignList200ResponseCodeEnum_number0,
        _$notificationCampaignList200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<NotificationCampaignList200ResponseCodeEnum>
_$notificationCampaignList200ResponseCodeEnumSerializer =
    _$NotificationCampaignList200ResponseCodeEnumSerializer();

class _$NotificationCampaignList200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<NotificationCampaignList200ResponseCodeEnum> {
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
    NotificationCampaignList200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'NotificationCampaignList200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationCampaignList200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationCampaignList200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationCampaignList200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationCampaignList200Response
    extends NotificationCampaignList200Response {
  @override
  final BuiltList<NotificationCampaignResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$NotificationCampaignList200Response([
    void Function(NotificationCampaignList200ResponseBuilder)? updates,
  ]) =>
      (NotificationCampaignList200ResponseBuilder()..update(updates))._build();

  _$NotificationCampaignList200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  NotificationCampaignList200Response rebuild(
    void Function(NotificationCampaignList200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationCampaignList200ResponseBuilder toBuilder() =>
      NotificationCampaignList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationCampaignList200Response &&
        data == other.data &&
        meta == other.meta &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationCampaignList200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class NotificationCampaignList200ResponseBuilder
    implements
        Builder<
          NotificationCampaignList200Response,
          NotificationCampaignList200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$NotificationCampaignList200Response? _$v;

  ListBuilder<NotificationCampaignResponseDto>? _data;
  ListBuilder<NotificationCampaignResponseDto> get data =>
      _$this._data ??= ListBuilder<NotificationCampaignResponseDto>();
  set data(covariant ListBuilder<NotificationCampaignResponseDto>? data) =>
      _$this._data = data;

  ApiPaginationMetaBuilder? _meta;
  ApiPaginationMetaBuilder get meta =>
      _$this._meta ??= ApiPaginationMetaBuilder();
  set meta(covariant ApiPaginationMetaBuilder? meta) => _$this._meta = meta;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  NotificationCampaignList200ResponseBuilder() {
    NotificationCampaignList200Response._defaults(this);
  }

  NotificationCampaignList200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant NotificationCampaignList200Response other) {
    _$v = other as _$NotificationCampaignList200Response;
  }

  @override
  void update(
    void Function(NotificationCampaignList200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  NotificationCampaignList200Response build() => _build();

  _$NotificationCampaignList200Response _build() {
    _$NotificationCampaignList200Response _$result;
    try {
      _$result =
          _$v ??
          _$NotificationCampaignList200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'NotificationCampaignList200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'NotificationCampaignList200Response',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'NotificationCampaignList200Response',
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
